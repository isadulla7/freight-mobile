import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Xabarlar',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConversationTile(
            name: 'Akmal Karimov',
            initials: 'AK',
            lastMessage: "Rahmat! Yo'lda bo'laman",
            time: '09:15',
            unread: 2,
          ),
          _buildConversationTile(
            name: 'Behzod Ergashev',
            initials: 'BE',
            lastMessage: 'Yuk yuklandi, ketayapmiz',
            time: 'Kecha',
            unread: 0,
          ),
          _buildConversationTile(
            name: 'Jasur Nazarov',
            initials: 'JN',
            lastMessage: 'Lokatsiya yuborildi',
            time: '20-may',
            unread: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile({
    required String name,
    required String initials,
    required String lastMessage,
    required String time,
    required int unread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (unread > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
