class SyllabusModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> topics;

  // Add this to your SyllabusModel class if it doesn't exist
  SyllabusModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? topics,
  }) {
    return SyllabusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      topics: topics ?? this.topics,
    );
  }

  SyllabusModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.topics,
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      source: json['source'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      topics: extractTopics(json['content']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to extract topics from syllabus content
  static List<String> extractTopics(String content) {
    // Simple implementation - split by newlines and filter empty lines
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // In a real implementation, you might use AI to extract actual topics
    return lines;
  }
}
