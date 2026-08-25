import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_repository.dart';
import '../data/models/auth_models.dart';

// Events
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class OtpRequested extends AuthEvent {
  final String phoneNumber;
  const OtpRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class OtpVerified extends AuthEvent {
  final String phoneNumber;
  final String otp;
  const OtpVerified({required this.phoneNumber, required this.otp});
  @override
  List<Object?> get props => [phoneNumber, otp];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

// States
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phoneNumber;
  const AuthOtpSent(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final SessionTokens tokens;
  const AuthAuthenticated(this.tokens);
  @override
  List<Object?> get props => [tokens.sessionId];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? phoneNumber;
  const AuthError(this.message, {this.phoneNumber});
  @override
  List<Object?> get props => [message, phoneNumber];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<OtpRequested>(_onOtpRequested);
    on<OtpVerified>(_onOtpVerified);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await _repository.isAuthenticated();
    emit(hasToken ? const AuthAuthenticated(SessionTokens(
      sessionId: '',
      accessToken: '',
      refreshToken: '',
      expiresAt: '',
    )) : const AuthUnauthenticated());
  }

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.requestOtp(event.phoneNumber);
      emit(AuthOtpSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(_errorMessage(e), phoneNumber: event.phoneNumber));
    }
  }

  Future<void> _onOtpVerified(
    OtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final tokens = await _repository.verifyOtp(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );
      emit(AuthAuthenticated(tokens));
    } catch (e) {
      emit(AuthError(_errorMessage(e), phoneNumber: event.phoneNumber));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.logout();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  String _errorMessage(Object e) {
    if (e.toString().contains('NETWORK_ERROR')) {
      return 'Internet aloqasi yo\'q';
    }
    if (e.toString().contains('RATE_LIMIT')) {
      return 'Juda ko\'p urinish. Biroz kuting';
    }
    // Backend noto'g'ri kod uchun INVALID_CREDENTIALS qaytaradi.
    if (e.toString().contains('INVALID_CREDENTIALS') ||
        e.toString().contains('INVALID_OTP')) {
      return 'Noto\'g\'ri kod kiritildi';
    }
    return 'Xatolik yuz berdi. Qayta urinib ko\'ring';
  }
}
