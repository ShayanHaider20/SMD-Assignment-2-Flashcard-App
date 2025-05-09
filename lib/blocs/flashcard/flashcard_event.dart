import 'package:equatable/equatable.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

class AddFlashcardEvent extends FlashcardEvent {
  final String deckId;
  final Flashcard flashcard;

  const AddFlashcardEvent({
    required this.deckId,
    required this.flashcard,
  });

  @override
  List<Object?> get props => [deckId, flashcard];
}

class ReviewFlashcardEvent extends FlashcardEvent {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalCards;

  const ReviewFlashcardEvent({
    required this.flashcard,
    required this.currentIndex,
    required this.totalCards,
  });

  @override
  List<Object?> get props => [flashcard, currentIndex, totalCards];
}

class UpdateUserProgressEvent extends FlashcardEvent {
  final String userId;
  final String deckId;
  final bool isCorrect;

  const UpdateUserProgressEvent({
    required this.userId,
    required this.deckId,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [userId, deckId, isCorrect];
}

class LoadUserProgressEvent extends FlashcardEvent {
  final String userId;
  final String deckId;

  const LoadUserProgressEvent({
    required this.userId,
    required this.deckId,
  });

  @override
  List<Object?> get props => [userId, deckId];
}
