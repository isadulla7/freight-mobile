import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/models/shipment_models.dart';

class ShipmentDetailScreen extends StatefulWidget {
  final String shipmentId;
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentDetailScreen> createState() => _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
  ShipmentResponse? _shipment;
  List<StatusHistoryEntry> _history = [];
  bool _isLoading = true;
  bool _isOpeningChat = false;
  bool _isUpdatingStatus = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        sl.shipmentRepository.getShipment(widget.shipmentId),
        sl.shipmentRepository.getStatusHistory(widget.shipmentId),
      ]);
      if (!mounted) return;
      setState(() {
        _shipment = results[0] as ShipmentResponse;
        _history = results[1] as List<StatusHistoryEntry>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ma\'lumotlarni yuklashda xatolik';
        _isLoading = false;
      });
    }
  }

  /// Chat conversation ID shipment ID'dan farq qiladi — avval suhbatni
  /// yaratib (yoki mavjudini olib), keyin uning ID'si bilan o'tamiz.
  Future<void> _openChat() async {
    final shipment = _shipment;
    if (shipment == null) return;

    setState(() => _isOpeningChat = true);
    try {
      final participants = <Map<String, String>>[
        if (shipment.shipperUserId != null)
          {'userId': shipment.shipperUserId!, 'role': 'SHIPPER'},
        if (shipment.carrierUserId != null)
          {'userId': shipment.carrierUserId!, 'role': 'CARRIER'},
      ];

      final conversation = await sl.chatRepository.getOrCreateShipmentConversation(
        shipmentId: shipment.shipmentId,
        participants: participants,
      );

      if (!mounted) return;
      setState(() => _isOpeningChat = false);
      context.push(
        '/chat/${conversation.conversationId}',
        extra: {
          'title': 'Yetkazish #${shipment.shipmentId.substring(0, 8)}',
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isOpeningChat = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suhbatni ochib bo\'lmadi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yetkazish tafsilotlari'),
        actions: [
          if (_shipment != null)
            IconButton(
              icon: _isOpeningChat
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat_outlined),
              onPressed: _isOpeningChat ? null : _openChat,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      );
    }

    final s = _shipment!;
    final badgeType = switch (s.status) {
      'IN_TRANSIT' || 'HEADING_TO_PICKUP' || 'AT_PICKUP' || 'LOADED' =>
        BadgeType.inTransit,
      'DELIVERED' || 'COMPLETED' => BadgeType.delivered,
      'CANCELLED' => BadgeType.cancelled,
      _ => BadgeType.draft,
    };

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(s, badgeType),
          const SizedBox(height: 16),
          _buildStatusActions(s),
          _buildDetailsCard(s),
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildHistoryCard(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Backend ruxsat bergan o'tishlar (UpdateShipmentStatus.ALLOWED_TRANSITIONS).
  static const _nextStatuses = <String, List<(String, String)>>{
    'CREATED': [('IN_TRANSIT', 'Yo\'lga chiqdim'), ('CANCELLED', 'Bekor qilish')],
    'IN_TRANSIT': [('DELIVERED', 'Yetkazdim'), ('CANCELLED', 'Bekor qilish')],
    'DELIVERED': [('COMPLETED', 'Yakunlash')],
  };

  Widget _buildStatusActions(ShipmentResponse s) {
    final options = _nextStatuses[s.status];
    if (options == null || options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          for (final (status, label) in options) ...[
            Expanded(
              child: status == 'CANCELLED'
                  ? OutlinedButton(
                      onPressed: _isUpdatingStatus
                          ? null
                          : () => _updateStatus(status, label),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(label),
                    )
                  : FilledButton(
                      onPressed: _isUpdatingStatus
                          ? null
                          : () => _updateStatus(status, label),
                      child: Text(label),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(String status, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$label?'),
        content: const Text('Bu amalni qaytarib bo\'lmaydi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    setState(() => _isUpdatingStatus = true);
    try {
      await sl.shipmentRepository
          .updateStatus(widget.shipmentId, status: status);
      if (!mounted) return;
      setState(() => _isUpdatingStatus = false);
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdatingStatus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Holatni yangilab bo\'lmadi')),
      );
    }
  }

  Widget _buildInfoCard(ShipmentResponse s, BadgeType badgeType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.formattedAmount,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              StatusBadge(label: s.statusLabel, type: badgeType),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${s.shipmentId.substring(0, 8)}...',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ShipmentResponse s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _detailRow(Icons.receipt_outlined, 'Buyurtma ID', s.offerId.substring(0, 8)),
          const Divider(height: 0, indent: 52),
          _detailRow(Icons.local_shipping_outlined, 'Yuk ID', s.loadId.substring(0, 8)),
          const Divider(height: 0, indent: 52),
          _detailRow(Icons.directions_car, 'Transport ID', s.vehicleId.substring(0, 8)),
          const Divider(height: 0, indent: 52),
          _detailRow(Icons.calendar_today_outlined, 'Yaratilgan', _formatDate(s.createdAt)),
          const Divider(height: 0, indent: 52),
          _detailRow(Icons.update, 'Yangilangan', _formatDate(s.updatedAt)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Status tarixi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ..._history.map((h) {
            return ListTile(
              leading: const Icon(Icons.circle, size: 10, color: AppColors.primary),
              title: Text(_statusLabel(h.newStatus), style: const TextStyle(fontSize: 14)),
              subtitle: Text(
                _formatDate(h.changedAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'CREATED' => 'Yaratildi',
        'DRIVER_ASSIGNED' => 'Haydovchi tayinlandi',
        'HEADING_TO_PICKUP' => 'Yuklash joyiga ketmoqda',
        'AT_PICKUP' => 'Yuklash joyida',
        'LOADED' => 'Yuklandi',
        'IN_TRANSIT' => "Yo'lda",
        'DELIVERED' => 'Yetkazildi',
        'COMPLETED' => 'Yakunlandi',
        'CANCELLED' => 'Bekor qilindi',
        _ => status,
      };

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
