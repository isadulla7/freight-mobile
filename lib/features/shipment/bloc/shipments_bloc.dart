import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/shipment_repository.dart';
import '../data/models/shipment_models.dart';

// Events
sealed class ShipmentsEvent extends Equatable {
  const ShipmentsEvent();
  @override
  List<Object?> get props => [];
}

class ShipmentsFetchRequested extends ShipmentsEvent {
  const ShipmentsFetchRequested();
}

class ShipmentStatusUpdateRequested extends ShipmentsEvent {
  final String shipmentId;
  final String status;
  const ShipmentStatusUpdateRequested({
    required this.shipmentId,
    required this.status,
  });
  @override
  List<Object?> get props => [shipmentId, status];
}

/// Logout'da chaqiriladi.
class ShipmentsReset extends ShipmentsEvent {
  const ShipmentsReset();
}

// States
sealed class ShipmentsState extends Equatable {
  const ShipmentsState();
  @override
  List<Object?> get props => [];
}

class ShipmentsInitial extends ShipmentsState {
  const ShipmentsInitial();
}

class ShipmentsLoading extends ShipmentsState {
  const ShipmentsLoading();
}

class ShipmentsLoaded extends ShipmentsState {
  final List<ShipmentResponse> shipments;

  /// Har yuklashda ortadi — ro'yxat uzunligi o'zgarmagan holatda ham
  /// (status yangilanganda) UI qayta chizilishini kafolatlaydi.
  final int revision;

  const ShipmentsLoaded(this.shipments, {this.revision = 0});
  @override
  List<Object?> get props => [shipments.length, revision];
}

class ShipmentsError extends ShipmentsState {
  final String message;
  const ShipmentsError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ShipmentsBloc extends Bloc<ShipmentsEvent, ShipmentsState> {
  final ShipmentRepository _repository;
  int _revision = 0;

  ShipmentsBloc(this._repository) : super(const ShipmentsInitial()) {
    on<ShipmentsFetchRequested>(_onFetch);
    on<ShipmentStatusUpdateRequested>(_onStatusUpdate);
    on<ShipmentsReset>(_onReset);
  }

  Future<void> _onFetch(
    ShipmentsFetchRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(const ShipmentsLoading());
    try {
      final shipments = await _repository.getMyShipments();
      emit(ShipmentsLoaded(shipments, revision: ++_revision));
    } catch (e) {
      emit(const ShipmentsError('Yetkazishlar yuklanmadi'));
    }
  }

  Future<void> _onStatusUpdate(
    ShipmentStatusUpdateRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    final previous = state;
    try {
      await _repository.updateStatus(event.shipmentId, status: event.status);
      final shipments = await _repository.getMyShipments();
      emit(ShipmentsLoaded(shipments, revision: ++_revision));
    } catch (e) {
      emit(const ShipmentsError('Holatni yangilashda xatolik'));
      // Xatolik butun ro'yxatni yo'q qilmasligi kerak — oldingi
      // yuklangan ma'lumotni qaytaramiz.
      if (previous is ShipmentsLoaded) {
        emit(ShipmentsLoaded(previous.shipments, revision: ++_revision));
      }
    }
  }

  void _onReset(ShipmentsReset event, Emitter<ShipmentsState> emit) {
    _revision = 0;
    emit(const ShipmentsInitial());
  }
}
