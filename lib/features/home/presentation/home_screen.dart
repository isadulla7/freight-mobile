import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/load_card.dart';
import '../../loads/bloc/loads_bloc.dart';
import '../../loads/data/models/load_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<LoadsBloc>();
    if (bloc.state is LoadsInitial) {
      bloc.add(const LoadsFetchRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: _buildContent(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 32,
      ),
      decoration: const BoxDecoration(color: AppColors.primaryDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Freight',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Text(
            'Bosh sahifa',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined,
                    color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  "Toshkent, O'zbekiston",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            _buildLoadsSection(context),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildBanner(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yaqin atrofdagi yuklar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/loads'),
                  child: const Text('Barchasi'),
                ),
              ],
            ),
          ),
          BlocBuilder<LoadsBloc, LoadsState>(
            builder: (context, state) {
              if (state is LoadsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is LoadsLoaded && state.loads.isNotEmpty) {
                final loads = state.loads.take(3).toList();
                return _buildLoadsList(context, loads);
              }
              if (state is LoadsError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Yuklarni yuklashda xatolik',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context
                            .read<LoadsBloc>()
                            .add(const LoadsFetchRequested()),
                        child: const Text('Qayta urinish'),
                      ),
                    ],
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Hozircha yuklar mavjud emas',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadsList(BuildContext context, List<LoadResponse> loads) {
    return Column(
      children: loads.asMap().entries.map((entry) {
        final load = entry.value;
        return Column(
          children: [
            LoadCard(
              origin: load.pickupCity,
              destination: load.deliveryCity,
              weight: load.formattedWeight.isNotEmpty
                  ? load.formattedWeight
                  : '-',
              price: load.formattedPrice,
              date: '',
              onTap: () => context.push('/loads/${load.loadId}'),
            ),
            if (entry.key < loads.length - 1)
              const Divider(indent: 16, endIndent: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      ('Yuk qidirish', Icons.search, () => context.go('/loads')),
      ('Yuk joylash', Icons.add_circle_outline,
          () => context.push('/loads/create')),
      ('Yetkazish', Icons.local_shipping_outlined,
          () => context.go('/shipments')),
      ('Profil', Icons.person_outline, () => context.go('/profile')),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tezkor amallar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((a) {
              return GestureDetector(
                onTap: a.$3,
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.divider, width: 0.5),
                      ),
                      child: Icon(a.$2, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ishonchli hamkorlar bilan xavfsiz yetkazib bering',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tasdiqlangan yuk jo\'natuvchilar va tashuvchilar',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    );
  }
}
