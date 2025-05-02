import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../utils/constants.dart';

class BookService {
  final Duration _timeout = Duration(seconds: 10);

  Future<List<Book>> searchBooks(String query, {int maxResults = 10}) async {
    try {
      final url = Uri.parse(
          '$googleBooksBaseUrl/volumes?q=$query&maxResults=$maxResults&key=$googleBooksApiKey');
      
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          
          return Book.fromJson({
            'id': item['id'] ?? '',
            'title': volumeInfo['title'] ?? 'Unknown Title',
            'authors': volumeInfo['authors'] ?? ['Unknown Author'],
            'description': volumeInfo['description'] ?? 'No description available',
            'imageLinks': volumeInfo['imageLinks'] ?? {'thumbnail': ''},
            'categories': volumeInfo['categories'] ?? ['Uncategorized'],
            'averageRating': volumeInfo['averageRating'] ?? 0,
            'ratingsCount': volumeInfo['ratingsCount'] ?? 0,
            'publishedDate': volumeInfo['publishedDate'] ?? DateTime.now().year.toString(),
          });
        }).toList();
      } else {
        throw Exception('API Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      final url = Uri.parse(
          '$googleBooksBaseUrl/volumes/$bookId?key=$googleBooksApiKey');
      
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final dynamic item = json.decode(response.body);
        final volumeInfo = item['volumeInfo'] ?? {};
        
        return Book.fromJson({
          'id': item['id'] ?? '',
          'title': volumeInfo['title'] ?? 'Unknown Title',
          'authors': volumeInfo['authors'] ?? ['Unknown Author'],
          'description': volumeInfo['description'] ?? 'No description available',
          'imageLinks': volumeInfo['imageLinks'] ?? {'thumbnail': ''},
          'categories': volumeInfo['categories'] ?? ['Uncategorized'],
          'averageRating': volumeInfo['averageRating'] ?? 0,
          'ratingsCount': volumeInfo['ratingsCount'] ?? 0,
          'publishedDate': volumeInfo['publishedDate'] ?? DateTime.now().year.toString(),
        });
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('API Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Book>> getRecommendedBooks(List<String> preferredGenres) async {
    List<Book> recommendedBooks = [];
    
    final genres = preferredGenres.isEmpty ? ['fiction'] : preferredGenres.take(3).toList();
    
    for (String genre in genres) {
      try {
        final url = Uri.parse(
            '$googleBooksBaseUrl/volumes?q=subject:$genre&maxResults=5&key=$googleBooksApiKey');
        
        final response = await http.get(url).timeout(_timeout);
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> items = data['items'] ?? [];
          
          for (final item in items) {
            final volumeInfo = item['volumeInfo'] ?? {};
            
            final book = Book.fromJson({
              'id': item['id'] ?? '',
              'title': volumeInfo['title'] ?? 'Unknown Title',
              'authors': volumeInfo['authors'] ?? ['Unknown Author'],
              'description': volumeInfo['description'] ?? 'No description available',
              'imageLinks': volumeInfo['imageLinks'] ?? {'thumbnail': ''},
              'categories': volumeInfo['categories'] ?? [genre],
              'averageRating': volumeInfo['averageRating'] ?? 0,
              'ratingsCount': volumeInfo['ratingsCount'] ?? 0,
              'publishedDate': volumeInfo['publishedDate'] ?? DateTime.now().year.toString(),
            });
            
            recommendedBooks.add(book);
          }
        }
      } catch (e) {
      }
    }
    
    return recommendedBooks.take(10).toList();
  }

  Future<List<Book>> getTrendingBooks() async {
    try {
      final url = Uri.parse(
          '$googleBooksBaseUrl/volumes?q=subject:fiction&orderBy=newest&maxResults=10&key=$googleBooksApiKey');
      
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          
          return Book.fromJson({
            'id': item['id'] ?? '',
            'title': volumeInfo['title'] ?? 'Unknown Title',
            'authors': volumeInfo['authors'] ?? ['Unknown Author'],
            'description': volumeInfo['description'] ?? 'No description available',
            'imageLinks': volumeInfo['imageLinks'] ?? {'thumbnail': ''},
            'categories': volumeInfo['categories'] ?? ['Fiction'],
            'averageRating': volumeInfo['averageRating'] ?? 0,
            'ratingsCount': volumeInfo['ratingsCount'] ?? 0,
            'publishedDate': volumeInfo['publishedDate'] ?? DateTime.now().year.toString(),
          });
        }).toList();
      } else {
        throw Exception('Failed to get trending books: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }
}