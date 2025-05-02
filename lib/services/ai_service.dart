import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/review.dart';
import '../utils/constants.dart';

class AIService {
  final Random _random = Random();
    Future<List<String>> getAIRecommendations(List<String> genres, List<String> readBooks) async {
    try {
      final url = Uri.parse('$openAiBaseUrl/chat/completions');
      String prompt = "Recommend 5 book titles based on these preferences:\n" +
                      (genres.isNotEmpty ? "Genres: ${genres.join(', ')}\n" : "") +
                      (readBooks.isNotEmpty ? "Books they've read: ${readBooks.join(', ')}\n" : "") +
                      "Respond with a JSON array of book titles only.";

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a book recommendation assistant.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final content = json.decode(response.body)['choices'][0]['message']['content'];
        try {
          return (json.decode(content) as List).map((item) => item.toString()).toList();
        } catch (e) {
          return [];
        }
      }
      throw Exception('API error: ${response.statusCode}');
    } catch (e) {
      print('Error getting AI recommendations: $e');
      return [];
    }
  }
  Future<Map<String, dynamic>> generateReadingInsights(
      List<Book> readBooks, List<Review> userReviews) async {
    try {
      final genres = <String, int>{};
      final authors = <String, int>{};
      int totalPages = 0;
      
      for (final book in readBooks) {
        if (book.genre.isNotEmpty) {
          genres[book.genre] = (genres[book.genre] ?? 0) + 1;
        }
        authors[book.author] = (authors[book.author] ?? 0) + 1;
                final description = book.description;
        int pageCount;
        
        if (description.length < 500) {
          pageCount = 150 + _random.nextInt(200);
        } else {
          pageCount = 300 + _random.nextInt(300);
        }
        
        totalPages += pageCount;
      }
            double averageRating = userReviews.isEmpty ? 0 : 
          userReviews.fold<double>(0, (sum, review) => sum + review.rating) / userReviews.length;
            String favoriteGenre = genres.isEmpty ? 'None' :
          genres.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      String favoriteAuthor = authors.isEmpty ? 'None' :
          authors.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      
      return {
        'books_read': readBooks.length,
        'pages_read': totalPages,
        'favorite_genre': favoriteGenre,
        'favorite_author': favoriteAuthor,
        'average_rating': averageRating.toStringAsFixed(1),
        'reviews_written': userReviews.length,
        'genres_explored': genres.keys.toList(),
      };
    } catch (e) {
      print('Error generating reading insights: $e');
      return {
        'books_read': 0,
        'pages_read': 0,
        'favorite_genre': 'None',
        'favorite_author': 'None',
        'average_rating': '0.0',
        'reviews_written': 0,
        'genres_explored': <String>[],
      };
    }
  }
}