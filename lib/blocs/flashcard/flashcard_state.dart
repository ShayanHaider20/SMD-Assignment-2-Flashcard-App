import 'package:equatable/equatable.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

abstract class FlashcardState extends Equatable {
  const FlashcardState();

  @override
  List<Object?> get props => [];
}

class FlashcardInitialState extends FlashcardState {}

class FlashcardLoadingState extends FlashcardState {}

class FlashcardAddedState extends FlashcardState {
  final Flashcard flashcard;

  const FlashcardAddedState({required this.flashcard});

  @override
  List<Object?> get props => [flashcard];
}

class FlashcardReviewingState extends FlashcardState {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalCards;

  const FlashcardReviewingState({
    required this.flashcard,
    required this.currentIndex,
    required this.totalCards,
  });

  @override
  List<Object?> get props => [flashcard, currentIndex, totalCards];
}

class UserProgressUpdatedState extends FlashcardState {
  final bool isCorrect;

  const UserProgressUpdatedState({required this.isCorrect});

  @override
  List<Object?> get props => [isCorrect];
}

class UserProgressLoadedState extends FlashcardState {
  final int correctAnswers;
  final int incorrectAnswers;

  const UserProgressLoadedState({
    required this.correctAnswers,
    required this.incorrectAnswers,
  });

  @override
  List<Object?> get props => [correctAnswers, incorrectAnswers];
}

class FlashcardErrorState extends FlashcardState {
  final String message;

  const FlashcardErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
