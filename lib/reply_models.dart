class Reply {
  final String id;
  final String discussionId;
  final String userId;
  final String userDisplayName;
  final String content;
  final DateTime timestamp;
  final int likes;

  Reply({
    required this.id,
    required this.discussionId,
    required this.userId,
    required this.userDisplayName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      discussionId: json['discussionId'],
      userId: json['userId'],
      userDisplayName: json['userDisplayName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'discussionId': discussionId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }
}