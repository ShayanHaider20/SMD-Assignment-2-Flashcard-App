import 'package:equatable/equatable.dart';
import 'package:micro_learning_flashcards/models/deck.dart';

abstract class DeckEvent extends Equatable {
  const DeckEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserDecksEvent extends DeckEvent {
  final String userId;

  const LoadUserDecksEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadPublicDecksEvent extends DeckEvent {}

class DecksLoadedEvent extends DeckEvent {
  final List<Deck> decks;

  const DecksLoadedEvent({required this.decks});

  @override
  List<Object?> get props => [decks];
}

class CreateDeckEvent extends DeckEvent {
  final Deck deck;

  const CreateDeckEvent({required this.deck});

  @override
  List<Object?> get props => [deck];
}

class UpdateDeckEvent extends DeckEvent {
  final Deck deck;

  const UpdateDeckEvent({required this.deck});

  @override
  List<Object?> get props => [deck];
}

class DeleteDeckEvent extends DeckEvent {
  final String deckId;

  const DeleteDeckEvent({required this.deckId});

  @override
  List<Object?> get props => [deckId];
}

class SearchDecksByTagsEvent extends DeckEvent {
  final List<String> tags;

  const SearchDecksByTagsEvent({required this.tags});

  @override
  List<Object?> get props => [tags];
}

class DeckErrorEvent extends DeckEvent {
  final String message;

  const DeckErrorEvent({required this.message});

  @override
  List<Object?> get props => [message];
}
