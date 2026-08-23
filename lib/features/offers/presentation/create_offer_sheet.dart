import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../load_detail/bloc/load_detail_bloc.dart';
import '../data/models/offer_models.dart';

class CreateOfferSheet extends StatefulWidget {
  final String loadId;
  const CreateOfferSheet({super.key, required this.loadId});

  @override
  State<CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<CreateOfferSheet> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount =
        int.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d]'), ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Narxni kiriting')),
      );
      return;
    }

    final payload = CreateOfferPayload(
      loadId: widget.loadId,
      driverProfileId: '',
      vehicleId: '',
      amount: amount,
      currency: 'UZS',
      message: _messageController.text.trim().isNotEmpty
          ? _messageController.text.trim()
          : null,
    );

    context.read<LoadDetailBloc>().add(LoadDetailOfferSubmitted(payload));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Taklif berish',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Narx (UZS)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Xabar (ixtiyoriy)',
              prefixIcon: Icon(Icons.message_outlined),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Taklif yuborish'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
