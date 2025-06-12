import 'package:myapp/model/question.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timtLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timtLimit,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id,
      title: map['title'] ?? "",
      categoryId: map['categoryId'] ?? "",
      timtLimit: map['timtLimit'] ?? 0,
      questions:
          ((map['questions'] ?? []) as List)
              .map((e) => Question.fromMap(e))
              .toList(),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'title': title,
      'categoryId': categoryId,
      'timtLimit': timtLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      if (isUpdate) 'updatedAt': DateTime.now,
      'createdAt': createdAt,
    };
  }

  Quiz copyWith({
    String? title,
    String? categoryId,
    int? timtLimit,
    List<Question>? questions,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timtLimit: timtLimit ?? this.timtLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
    );
  }
}
