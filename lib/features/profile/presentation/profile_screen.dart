import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryDark,
                  child: Text(
                    'SS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sadulla Selxanov',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '+998 90 123 45 67',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection([
            _buildMenuItem(Icons.business, 'Kompaniya'),
            _buildMenuItem(Icons.directions_car, 'Transportlar'),
            _buildMenuItem(Icons.description, 'Hujjatlar'),
          ]),
          const SizedBox(height: 12),
          _buildSection([
            _buildMenuItem(Icons.notifications_outlined, 'Bildirishnomalar'),
            _buildMenuItem(Icons.language, 'Til'),
            _buildMenuItem(Icons.help_outline, 'Yordam'),
          ]),
          const SizedBox(height: 12),
          _buildSection([
            _buildMenuItem(
              Icons.logout,
              'Chiqish',
              color: AppColors.error,
              onTap: () => context.go('/login'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          return Column(
            children: [
              e.value,
              if (e.key < items.length - 1)
                const Divider(height: 0, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color ?? AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
