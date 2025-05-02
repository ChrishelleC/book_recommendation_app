class Discussion {
  final String id;
  final String bookId;
  final String userId;
  final String userDisplayName;
  final String title;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int replies;

  Discussion({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userDisplayName,
    required this.title,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.replies = 0,
  });

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion(
      id: json['id'],
      bookId: json['bookId'],
      userId: json['userId'],
      userDisplayName: json['userDisplayName'],
      title: json['title'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
      replies: json['replies'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'replies': replies,
    };
  }
}