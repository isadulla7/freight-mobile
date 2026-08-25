import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../loads/data/load_repository.dart';
import '../../loads/data/models/load_models.dart';
import '../../offers/data/offer_repository.dart';
import '../../offers/data/models/offer_models.dart';
import '../../shipment/data/shipment_repository.dart';

// Events
sealed class LoadDetailEvent extends Equatable {
  const LoadDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadDetailFetchRequested extends LoadDetailEvent {
  final String loadId;
  const LoadDetailFetchRequested(this.loadId);
  @override
  List<Object?> get props => [loadId];
}

class LoadDetailOfferSubmitted extends LoadDetailEvent {
  final CreateOfferPayload payload;
  const LoadDetailOfferSubmitted(this.payload);
  @override
  List<Object?> get props => [payload.loadId];
}

class LoadDetailOfferAccepted extends LoadDetailEvent {
  final String offerId;
  final int expectedLoadVersion;
  const LoadDetailOfferAccepted({
    required this.offerId,
    required this.expectedLoadVersion,
  });
  @override
  List<Object?> get props => [offerId];
}

class LoadDetailOfferRejected extends LoadDetailEvent {
  final String offerId;
  const LoadDetailOfferRejected(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

// States
sealed class LoadDetailState extends Equatable {
  const LoadDetailState();
  @override
  List<Object?> get props => [];
}

class LoadDetailInitial extends LoadDetailState {
  const LoadDetailInitial();
}

class LoadDetailLoading extends LoadDetailState {
  const LoadDetailLoading();
}

class LoadDetailLoaded extends LoadDetailState {
  final LoadResponse load;
  final List<OfferResponse> offers;

  /// Taklif statusi o'zgarganda (soni o'zgarmasa ham) UI yangilanishi uchun.
  final int revision;

  /// Amal bajarilmaganda sahifani yo'qotmasdan xato ko'rsatish uchun.
  final String? transientError;

  const LoadDetailLoaded({
    required this.load,
    required this.offers,
    this.revision = 0,
    this.transientError,
  });

  @override
  List<Object?> get props =>
      [load.loadId, load.status, offers.length, revision, transientError];
}

class LoadDetailError extends LoadDetailState {
  final String message;
  const LoadDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

class LoadDetailOfferSuccess extends LoadDetailState {
  final String offerId;
  const LoadDetailOfferSuccess(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

// BLoC
class LoadDetailBloc extends Bloc<LoadDetailEvent, LoadDetailState> {
  final LoadRepository _loadRepo;
  final OfferRepository _offerRepo;
  final ShipmentRepository _shipmentRepo;
  int _revision = 0;

  LoadDetailBloc(this._loadRepo, this._offerRepo, this._shipmentRepo)
      : super(const LoadDetailInitial()) {
    on<LoadDetailFetchRequested>(_onFetch);
    on<LoadDetailOfferSubmitted>(_onOfferSubmit);
    on<LoadDetailOfferAccepted>(_onOfferAccept);
    on<LoadDetailOfferRejected>(_onOfferReject);
  }

  Future<void> _onFetch(
    LoadDetailFetchRequested event,
    Emitter<LoadDetailState> emit,
  ) async {
    if (state is! LoadDetailLoaded) emit(const LoadDetailLoading());
    await _reload(event.loadId, emit);
  }

  Future<void> _reload(String loadId, Emitter<LoadDetailState> emit) async {
    try {
      final load = await _loadRepo.getLoad(loadId);
      List<OfferResponse> offers = [];
      if (load.status == 'PUBLISHED') {
        try {
          offers = await _offerRepo.getOffersForLoad(loadId);
        } catch (_) {
          // Takliflar yuklanmasa ham yuk tafsilotlarini ko'rsatamiz.
        }
      }
      emit(LoadDetailLoaded(
        load: load,
        offers: offers,
        revision: ++_revision,
      ));
    } catch (e) {
      emit(const LoadDetailError('Yuk ma\'lumotlari yuklanmadi'));
    }
  }

  Future<void> _onOfferSubmit(
    LoadDetailOfferSubmitted event,
    Emitter<LoadDetailState> emit,
  ) async {
    final previous = state;
    try {
      final offerId = await _offerRepo.createOffer(event.payload);
      emit(LoadDetailOfferSuccess(offerId));
      await _reload(event.payload.loadId, emit);
    } catch (e) {
      // Taklif yuborilmagani butun sahifani yo'q qilmasligi kerak.
      if (previous is LoadDetailLoaded) {
        emit(LoadDetailLoaded(
          load: previous.load,
          offers: previous.offers,
          revision: ++_revision,
          transientError: 'Taklif yuborishda xatolik',
        ));
      } else {
        emit(const LoadDetailError('Taklif yuborishda xatolik'));
      }
    }
  }

  Future<void> _onOfferAccept(
    LoadDetailOfferAccepted event,
    Emitter<LoadDetailState> emit,
  ) async {
    final previous = state;
    if (previous is! LoadDetailLoaded) return;

    final offer = previous.offers
        .where((o) => o.offerId == event.offerId)
        .firstOrNull;
    if (offer == null) return;

    try {
      await _offerRepo.acceptOffer(event.offerId, event.expectedLoadVersion);

      // Taklifni qabul qilish o'zi yetkazish yozuvini yaratmaydi —
      // uni alohida yaratmasak, "Yetkazishlar" bo'sh qolaveradi.
      await _shipmentRepo.createShipment(
        offerId: offer.offerId,
        loadId: previous.load.loadId,
        driverProfileId: offer.driverProfileId,
        vehicleId: offer.vehicleId,
        acceptedAmount: offer.amount,
        acceptedCurrency: offer.currency ?? 'UZS',
        shipperUserId: previous.load.ownerUserId,
        carrierUserId: offer.offererUserId,
      );

      await _reload(previous.load.loadId, emit);
    } catch (e) {
      emit(LoadDetailLoaded(
        load: previous.load,
        offers: previous.offers,
        revision: ++_revision,
        transientError: 'Taklifni qabul qilishda xatolik',
      ));
    }
  }

  Future<void> _onOfferReject(
    LoadDetailOfferRejected event,
    Emitter<LoadDetailState> emit,
  ) async {
    final previous = state;
    if (previous is! LoadDetailLoaded) return;
    try {
      await _offerRepo.rejectOffer(event.offerId);
      await _reload(previous.load.loadId, emit);
    } catch (e) {
      emit(LoadDetailLoaded(
        load: previous.load,
        offers: previous.offers,
        revision: ++_revision,
        transientError: 'Taklifni rad etishda xatolik',
      ));
    }
  }
}
