import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_event.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_state.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/screens/flashcard_review_screen.dart';
import 'package:micro_learning_flashcards/widgets/deck_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _commonTags = [
    'programming',
    'language',
    'history',
    'math',
    'science',
    'geography',
    'arts',
    'literature'
  ];

  @override
  void initState() {
    super.initState();
    // Load public decks initially
    context.read<DeckBloc>().add(LoadPublicDecksEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
      _performSearch();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    _performSearch();
  }

  void _performSearch() {
    if (_selectedTags.isNotEmpty) {
      context.read<DeckBloc>().add(SearchDecksByTagsEvent(tags: _selectedTags));
    } else {
      context.read<DeckBloc>().add(LoadPublicDecksEvent());
    }
  }

  void _startReview(Deck deck) {
    if (deck.flashcards.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardReviewScreen(deck: deck),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This deck has no flashcards to review')),
      );
    }
  }

  Widget _buildTagChip(String tag) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
        label: Text(tag),
        selected: _selectedTags.contains(tag),
        onPressed: () {
          if (_selectedTags.contains(tag)) {
            _removeTag(tag);
          } else {
            _addTag(tag);
          }
        },
      ),
    );
  }

  Widget _buildSelectedTagsList() {
    return Wrap(
      spacing: 8.0,
      children: _selectedTags.map((tag) {
        return Chip(
          label: Text(tag),
          onDeleted: () => _removeTag(tag),
        );
      }).toList(),
    );
  }

  Widget _buildDecksList(List<Deck> decks) {
    if (decks.isEmpty) {
      return const Center(
        child: Text(
          'No decks found matching your search',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return DeckListItem(
          deck: deck,
          progress: 0.0, // Not tracking progress for public decks in search
          onTap: () => _startReview(deck),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Decks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter by tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _commonTags.map(_buildTagChip).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by tag',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addTag(value);
                      _searchController.clear();
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (_selectedTags.isNotEmpty) ...[
                  const Text(
                    'Filtered by:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildSelectedTagsList(),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DeckBloc, DeckState>(
              builder: (context, state) {
                if (state is DeckLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DecksLoadedState) {
                  return _buildDecksList(state.publicDecks);
                } else if (state is DeckErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _performSearch,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Search for flashcard decks'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
