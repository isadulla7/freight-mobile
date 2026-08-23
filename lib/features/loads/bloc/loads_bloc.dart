import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/load_repository.dart';
import '../data/models/load_models.dart';

// Events
sealed class LoadsEvent extends Equatable {
  const LoadsEvent();
  @override
  List<Object?> get props => [];
}

class LoadsFetchRequested extends LoadsEvent {
  final double latitude;
  final double longitude;
  final double radiusMeters;
  const LoadsFetchRequested({
    this.latitude = 41.2995,
    this.longitude = 69.2401,
    this.radiusMeters = 100000,
  });
  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}

class LoadsRefreshRequested extends LoadsEvent {
  const LoadsRefreshRequested();
}

class LoadCreateRequested extends LoadsEvent {
  final CreateLoadPayload payload;
  const LoadCreateRequested(this.payload);
  @override
  List<Object?> get props => [payload];
}

// States
sealed class LoadsState extends Equatable {
  const LoadsState();
  @override
  List<Object?> get props => [];
}

class LoadsInitial extends LoadsState {
  const LoadsInitial();
}

class LoadsLoading extends LoadsState {
  const LoadsLoading();
}

class LoadsLoaded extends LoadsState {
  final List<LoadResponse> loads;
  const LoadsLoaded(this.loads);
  @override
  List<Object?> get props => [loads.length];
}

class LoadsError extends LoadsState {
  final String message;
  const LoadsError(this.message);
  @override
  List<Object?> get props => [message];
}

class LoadCreateSuccess extends LoadsState {
  final String loadId;
  const LoadCreateSuccess(this.loadId);
  @override
  List<Object?> get props => [loadId];
}

// BLoC
class LoadsBloc extends Bloc<LoadsEvent, LoadsState> {
  final LoadRepository _repository;
  double _lastLat = 41.2995;
  double _lastLng = 69.2401;
  double _lastRadius = 100000;

  LoadsBloc(this._repository) : super(const LoadsInitial()) {
    on<LoadsFetchRequested>(_onFetch);
    on<LoadsRefreshRequested>(_onRefresh);
    on<LoadCreateRequested>(_onCreate);
  }

  Future<void> _onFetch(
    LoadsFetchRequested event,
    Emitter<LoadsState> emit,
  ) async {
    emit(const LoadsLoading());
    _lastLat = event.latitude;
    _lastLng = event.longitude;
    _lastRadius = event.radiusMeters;
    try {
      final loads = await _repository.searchAndFetchLoads(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusMeters: event.radiusMeters,
      );
      emit(LoadsLoaded(loads));
    } catch (e) {
      emit(LoadsError('Yuklar yuklanmadi: $e'));
    }
  }

  Future<void> _onRefresh(
    LoadsRefreshRequested event,
    Emitter<LoadsState> emit,
  ) async {
    try {
      final loads = await _repository.searchAndFetchLoads(
        latitude: _lastLat,
        longitude: _lastLng,
        radiusMeters: _lastRadius,
      );
      emit(LoadsLoaded(loads));
    } catch (e) {
      emit(LoadsError('Yuklar yuklanmadi: $e'));
    }
  }

  Future<void> _onCreate(
    LoadCreateRequested event,
    Emitter<LoadsState> emit,
  ) async {
    emit(const LoadsLoading());
    try {
      final loadId = await _repository.createLoad(event.payload);
      emit(LoadCreateSuccess(loadId));
    } catch (e) {
      emit(LoadsError('Yuk yaratishda xatolik: $e'));
    }
  }
}
