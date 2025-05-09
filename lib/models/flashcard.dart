import 'package:uuid/uuid.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;

  Flashcard({
    String? id,
    required this.question,
    required this.answer,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? const Uuid().v4(),
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.fromMillisecondsSinceEpoch(
                  map['createdAt'].millisecondsSinceEpoch))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'createdAt': createdAt,
    };
  }

  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
