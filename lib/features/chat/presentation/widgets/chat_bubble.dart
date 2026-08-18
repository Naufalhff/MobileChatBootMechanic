import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatBubbleMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? AppColors.userBubble : AppColors.aiBubble;
    final textColor = isUser ? Colors.white : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.motorcycle_rounded, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    message.motorModel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.build_rounded, 
                      size: 10, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Pocket Mechanic',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
              ),
              border: isUser
                  ? null
                  : Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: isUser
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imagePath != null &&
                    message.imagePath!.isNotEmpty) ...[
                  _buildImageWidget(message.imagePath!),
                  const SizedBox(height: 8),
                ],

                if (message.isTyping)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Menganalisis manual book...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else
                  MarkdownBody(
                    data: message.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      h1: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                      h2: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      h3: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                      listBullet: TextStyle(color: textColor, fontSize: 14.5),
                    ),
                  ),

                if (!isUser && message.normalizedText != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.g_translate_rounded,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Glosarium: "${message.normalizedText}"',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isUser && !message.isTyping)
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jawaban disalin ke papan klip'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.copy_all_rounded,
                          size: 16,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      )
                    else
                      const SizedBox(),
                    Text(
                      DateFormat('HH:mm').format(message.time),
                      style: TextStyle(
                        color: (isUser ? Colors.white : AppColors.textSecondary).withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http') ||
        path.startsWith('/media') ||
        path.startsWith('media')) {
      final imageUrl = path.startsWith('http')
          ? path
          : '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/${path.startsWith('/') ? path.substring(1) : path}';
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.broken_image_rounded, color: Colors.white54),
              ),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.broken_image_rounded, color: Colors.white54),
              ),
            );
          },
        ),
      );
    }
  }
}
