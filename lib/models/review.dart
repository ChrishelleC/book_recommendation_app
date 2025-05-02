class Review {
  final String id;
  final String bookId;
  final String userId;
  final String userDisplayName;
  final double rating;
  final String content;
  final DateTime timestamp;
  final int likes;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userDisplayName,
    required this.rating,
    required this.content,
    required this.timestamp,
    this.likes = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      bookId: json['bookId'],
      userId: json['userId'],
      userDisplayName: json['userDisplayName'],
      rating: json['rating'].toDouble(),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'rating': rating,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
    };
  }
}