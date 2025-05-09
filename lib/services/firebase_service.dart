import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _decksCollection => _firestore.collection('decks');
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create a new deck
  Future<String> createDeck(Deck deck) async {
    try {
      DocumentReference docRef = await _decksCollection.add(deck.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create deck: $e');
    }
  }

  // Get user's decks
  Stream<List<Deck>> getUserDecks(String userId) {
    return _decksCollection
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Deck.fromFirestore(doc)).toList());
  }

  // Get public decks
  Stream<List<Deck>> getPublicDecks() {
    return _decksCollection.where('isPublic', isEqualTo: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Deck.fromFirestore(doc)).toList());
  }

  // Get a specific deck
  Future<Deck?> getDeck(String deckId) async {
    try {
      DocumentSnapshot doc = await _decksCollection.doc(deckId).get();
      if (doc.exists) {
        return Deck.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get deck: $e');
    }
  }

  // Update a deck
  Future<void> updateDeck(Deck deck) async {
    try {
      await _decksCollection.doc(deck.id).update(deck.toMap());
    } catch (e) {
      throw Exception('Failed to update deck: $e');
    }
  }

  // Delete a deck
  Future<void> deleteDeck(String deckId) async {
    try {
      await _decksCollection.doc(deckId).delete();
    } catch (e) {
      throw Exception('Failed to delete deck: $e');
    }
  }

  // Add a flashcard to a deck
  Future<void> addFlashcardToDeck(String deckId, Flashcard flashcard) async {
    try {
      Deck? deck = await getDeck(deckId);
      if (deck != null) {
        List<Flashcard> updatedFlashcards = [...deck.flashcards, flashcard];
        await _decksCollection.doc(deckId).update({
          'flashcards': updatedFlashcards.map((f) => f.toMap()).toList(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add flashcard: $e');
    }
  }

  // Create user profile
  Future<void> createUserProfile(
      String userId, String displayName, String email) async {
    try {
      await _usersCollection.doc(userId).set({
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Update user study progress
  Future<void> updateUserProgress(
      String userId, String deckId, bool isCorrect) async {
    try {
      DocumentReference userProgressRef =
          _usersCollection.doc(userId).collection('progress').doc(deckId);

      DocumentSnapshot progressDoc = await userProgressRef.get();

      if (progressDoc.exists) {
        Map<String, dynamic> data = progressDoc.data() as Map<String, dynamic>;
        int correctAnswers = data['correctAnswers'] ?? 0;
        int incorrectAnswers = data['incorrectAnswers'] ?? 0;

        await userProgressRef.update({
          'correctAnswers': isCorrect ? correctAnswers + 1 : correctAnswers,
          'incorrectAnswers':
              isCorrect ? incorrectAnswers : incorrectAnswers + 1,
          'lastStudied': FieldValue.serverTimestamp(),
        });
      } else {
        await userProgressRef.set({
          'correctAnswers': isCorrect ? 1 : 0,
          'incorrectAnswers': isCorrect ? 0 : 1,
          'lastStudied': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  // Get user's study progress
  Future<Map<String, dynamic>> getUserProgress(
      String userId, String deckId) async {
    try {
      DocumentSnapshot doc = await _usersCollection
          .doc(userId)
          .collection('progress')
          .doc(deckId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {'correctAnswers': 0, 'incorrectAnswers': 0};
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  // Search decks by tags
  Stream<List<Deck>> searchDecksByTags(List<String> tags) {
    return _decksCollection
        .where('isPublic', isEqualTo: true)
        .where('tags', arrayContainsAny: tags)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Deck.fromFirestore(doc)).toList());
  }
}
