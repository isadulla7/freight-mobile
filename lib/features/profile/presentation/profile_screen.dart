import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../data/models/user_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProfileBloc>();
    if (bloc.state is ProfileInitial) {
      bloc.add(const ProfileFetchRequested());
    }
  }

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
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final user = state is ProfileLoaded ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileCard(user),
              const SizedBox(height: 16),
              _buildSection([
                _buildMenuItem(Icons.badge_outlined, 'Haydovchi profili',
                    onTap: () => context.push('/driver-profile')),
                _buildMenuItem(Icons.business, 'Kompaniya',
                    onTap: () => context.push('/companies')),
                _buildMenuItem(Icons.directions_car, 'Transportlar',
                    onTap: () => context.push('/vehicles')),
              ]),
              const SizedBox(height: 12),
              _buildSection([
                _buildMenuItem(
                    Icons.notifications_outlined, 'Bildirishnomalar',
                    onTap: () => context.push('/notifications')),
                _buildMenuItem(Icons.language, 'Til'),
                _buildMenuItem(Icons.help_outline, 'Yordam'),
              ]),
              const SizedBox(height: 12),
              _buildSection([
                _buildMenuItem(
                  Icons.logout,
                  'Chiqish',
                  color: AppColors.error,
                  onTap: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                    context.go('/login');
                  },
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(UserResponse? user) {
    final name = user?.displayName ?? '...';
    final initials = user?.initials ?? '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryDark,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.badgeGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.status == 'ACTIVE' ? 'Faol' : user.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.badgeGreenText,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
