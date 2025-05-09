import 'package:equatable/equatable.dart';
import 'package:micro_learning_flashcards/models/deck.dart';

abstract class DeckState extends Equatable {
  const DeckState();

  @override
  List<Object?> get props => [];
}

class DeckInitialState extends DeckState {}

class DeckLoadingState extends DeckState {}

class DecksLoadedState extends DeckState {
  final List<Deck> userDecks;
  final List<Deck> publicDecks;

  const DecksLoadedState(
    List<Deck> decks, {
    required thisdecks,
    required this.userDecks,
    required this.publicDecks,
  });

  @override
  List<Object?> get props => [userDecks, publicDecks];
}

class DeckCreatedState extends DeckState {
  final Deck deck;

  const DeckCreatedState({required this.deck});

  @override
  List<Object?> get props => [deck];
}

class DeckUpdatedState extends DeckState {
  final Deck deck;

  const DeckUpdatedState({required this.deck});

  @override
  List<Object?> get props => [deck];
}

class DeckDeletedState extends DeckState {
  final String deckId;

  const DeckDeletedState({required this.deckId});

  @override
  List<Object?> get props => [deckId];
}

class DeckErrorState extends DeckState {
  final String message;

  const DeckErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
