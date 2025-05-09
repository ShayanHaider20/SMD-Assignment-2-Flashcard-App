import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/services/firebase_service.dart';
import 'deck_event.dart';
import 'deck_state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final FirebaseService firebaseService;

  DeckBloc({required this.firebaseService}) : super(DeckInitialState()) {
    on<LoadUserDecksEvent>(_onLoadUserDecks);
    on<LoadPublicDecksEvent>(_onLoadPublicDecks);
    on<CreateDeckEvent>(_onCreateDeck);
    on<UpdateDeckEvent>(_onUpdateDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<SearchDecksByTagsEvent>(_onSearchDecksByTags);
  }

  void _onLoadUserDecks(
    LoadUserDecksEvent event,
    Emitter<DeckState> emit,
  ) async {
    emit(DeckLoadingState());
    try {
      firebaseService.getUserDecks(event.userId).listen(
        (decks) {
          add(DecksLoadedEvent(decks: decks));
        },
        onError: (error) {
          add(DeckErrorEvent(message: error.toString()));
        },
      );
    } catch (e) {
      emit(DeckErrorState(message: e.toString()));
    }
  }

  void _onLoadPublicDecks(
    LoadPublicDecksEvent event,
    Emitter<DeckState> emit,
  ) async {
    emit(DeckLoadingState());
    try {
      firebaseService.getPublicDecks().listen(
        (decks) {
          add(DecksLoadedEvent(decks: decks));
        },
        onError: (error) {
          add(DeckErrorEvent(message: error.toString()));
        },
      );
    } catch (e) {
      emit(DeckErrorState(message: e.toString()));
    }
  }

  void _onCreateDeck(
    CreateDeckEvent event,
    Emitter<DeckState> emit,
  ) async {
    emit(DeckLoadingState());
    try {
      String deckId = await firebaseService.createDeck(event.deck);
      Deck? newDeck = await firebaseService.getDeck(deckId);
      if (newDeck != null) {
        emit(DeckCreatedState(deck: newDeck));
      } else {
        emit(DeckErrorState(message: 'Failed to create deck'));
      }
    } catch (e) {
      emit(DeckErrorState(message: e.toString()));
    }
  }

  void _onUpdateDeck(
    UpdateDeckEvent event,
    Emitter<DeckState> emit,
  ) async {
    emit(DeckLoadingState());
    try {
      await firebaseService.updateDeck(event.deck);
      emit(DeckUpdatedState(deck: event.deck));
    } catch (e) {
      emit(DeckErrorState(message: e.toString()));
    }
  }

  void _onDeleteDeck(
    DeleteDeckEvent event,
    Emitter<DeckState> emit,
  ) async {
    emit(DeckLoadingState());
    try {
      await firebaseService.deleteDeck(event.deckId);
      emit(DeckDeletedState(deckId: event.deckId));
    } catch (e) {
      emit(DeckErrorState(message: e.toString()));
    }
  }

  void _onSearchDecksByTags(
    SearchDecksByTagsEvent event,
    Emitter<DeckState> emit,
  ) async {
    emit(DeckLoadingState());
    try {
      firebaseService.searchDecksByTags(event.tags).listen(
        (decks) {
          add(DecksLoadedEvent(decks: decks));
        },
        onError: (error) {
          add(DeckErrorEvent(message: error.toString()));
        },
      );
    } catch (e) {
      emit(DeckErrorState(message: e.toString()));
    }
  }
}
