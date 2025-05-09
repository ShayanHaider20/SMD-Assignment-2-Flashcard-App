import 'package:flutter/material.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback? onFlip;
  final Function(bool)? onAnswer;

  const FlashcardWidget({
    Key? key,
    required this.flashcard,
    this.onFlip,
    this.onAnswer,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showingAnswer = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _animation.addListener(() {
      if (_animation.value >= 0.5 && !_showingAnswer) {
        setState(() {
          _showingAnswer = true;
        });
      } else if (_animation.value < 0.5 && _showingAnswer) {
        setState(() {
          _showingAnswer = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    if (widget.onFlip != null) {
      widget.onFlip!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _flip,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(3.1415926535897932 * _animation.value);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: _animation.value <= 0.5
                      ? _buildCardFace(
                          widget.flashcard.question,
                          Colors.blue.shade50,
                          Icons.help_outline,
                          Colors.blue,
                          'Question',
                        )
                      : Transform(
                          transform: Matrix4.identity()
                            ..rotateY(3.1415926535897932),
                          alignment: Alignment.center,
                          child: _buildCardFace(
                            widget.flashcard.answer,
                            Colors.green.shade50,
                            Icons.check_circle_outline,
                            Colors.green,
                            'Answer',
                          ),
                        ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_showingAnswer)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnswerButton(
                'Incorrect',
                Colors.red,
                Icons.close,
                () => widget.onAnswer?.call(false),
              ),
              _buildAnswerButton(
                'Correct',
                Colors.green,
                Icons.check,
                () => widget.onAnswer?.call(true),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCardFace(
    String content,
    Color backgroundColor,
    IconData icon,
    Color iconColor,
    String label,
  ) {
    return Card(
      elevation: 4,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Tap to flip',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

class FlipFlashcardGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onFlip;

  const FlipFlashcardGestureDetector({
    Key? key,
    required this.child,
    required this.onFlip,
  }) : super(key: key);

  @override
  State<FlipFlashcardGestureDetector> createState() =>
      _FlipFlashcardGestureDetectorState();
}

class _FlipFlashcardGestureDetectorState
    extends State<FlipFlashcardGestureDetector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {},
      onHorizontalDragEnd: (details) {
        final horizontalVelocity = details.primaryVelocity ?? 0;

        // If swiped horizontally with sufficient velocity
        if (horizontalVelocity.abs() > 300) {
          widget.onFlip();
        }
      },
      onTap: widget.onFlip,
      child: widget.child,
    );
  }
}
