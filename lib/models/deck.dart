import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

class Deck {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final bool isPublic;
  final List<String> tags;
  final DateTime createdAt;
  final List<Flashcard> flashcards;

  Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.isPublic,
    required this.tags,
    required this.createdAt,
    required this.flashcards,
  });

  factory Deck.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> flashcardsData = data['flashcards'] ?? [];

    return Deck(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      isPublic: data['isPublic'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      flashcards: flashcardsData
          .map((flashcardData) => Flashcard.fromMap(flashcardData))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'isPublic': isPublic,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'flashcards': flashcards.map((flashcard) => flashcard.toMap()).toList(),
    };
  }

  Deck copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? creatorName,
    bool? isPublic,
    List<String>? tags,
    DateTime? createdAt,
    List<Flashcard>? flashcards,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      flashcards: flashcards ?? this.flashcards,
    );
  }
}
