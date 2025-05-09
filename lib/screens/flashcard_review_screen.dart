import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/blocs/flashcard/flashcard_bloc.dart';
import 'package:micro_learning_flashcards/blocs/flashcard/flashcard_event.dart';
import 'package:micro_learning_flashcards/blocs/flashcard/flashcard_state.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

class FlashcardReviewScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardReviewScreen({
    Key? key,
    required this.deck,
  }) : super(key: key);

  @override
  State<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends State<FlashcardReviewScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  List<Flashcard> _flashcardsToReview = [];
  int _correctCount = 0;
  int _incorrectCount = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeReview();

    // Load user progress if user is authenticated
    if (_auth.currentUser != null) {
      context.read<FlashcardBloc>().add(
            LoadUserProgressEvent(
              userId: _auth.currentUser!.uid,
              deckId: widget.deck.id,
            ),
          );
    }
  }

  void _initializeReview() {
    // For simplicity, we'll review all cards
    // In a more advanced implementation, you could filter by due date
    setState(() {
      _flashcardsToReview = List.from(widget.deck.flashcards);
      _flashcardsToReview.shuffle(); // Randomize the order
      _currentIndex = 0;
      _showAnswer = false;
      _correctCount = 0;
      _incorrectCount = 0;
    });

    // Start with the first card
    if (_flashcardsToReview.isNotEmpty) {
      context.read<FlashcardBloc>().add(
            ReviewFlashcardEvent(
              flashcard: _flashcardsToReview[0],
              currentIndex: 1,
              totalCards: _flashcardsToReview.length,
            ),
          );
    }
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _recordAnswer(bool isCorrect) {
    // Record the answer
    if (isCorrect) {
      setState(() {
        _correctCount++;
      });
    } else {
      setState(() {
        _incorrectCount++;
      });
    }

    // Update user progress in Firebase if user is authenticated
    if (_auth.currentUser != null) {
      context.read<FlashcardBloc>().add(
            UpdateUserProgressEvent(
              userId: _auth.currentUser!.uid,
              deckId: widget.deck.id,
              isCorrect: isCorrect,
            ),
          );
    }

    // Move to the next card or finish review
    if (_currentIndex < _flashcardsToReview.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });

      // Update the current flashcard in the bloc
      context.read<FlashcardBloc>().add(
            ReviewFlashcardEvent(
              flashcard: _flashcardsToReview[_currentIndex],
              currentIndex: _currentIndex + 1,
              totalCards: _flashcardsToReview.length,
            ),
          );
    } else {
      // Show summary when all cards are reviewed
      _showSummaryDialog();
    }
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Review Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You have completed reviewing this deck!'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(height: 4),
                      Text(
                        '$_correctCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Correct'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red),
                      const SizedBox(height: 4),
                      Text(
                        '$_incorrectCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Incorrect'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.analytics, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(
                        '${(_correctCount / (_correctCount + _incorrectCount) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Accuracy'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _initializeReview(); // Restart review
              },
              child: const Text('Review Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviewing: ${widget.deck.title}'),
      ),
      body: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (_flashcardsToReview.isEmpty) {
            return const Center(
              child: Text('No flashcards to review'),
            );
          }

          if (state is UserProgressLoadedState) {
            // If progress is loaded, we can show it somewhere if needed
            // Currently just keeping track in the state
          }

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _flashcardsToReview.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Card ${_currentIndex + 1} of ${_flashcardsToReview.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Flashcard display
              Expanded(
                child: GestureDetector(
                  onTap: _toggleAnswer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showAnswer ? 'Answer' : 'Question',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showAnswer
                                  ? _flashcardsToReview[_currentIndex].answer
                                  : _flashcardsToReview[_currentIndex].question,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            const Text('Tap to view the other side'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Feedback buttons
              if (_showAnswer)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _recordAnswer(false),
                        icon: const Icon(Icons.thumb_down, color: Colors.white),
                        label: const Text('Incorrect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _recordAnswer(true),
                        icon: const Icon(Icons.thumb_up, color: Colors.white),
                        label: const Text('Correct'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
