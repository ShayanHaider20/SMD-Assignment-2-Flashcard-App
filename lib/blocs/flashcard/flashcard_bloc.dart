import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/services/firebase_service.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final FirebaseService firebaseService;

  FlashcardBloc({required this.firebaseService})
      : super(FlashcardInitialState()) {
    on<AddFlashcardEvent>(_onAddFlashcard);
    on<ReviewFlashcardEvent>(_onReviewFlashcard);
    on<UpdateUserProgressEvent>(_onUpdateUserProgress);
    on<LoadUserProgressEvent>(_onLoadUserProgress);
  }

  void _onAddFlashcard(
    AddFlashcardEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoadingState());
    try {
      await firebaseService.addFlashcardToDeck(event.deckId, event.flashcard);
      emit(FlashcardAddedState(flashcard: event.flashcard));
    } catch (e) {
      emit(FlashcardErrorState(message: e.toString()));
    }
  }

  void _onReviewFlashcard(
    ReviewFlashcardEvent event,
    Emitter<FlashcardState> emit,
  ) {
    emit(FlashcardReviewingState(
      flashcard: event.flashcard,
      currentIndex: event.currentIndex,
      totalCards: event.totalCards,
    ));
  }

  void _onUpdateUserProgress(
    UpdateUserProgressEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    try {
      await firebaseService.updateUserProgress(
        event.userId,
        event.deckId,
        event.isCorrect,
      );
      emit(UserProgressUpdatedState(isCorrect: event.isCorrect));
    } catch (e) {
      emit(FlashcardErrorState(message: e.toString()));
    }
  }

  void _onLoadUserProgress(
    LoadUserProgressEvent event,
    Emitter<FlashcardState> emit,
  ) async {
    emit(FlashcardLoadingState());
    try {
      Map<String, dynamic> progress = await firebaseService.getUserProgress(
        event.userId,
        event.deckId,
      );
      emit(UserProgressLoadedState(
        correctAnswers: progress['correctAnswers'] ?? 0,
        incorrectAnswers: progress['incorrectAnswers'] ?? 0,
      ));
    } catch (e) {
      emit(FlashcardErrorState(message: e.toString()));
    }
  }
}
