import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/welcome_page.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Pengaturan Profil',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            String fullName = 'Nama Pengguna';
            String email = 'email@domain.com';

            if (state is AuthSuccess) {
              fullName = state.user.fullName;
              email = state.user.email;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(Icons.person_outline_rounded, 'Nama Lengkap', fullName),
                        const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 56),
                        _buildInfoTile(Icons.email_outlined, 'Email', email),
                        const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 56),
                        _buildInfoTile(Icons.wc_outlined, 'Gender', 'Laki-laki'),
                        const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 56),
                        _buildInfoTile(Icons.calendar_today_outlined, 'Tanggal Lahir', '1998-05-15'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(Icons.shield_outlined, 'Kebijakan Privasi'),
                        const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 56),
                        _buildSettingsTile(Icons.description_outlined, 'Syarat & Ketentuan'),
                        const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 56),
                        _buildSettingsTile(Icons.info_outline_rounded, 'Versi Aplikasi', subtitle: '1.0.0'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade600,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Keluar Akun',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      trailing: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textDisabled),
    );
  }
}
