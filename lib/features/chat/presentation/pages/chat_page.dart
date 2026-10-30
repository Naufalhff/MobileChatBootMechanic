import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/ai_model_model.dart';
import '../cubit/chat_cubit.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  final String? initialMotor;
  final String? initialModel;
  final int? conversationId;

  const ChatPage({
    Key? key,
    this.initialMotor,
    this.initialModel,
    this.conversationId,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const String _selectedModelPrefKey = 'selected_ai_model';

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _modelSearchController = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedMotor;
  String? _selectedModelId;
  String? _attachedImagePath;

  @override
  void initState() {
    super.initState();
    _selectedMotor = widget.initialMotor;
    _selectedModelId = widget.initialModel;
    _loadSavedModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadChat(
            conversationId: widget.conversationId,
          );
    });
  }

  Future<void> _loadSavedModel() async {
    if (widget.initialModel != null) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_selectedModelPrefKey);
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _selectedModelId = saved;
      });
    }
  }

  void _startNewChat() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          initialMotor: _selectedMotor,
          initialModel: _selectedModelId,
        ),
      ),
    );
  }

  Future<void> _selectModel(String modelId) async {
    setState(() {
      _selectedModelId = modelId;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelPrefKey, modelId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _modelSearchController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _attachedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _removeAttachedImage() {
    setState(() {
      _attachedImagePath = null;
    });
  }

  void _sendMessage() {
    final chatState = context.read<ChatCubit>().state;
    if (chatState is ChatLoaded && chatState.isSending) return;

    final text = _messageController.text.trim();
    if (text.isEmpty && _attachedImagePath == null) return;

    if (_selectedMotor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih model motor Anda terlebih dahulu!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selectedModel = _findSelectedModel();
    if (_attachedImagePath != null && selectedModel?.supportsVision == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Model ${selectedModel!.label} tidak mendukung analisis gambar. '
            'Pilih model lain atau hapus lampiran foto.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<ChatCubit>().sendMessage(
          message: text,
          motorModel: _selectedMotor!,
          model: _selectedModelId,
          localImagePath: _attachedImagePath,
        );

    _messageController.clear();
    setState(() {
      _attachedImagePath = null;
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _selectedMotor ?? 'Pocket Mechanic',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Mekanik Aktif',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_comment_outlined,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Sesi Baru',
            onPressed: _startNewChat,
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded) {
              Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
            }
          },
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 64),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<ChatCubit>().loadChat(
                              conversationId: widget.conversationId,
                            ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ChatLoaded) {
              if (_selectedMotor == null && state.supportedMotors.isNotEmpty) {
                _selectedMotor = widget.initialMotor ?? (state.supportedMotors.first['model_name'] ?? '').toString();
              }

              if (state.aiModels.isNotEmpty) {
                final isKnown = state.aiModels
                    .any((model) => model.id == _selectedModelId);
                if (_selectedModelId == null || !isKnown) {
                  final preferred = state.defaultModel;
                  final hasPreferred = preferred != null &&
                      state.aiModels.any((model) => model.id == preferred);
                  _selectedModelId =
                      hasPreferred ? preferred : state.aiModels.first.id;
                }
              }

              final filteredMessages = state.conversationId != null
                  ? state.messages
                  : state.messages
                      .where((msg) => msg.motorModel == _selectedMotor)
                      .toList();

              return Column(
                children: [
                  Expanded(
                    child: filteredMessages.isEmpty
                        ? _buildWelcomeScreen(theme)
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredMessages.length,
                            itemBuilder: (context, index) {
                              return ChatBubble(message: filteredMessages[index]);
                            },
                          ),
                  ),
                  if (_attachedImagePath != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_attachedImagePath!),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              GestureDetector(
                                onTap: _removeAttachedImage,
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Foto terlampir. Tulis deskripsi masalah pada kolom chat di bawah.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (state.aiModels.isNotEmpty) _buildModelSelector(state),
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      top: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primary, size: 22),
                            onPressed: () => _pickImage(ImageSource.gallery),
                            tooltip: 'Pilih Gambar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: AppColors.primary, size: 22),
                            onPressed: () => _pickImage(ImageSource.camera),
                            tooltip: 'Ambil Foto',
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                              maxLines: 4,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: 'Tanyakan problem motor...',
                                hintStyle: TextStyle(color: AppColors.textDisabled),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                filled: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              icon: state.isSending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              onPressed:
                                  state.isSending ? null : _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
    );
  }

  AiModel? _findSelectedModel() {
    final state = context.read<ChatCubit>().state;
    if (state is! ChatLoaded) return null;
    for (final model in state.aiModels) {
      if (model.id == _selectedModelId) return model;
    }
    return null;
  }

  Widget _buildModelSelector(ChatLoaded state) {
    final selected = state.aiModels.firstWhere(
      (model) => model.id == _selectedModelId,
      orElse: () => state.aiModels.first,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
      child: Row(
        children: [
          const Icon(
            Icons.memory_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          const Text(
            'Model AI',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showModelPicker(state.aiModels),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected.isCombo) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'COMBO',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          selected.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showModelPicker(List<AiModel> models) async {
    _modelSearchController.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = _modelSearchController.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? models
                : models
                    .where(
                      (model) =>
                          model.id.toLowerCase().contains(query) ||
                          model.label.toLowerCase().contains(query),
                    )
                    .toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Pilih Model AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _modelSearchController,
                        onChanged: (_) => setSheetState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari model...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Model tidak ditemukan.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final model = filtered[index];
                                final isSelected = model.id == _selectedModelId;
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.memory_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textDisabled,
                                    size: 20,
                                  ),
                                  title: Text(
                                    model.label,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: model.label == model.id
                                      ? null
                                      : Text(
                                          model.id,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (model.isCombo)
                                        _buildModelBadge(
                                          'COMBO',
                                          AppColors.primary,
                                        ),
                                      if (model.supportsVision == true) ...[
                                        if (model.isCombo)
                                          const SizedBox(width: 4),
                                        _buildModelBadge(
                                          'VISION',
                                          AppColors.success,
                                        ),
                                      ],
                                    ],
                                  ),
                                  onTap: () async {
                                    final navigator = Navigator.of(sheetContext);
                                    await _selectModel(model.id);
                                    navigator.pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

  }

  Widget _buildModelBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(ThemeData theme) {
    final List<Map<String, String>> starterPrompts = [
      {
        'title': 'Busi Cepat Hitam & Basah',
        'desc': 'Solusi busi Honda GL Pro sering cepat mati/basah oli.',
        'prompt': 'Busi Honda GL Pro saya cepat hitam and basah oli. Bagaimana cara mendiagnosa dan memperbaikinya?',
      },
      {
        'title': 'Konversi Platina ke CDI',
        'desc': 'Langkah ubah pengapian platina CB100 ke CDI Grand.',
        'prompt': 'Bagaimana cara konversi sistem pengapian platina ke CDI di Honda CB100 menggunakan koil/pulser Supra/Grand?',
      },
      {
        'title': 'Karburator Banjir Terus',
        'desc': 'Mengatasi bensin keluar terus dari selang pembuangan.',
        'prompt': 'Karburator motor klasik saya banjir terus keluar bensin dari selang buang. Apa penyebab dan solusinya?',
      },
      {
        'title': 'Mesin Susah Hidup Pagi',
        'desc': 'Troubleshoot motor klasik susah start saat mesin dingin.',
        'prompt': 'Motor klasik saya susah sekali dihidupkan di pagi hari saat mesin dingin. Apa saja yang perlu diperiksa?',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Halo Montir Klasik!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Asisten Pintar Anda untuk restorasi dan troubleshoot motor klasik Honda CB, GL, C70, dsb.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rekomendasi Pertanyaan:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...starterPrompts.map((item) {
            return GestureDetector(
              onTap: () {
                _messageController.text = item['prompt']!;
                _sendMessage();
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.textDisabled,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
