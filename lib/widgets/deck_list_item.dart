import 'package:flutter/material.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/widgets/progress_bar_widget.dart';

class DeckListItem extends StatelessWidget {
  final Deck deck;
  final double progress;
  final VoidCallback onTap;

  const DeckListItem({
    Key? key,
    required this.deck,
    required this.progress,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dueCount = deck.getDueFlashcardsCount();
    final totalCards = deck.flashcards.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deck.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: deck.isPublic
                          ? Colors.green.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      deck.isPublic ? 'Public' : 'Private',
                      style: TextStyle(
                        fontSize: 12,
                        color: deck.isPublic
                            ? Colors.green[700]
                            : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                deck.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cards: $totalCards',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Due: $dueCount',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          dueCount > 0 ? Colors.orange[700] : Colors.grey[600],
                      fontWeight:
                          dueCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBarWidget(
                progress: progress,
                height: 8,
              ),
              const SizedBox(height: 8),
              if (deck.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: deck.tags
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.grey[200],
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension method for Deck to calculate due flashcards
extension DeckFlashcardExtension on Deck {
  int getDueFlashcardsCount() {
    // This is a placeholder implementation - in a real implementation,
    // this would check each flashcard's review date against the current date
    // or use a spaced repetition algorithm to determine which cards are due
    return flashcards.length;
  }
}
