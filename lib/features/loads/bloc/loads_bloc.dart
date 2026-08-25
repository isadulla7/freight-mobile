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

/// Logout'da chaqiriladi — keyingi foydalanuvchi oldingisining
/// yuklarini ko'rmasligi uchun.
class LoadsReset extends LoadsEvent {
  const LoadsReset();
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

  /// Har bir yuklashda ortadi. Ro'yxat uzunligi o'zgarmagan holatda ham
  /// (masalan, narx yoki status yangilanganda) yangi state emit qilinishini
  /// kafolatlaydi — aks holda Equatable uni bir xil deb tashlab yuboradi.
  final int revision;

  const LoadsLoaded(this.loads, {this.revision = 0});
  @override
  List<Object?> get props => [loads.length, revision];
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
  int _revision = 0;

  LoadsBloc(this._repository) : super(const LoadsInitial()) {
    on<LoadsFetchRequested>(_onFetch);
    on<LoadsRefreshRequested>(_onRefresh);
    on<LoadCreateRequested>(_onCreate);
    on<LoadsReset>(_onReset);
  }

  Future<void> _onFetch(
    LoadsFetchRequested event,
    Emitter<LoadsState> emit,
  ) async {
    emit(const LoadsLoading());
    _lastLat = event.latitude;
    _lastLng = event.longitude;
    _lastRadius = event.radiusMeters;
    await _load(emit);
  }

  Future<void> _onRefresh(
    LoadsRefreshRequested event,
    Emitter<LoadsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<LoadsState> emit) async {
    try {
      final loads = await _repository.searchAndFetchLoads(
        latitude: _lastLat,
        longitude: _lastLng,
        radiusMeters: _lastRadius,
      );
      emit(LoadsLoaded(loads, revision: ++_revision));
    } catch (e) {
      emit(LoadsError(_message(e, 'Yuklar yuklanmadi')));
    }
  }

  Future<void> _onCreate(
    LoadCreateRequested event,
    Emitter<LoadsState> emit,
  ) async {
    emit(const LoadsLoading());
    try {
      final loadId = await _repository.createLoad(event.payload);
      // Yuk DRAFT holatida yaratiladi — publish qilinmasa qidiruvda
      // ko'rinmaydi va unga taklif berib bo'lmaydi.
      await _repository.publishLoad(loadId);
      emit(LoadCreateSuccess(loadId));
      // Ro'yxatni yangilaymiz, aks holda LoadCreateSuccess state'i
      // ekranda "yuk yo'q" bo'lib qoladi.
      await _load(emit);
    } catch (e) {
      emit(LoadsError(_message(e, 'Yuk yaratishda xatolik')));
    }
  }

  void _onReset(LoadsReset event, Emitter<LoadsState> emit) {
    _revision = 0;
    emit(const LoadsInitial());
  }

  /// Foydalanuvchiga xom `DioException` matnini ko'rsatmaslik uchun.
  String _message(Object e, String fallback) {
    final text = e.toString();
    if (text.contains('SocketException') ||
        text.contains('connection error') ||
        text.contains('Connection refused')) {
      return 'Internet aloqasi yo\'q';
    }
    return fallback;
  }
}
