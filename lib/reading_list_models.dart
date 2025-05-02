enum ReadingStatus { wantToRead, currentlyReading, finished }

class ReadingListItem {
  final String id;
  final String bookId;
  final String userId;
  final ReadingStatus status;
  final DateTime dateAdded;
  final DateTime? dateStarted;
  final DateTime? dateFinished;
  final int? currentPage;
  final int? totalPages;

  ReadingListItem({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.status,
    required this.dateAdded,
    this.dateStarted,
    this.dateFinished,
    this.currentPage,
    this.totalPages,
  });

  factory ReadingListItem.fromJson(Map<String, dynamic> json) {
    return ReadingListItem(
      id: json['id'],
      bookId: json['bookId'],
      userId: json['userId'],
      status: ReadingStatus.values.byName(json['status']),
      dateAdded: DateTime.parse(json['dateAdded']),
      dateStarted: json['dateStarted'] != null
          ? DateTime.parse(json['dateStarted'])
          : null,
      dateFinished: json['dateFinished'] != null
          ? DateTime.parse(json['dateFinished'])
          : null,
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'status': status.name,
      'dateAdded': dateAdded.toIso8601String(),
      'dateStarted': dateStarted?.toIso8601String(),
      'dateFinished': dateFinished?.toIso8601String(),
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }

  ReadingListItem copyWith({
    String? id,
    String? bookId,
    String? userId,
    ReadingStatus? status,
    DateTime? dateAdded,
    DateTime? dateStarted,
    DateTime? dateFinished,
    int? currentPage,
    int? totalPages,
  }) {
    return ReadingListItem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      dateStarted: dateStarted ?? this.dateStarted,
      dateFinished: dateFinished ?? this.dateFinished,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}