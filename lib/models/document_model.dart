class DocumentModel {
  final String id;
  final String title;
  final String uid;
  final DateTime createdAt;
  final List content;

  DocumentModel({
    required this.title,
    required this.uid,
    required this.createdAt,
    required this.content,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'uid': uid,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'content': content,
      };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['_id'] ?? '',
        title: json['title'] ?? '',
        uid: json['uid'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        content: List.from(json['content']),
      );

  DocumentModel copyWith({
    String? id,
    String? title,
    String? uid,
    DateTime? createdAt,
    List? content,
  }) =>
      DocumentModel(
        id: id ?? this.id,
        title: title ?? this.title,
        uid: uid ?? this.uid,
        createdAt: createdAt ?? this.createdAt,
        content: content ?? this.content,
      );
}
