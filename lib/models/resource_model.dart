class ResourceModel {
  final String id;
  final String syllabusId;
  final String topic;
  final String type; // 'youtube' or 'pdf' or 'web'
  final String title;
  final String url;
  final String? description;
  final DateTime createdAt;

  ResourceModel({
    required this.id,
    required this.syllabusId,
    required this.topic,
    required this.type,
    required this.title,
    required this.url,
    this.description,
    required this.createdAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'],
      syllabusId: json['syllabus_id'],
      topic: json['topic'],
      type: json['type'],
      title: json['title'],
      url: json['url'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syllabus_id': syllabusId,
      'topic': topic,
      'type': type,
      'title': title,
      'url': url,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
