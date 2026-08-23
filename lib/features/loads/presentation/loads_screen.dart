import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/load_card.dart';

class LoadsScreen extends StatefulWidget {
  const LoadsScreen({super.key});

  @override
  State<LoadsScreen> createState() => _LoadsScreenState();
}

class _LoadsScreenState extends State<LoadsScreen> {
  int _selectedFilter = 0;
  final _filters = ['Barchasi', 'Bugun', 'Ertaga'];

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
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildLoadsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
          ActionChip(
            avatar: const Icon(Icons.tune, size: 16),
            label: const Text('Filtrlar'),
            onPressed: () {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadsList() {
    final loads = [
      ('Toshkent', 'Samarqand', '12 t', '4 500 000 UZS', 'Bugun, 14:00', 'Tentli yuk', '82 m³'),
      ('Toshkent', "Farg'ona", '8 t', '3 200 000 UZS', 'Bugun, 16:30', 'Yopiq furgon', '45 m³'),
      ('Toshkent', 'Buxoro', '20 t', '6 800 000 UZS', 'Ertaga, 09:00', 'Tentli yuk', '120 m³'),
      ('Navoiy', 'Toshkent', '15 t', '5 100 000 UZS', 'Ertaga, 11:00', 'Yopiq furgon', '60 m³'),
      ('Andijon', 'Toshkent', '10 t', '3 000 000 UZS', '23-may, 10:00', null, null),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: loads.length,
        separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final l = loads[index];
          return LoadCard(
            origin: l.$1,
            destination: l.$2,
            weight: l.$3,
            price: l.$4,
            date: l.$5,
            vehicleType: l.$6,
            volume: l.$7,
            showHeart: true,
            onTap: () => context.push('/loads/${index + 1}'),
          );
        },
      ),
    );
  }
}
