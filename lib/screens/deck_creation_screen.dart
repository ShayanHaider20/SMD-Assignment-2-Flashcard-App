import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_event.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_state.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

class DeckCreationScreen extends StatefulWidget {
  const DeckCreationScreen({super.key});

  @override
  State<DeckCreationScreen> createState() => _DeckCreationScreenState();
}

class _DeckCreationScreenState extends State<DeckCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  bool _isPublic = false;
  final List<String> _tags = [];
  final List<Flashcard> _flashcards = [];
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addFlashcard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FlashcardFormWidget(
          onSave: (question, answer) {
            setState(() {
              _flashcards.add(
                Flashcard(
                  question: question,
                  answer: answer,
                ),
              );
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _removeFlashcard(int index) {
    setState(() {
      _flashcards.removeAt(index);
    });
  }

  void _saveDeck() {
    if (_formKey.currentState!.validate()) {
      if (_flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one flashcard'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to create a deck'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newDeck = Deck(
        id: '', // Will be assigned by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        creatorId: user.uid,
        creatorName: user.displayName ?? 'Unknown',
        isPublic: _isPublic,
        tags: _tags,
        createdAt: DateTime.now(),
        flashcards: _flashcards,
      );

      context.read<DeckBloc>().add(CreateDeckEvent(deck: newDeck));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Deck'),
      ),
      body: BlocConsumer<DeckBloc, DeckState>(
        listener: (context, state) {
          if (state is DeckLoadingState) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is DeckCreatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deck created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is DeckErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Deck Title',
                      hintText: 'Enter a title for your deck',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what this deck is about',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            hintText: 'Add relevant tags',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTag,
                        child: const Text('Add Tag'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.clear),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Make this deck public'),
                    subtitle: const Text(
                        'Public decks can be viewed and used by other users'),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Flashcards',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addFlashcard,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Flashcard'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = _flashcards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            flashcard.question,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(flashcard.answer),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeFlashcard(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDeck,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Deck'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FlashcardFormWidget extends StatefulWidget {
  final Function(String question, String answer) onSave;

  const FlashcardFormWidget({
    super.key,
    required this.onSave,
  });

  @override
  State<FlashcardFormWidget> createState() => _FlashcardFormWidgetState();
}

class _FlashcardFormWidgetState extends State<FlashcardFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _saveFlashcard() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _questionController.text.trim(),
        _answerController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Flashcard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Enter the question',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                hintText: 'Enter the answer',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an answer';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveFlashcard,
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
