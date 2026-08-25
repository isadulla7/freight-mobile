import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/load_card.dart';
import '../bloc/loads_bloc.dart';
import '../data/models/load_models.dart';

class LoadsScreen extends StatefulWidget {
  const LoadsScreen({super.key});

  @override
  State<LoadsScreen> createState() => _LoadsScreenState();
}

class _LoadsScreenState extends State<LoadsScreen> {
  int _selectedFilter = 0;
  final _filters = ['Barchasi', 'Bugun', 'Ertaga'];

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Yuklar',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/loads/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: AppColors.surface,
      child: Row(
        children: [
          ..._filters.asMap().entries.map((e) {
            final isSelected = e.key == _selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(e.value),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                ),
                onSelected: (selected) {
                  setState(() => _selectedFilter = e.key);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LoadsBloc, LoadsState>(
      builder: (context, state) {
        if (state is LoadsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LoadsError) {
          return _buildErrorState(state.message);
        }
        if (state is LoadsLoaded) {
          if (state.loads.isEmpty) return _buildEmptyState();
          return _buildLoadsList(state.loads);
        }
        // LoadsInitial / LoadCreateSuccess — ma'lumot hali yo'q, lekin
        // bu "yuk yo'q" degani emas.
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLoadsList(List<LoadResponse> loads) {
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<LoadsBloc>();
        bloc.add(const LoadsRefreshRequested());
        // Spinner ma'lumot kelguncha aylanishi uchun kutamiz.
        await bloc.stream.firstWhere(
          (s) => s is LoadsLoaded || s is LoadsError,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: loads.length,
          separatorBuilder: (_, _) =>
              const Divider(indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final load = loads[index];
            return LoadCard(
              origin: load.pickupCity,
              destination: load.deliveryCity,
              weight: load.formattedWeight,
              price: load.formattedPrice,
              date: load.cargoType ?? '',
              vehicleType: load.cargoDescription,
              volume: load.formattedVolume.isNotEmpty
                  ? load.formattedVolume
                  : null,
              onTap: () => context.push('/loads/${load.loadId}'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'Hozircha yuklar topilmadi',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.read<LoadsBloc>().add(const LoadsFetchRequested()),
            child: const Text('Yangilash'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.read<LoadsBloc>().add(const LoadsFetchRequested()),
            child: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }
}
