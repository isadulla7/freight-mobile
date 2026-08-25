import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/chat_repository.dart';
import '../data/models/chat_models.dart';

// Events
sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatMessagesFetchRequested extends ChatEvent {
  final String conversationId;
  const ChatMessagesFetchRequested(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class ChatMessageSent extends ChatEvent {
  final String conversationId;
  final String body;
  const ChatMessageSent({required this.conversationId, required this.body});
  @override
  List<Object?> get props => [conversationId, body];
}

// States
sealed class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageResponse> messages;
  final String conversationId;

  /// Xabar matni o'zgarib, soni o'zgarmagan holatda ham UI yangilanishi uchun.
  final int revision;

  /// Yuborish muvaffaqiyatsiz bo'lganda — suhbatni yo'qotmasdan
  /// xatoni ko'rsatish uchun.
  final String? transientError;

  const ChatLoaded({
    required this.messages,
    required this.conversationId,
    this.revision = 0,
    this.transientError,
  });

  @override
  List<Object?> get props =>
      [messages.length, conversationId, revision, transientError];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  int _revision = 0;

  ChatBloc(this._repository) : super(const ChatInitial()) {
    on<ChatMessagesFetchRequested>(_onFetch);
    on<ChatMessageSent>(_onSend);
  }

  Future<void> _onFetch(
    ChatMessagesFetchRequested event,
    Emitter<ChatState> emit,
  ) async {
    // Suhbat allaqachon yuklangan bo'lsa uni o'chirmaymiz —
    // qayta yuklashda xabarlar ko'z oldida turaveradi.
    if (state is! ChatLoaded) emit(const ChatLoading());
    try {
      final messages = await _repository.getMessages(event.conversationId);
      emit(ChatLoaded(
        messages: messages,
        conversationId: event.conversationId,
        revision: ++_revision,
      ));
    } catch (e) {
      final previous = state;
      if (previous is ChatLoaded) {
        emit(ChatLoaded(
          messages: previous.messages,
          conversationId: previous.conversationId,
          revision: ++_revision,
          transientError: 'Xabarlar yangilanmadi',
        ));
      } else {
        emit(const ChatError('Xabarlar yuklanmadi'));
      }
    }
  }

  Future<void> _onSend(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final previous = state;
    try {
      await _repository.sendMessage(event.conversationId, event.body);
      add(ChatMessagesFetchRequested(event.conversationId));
    } catch (e) {
      // Bitta xabar yuborilmagani butun suhbatni yo'q qilmasligi kerak.
      if (previous is ChatLoaded) {
        emit(ChatLoaded(
          messages: previous.messages,
          conversationId: previous.conversationId,
          revision: ++_revision,
          transientError: 'Xabar yuborilmadi',
        ));
      } else {
        emit(const ChatError('Xabar yuborilmadi'));
      }
    }
  }
}
