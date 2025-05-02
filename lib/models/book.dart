class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String genre;
  final double averageRating;
  final int totalRatings;
  final DateTime publishDate;
  final List<String> categories;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.genre,
    required this.averageRating,
    required this.totalRatings,
    required this.publishDate,
    required this.categories,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Extract and fix the cover URL
    String coverUrl = json['imageLinks']?['thumbnail'] ?? '';
    
    // Force HTTPS protocol
    if (coverUrl.startsWith('http:')) {
      coverUrl = coverUrl.replaceFirst('http:', 'https:');
    }
    
    // Add zoom parameter for higher quality if not present
    if (coverUrl.isNotEmpty && !coverUrl.contains('zoom=')) {
      coverUrl += coverUrl.contains('?') ? '&zoom=1' : '?zoom=1';
    }
    
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['authors']?[0] ?? 'Unknown Author',
      description: json['description'] ?? 'No description available',
      coverUrl: coverUrl,
      genre: json['categories']?[0] ?? 'Uncategorized',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['ratingsCount'] ?? 0,
      publishDate: json['publishedDate'] != null
          ? _parsePublishedDate(json['publishedDate'])
          : DateTime.now(),
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
    );
  }

  static DateTime _parsePublishedDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      if (dateStr.length == 4) {
        return DateTime(int.parse(dateStr), 1, 1);
      } else if (dateStr.length == 7) {
        final parts = dateStr.split('-');
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      } else {
        return DateTime.now();
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'genre': genre,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'publishDate': publishDate.toIso8601String(),
      'categories': categories,
    };
  }
}