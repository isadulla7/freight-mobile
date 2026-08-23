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
  const ChatLoaded({required this.messages, required this.conversationId});
  @override
  List<Object?> get props => [messages.length, conversationId];
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

  ChatBloc(this._repository) : super(const ChatInitial()) {
    on<ChatMessagesFetchRequested>(_onFetch);
    on<ChatMessageSent>(_onSend);
  }

  Future<void> _onFetch(
    ChatMessagesFetchRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final messages = await _repository.getMessages(event.conversationId);
      emit(ChatLoaded(
        messages: messages,
        conversationId: event.conversationId,
      ));
    } catch (e) {
      emit(const ChatError('Xabarlar yuklanmadi'));
    }
  }

  Future<void> _onSend(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _repository.sendMessage(event.conversationId, event.body);
      add(ChatMessagesFetchRequested(event.conversationId));
    } catch (e) {
      emit(const ChatError('Xabar yuborilmadi'));
    }
  }
}
