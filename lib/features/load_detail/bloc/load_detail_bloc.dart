import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../loads/data/load_repository.dart';
import '../../loads/data/models/load_models.dart';
import '../../offers/data/offer_repository.dart';
import '../../offers/data/models/offer_models.dart';

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
  const LoadDetailLoaded({required this.load, required this.offers});
  @override
  List<Object?> get props => [load.loadId, offers.length];
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

  LoadDetailBloc(this._loadRepo, this._offerRepo)
      : super(const LoadDetailInitial()) {
    on<LoadDetailFetchRequested>(_onFetch);
    on<LoadDetailOfferSubmitted>(_onOfferSubmit);
    on<LoadDetailOfferAccepted>(_onOfferAccept);
  }

  Future<void> _onFetch(
    LoadDetailFetchRequested event,
    Emitter<LoadDetailState> emit,
  ) async {
    emit(const LoadDetailLoading());
    try {
      final load = await _loadRepo.getLoad(event.loadId);
      List<OfferResponse> offers = [];
      if (load.status == 'PUBLISHED') {
        try {
          offers = await _offerRepo.getOffersForLoad(event.loadId);
        } catch (_) {}
      }
      emit(LoadDetailLoaded(load: load, offers: offers));
    } catch (e) {
      emit(LoadDetailError('Yuk ma\'lumotlari yuklanmadi'));
    }
  }

  Future<void> _onOfferSubmit(
    LoadDetailOfferSubmitted event,
    Emitter<LoadDetailState> emit,
  ) async {
    try {
      final offerId = await _offerRepo.createOffer(event.payload);
      emit(LoadDetailOfferSuccess(offerId));
    } catch (e) {
      emit(const LoadDetailError('Taklif yuborishda xatolik'));
    }
  }

  Future<void> _onOfferAccept(
    LoadDetailOfferAccepted event,
    Emitter<LoadDetailState> emit,
  ) async {
    try {
      await _offerRepo.acceptOffer(event.offerId, event.expectedLoadVersion);
    } catch (e) {
      emit(const LoadDetailError('Taklifni qabul qilishda xatolik'));
    }
  }
}
