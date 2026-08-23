import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/user_repository.dart';
import '../data/models/user_models.dart';

// Events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileFetchRequested extends ProfileEvent {
  const ProfileFetchRequested();
}

// States
sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserResponse user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user.userId];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileInitial()) {
    on<ProfileFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _repository.getMe();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(const ProfileError('Profil yuklanmadi'));
    }
  }
}
