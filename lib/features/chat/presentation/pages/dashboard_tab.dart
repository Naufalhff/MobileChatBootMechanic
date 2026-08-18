import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'chat_page.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'CB Series', 'GL Series', 'C Series'];

  final List<Map<String, dynamic>> _motors = [
    {
      'name': 'Honda CB 100',
      'subtitle': 'Platina & Kelistrikan',
      'desc': 'Panduan restorasi kelistrikan bodi & karburator Keihin original.',
      'category': 'CB Series',
      'tier': 'Tier 1 Verified',
      'icon': Icons.motorcycle_rounded,
      'color': Color(0xFF4F46E5),
      'imagePath': 'assets/images/cb100.jpg',
    },
    {
      'name': 'Honda GL Pro',
      'subtitle': 'CDI & Mesin Neotech',
      'desc': 'Diagnosa pengapian CDI, spul pengisian magnet, & mesin.',
      'category': 'GL Series',
      'tier': 'Tier 1 Verified',
      'icon': Icons.settings_suggest_rounded,
      'color': Color(0xFF06B6D4),
      'imagePath': 'assets/images/glpro.jpg',
    },
    {
      'name': 'Honda GL Max',
      'subtitle': 'Kelistrikan & Karbu',
      'desc': 'Skema kelistrikan karburator PE & spul pengapian AC.',
      'category': 'GL Series',
      'tier': 'Tier 2 AI',
      'icon': Icons.build_circle_outlined,
      'color': Color(0xFFF59E0B),
      'imagePath': 'assets/images/glmax.jpg',
    },
    {
      'name': 'Honda Astrea Grand',
      'subtitle': 'C-Series Horizontal',
      'desc': 'Troubleshoot dinamo starter elektrik, kopling ganda, & aki.',
      'category': 'C Series',
      'tier': 'Tier 2 AI',
      'icon': Icons.two_wheeler_rounded,
      'color': Color(0xFF10B981),
      'imagePath': 'assets/images/astrea.png',
    },
    {
      'name': 'Honda C70',
      'subtitle': 'Platina 6V Klasik',
      'desc': 'Buku manual sistem pengapian platina 6 Volt & kabel bodi.',
      'category': 'C Series',
      'tier': 'Tier 2 AI',
      'icon': Icons.bolt_rounded,
      'color': Color(0xFFEC4899),
      'imagePath': 'assets/images/c70.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter motors based on category
    final filteredMotors = _selectedCategory == 'Semua'
        ? _motors
        : _motors.where((m) => m['category'] == _selectedCategory).toList();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 40 - 14) / 2;
    final double dynamicAspectRatio = cardWidth / 270.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pocket Mechanic',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pilih tipe motor klasik Anda untuk memulai',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Categories selection row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Daftar Manual Motor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: dynamicAspectRatio,
                ),
                itemCount: filteredMotors.length,
                itemBuilder: (context, index) {
                  final motor = filteredMotors[index];
                  final isTier1 = motor['tier'] == 'Tier 1 Verified';

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatPage(initialMotor: motor['name']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.asset(
                              motor['imagePath'],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: motor['color'].withOpacity(0.08),
                                  child: Center(
                                    child: Icon(
                                      motor['icon'],
                                      color: motor['color'],
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  motor['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  motor['subtitle'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: motor['color'],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  motor['desc'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: AppColors.textSecondary,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Tier verification badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isTier1 ? Colors.green.shade50 : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isTier1 ? Colors.green.shade200 : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    motor['tier'],
                                    style: TextStyle(
                                      color: isTier1 ? Colors.green.shade700 : Colors.grey.shade600,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 28,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChatPage(initialMotor: motor['name']),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Tanya AI',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
