import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_bloc.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_event.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_event.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_state.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/screens/auth/login_screen.dart';
import 'package:micro_learning_flashcards/screens/deck_creation_screen.dart';
import 'package:micro_learning_flashcards/screens/flashcard_review_screen.dart';
import 'package:micro_learning_flashcards/screens/search_screen.dart';
import 'package:micro_learning_flashcards/widgets/deck_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load user decks
    if (_auth.currentUser != null) {
      context.read<DeckBloc>().add(
            LoadUserDecksEvent(userId: _auth.currentUser!.uid),
          );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPublicDecks() {
    context.read<DeckBloc>().add(
          LoadPublicDecksEvent(),
        );
  }

  void _navigateToDeckCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeckCreationScreen(),
      ),
    ).then((_) {
      // Refresh user decks when returning from deck creation
      if (_auth.currentUser != null) {
        context.read<DeckBloc>().add(
              LoadUserDecksEvent(userId: _auth.currentUser!.uid),
            );
      }
    });
  }

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  void _signOut() async {
    await _auth.signOut();
    if (mounted) {
      context.read<AuthBloc>().add(SignOutEvent());
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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

  Widget _buildDecksList(List<Deck> decks) {
    if (decks.isEmpty) {
      return const Center(
        child: Text(
          'No decks found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        final int dueCount =
            DeckFlashcardExtension(deck).getDueFlashcardsCount();
        final totalCount = deck.flashcards.length;
        final progress =
            totalCount > 0 ? (totalCount - dueCount) / totalCount : 0.0;

        return DeckListItem(
          deck: deck,
          progress: progress,
          onTap: () => _startReview(deck),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro Learning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _navigateToSearchScreen,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Decks'),
            Tab(text: 'Public Decks'),
          ],
          onTap: (index) {
            if (index == 1) {
              _loadPublicDecks();
            } else if (_auth.currentUser != null) {
              context.read<DeckBloc>().add(
                    LoadUserDecksEvent(userId: _auth.currentUser!.uid),
                  );
            }
          },
        ),
      ),
      body: BlocBuilder<DeckBloc, DeckState>(
        builder: (context, state) {
          if (state is DeckLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DecksLoadedState) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDecksList(state.userDecks),
                _buildDecksList(state.publicDecks),
              ],
            );
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
                    onPressed: () {
                      if (_auth.currentUser != null) {
                        context.read<DeckBloc>().add(
                              LoadUserDecksEvent(
                                  userId: _auth.currentUser!.uid),
                            );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Default empty state
          return const Center(child: Text('No decks available'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToDeckCreation,
        child: const Icon(Icons.add),
        tooltip: 'Create New Deck',
      ),
    );
  }
}

// Extension method to get due flashcard count
extension DeckExtension on Deck {
  int getDueFlashcardsCount() {
    // In a real implementation, this would check the due date based on spaced repetition algorithm
    // For now, let's assume all flashcards are due
    return flashcards.length;
  }
}
