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
      
      print('Calling Google Books API: $url');
      
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        print('Found ${items.length} books for query: $query');
        
        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          
          // Debug print for image URLs
          print('Book cover URL for ${volumeInfo['title']}: ${volumeInfo['imageLinks']?['thumbnail'] ?? 'No cover available'}');
          
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
      } else if (response.statusCode == 403) {
        // API key issue
        print('API Key issue detected: ${response.body}');
        throw Exception('Google Books API key issue - please check quota or restrictions');
      } else {
        print('API Error: Status code ${response.statusCode}, Response: ${response.body}');
        throw Exception('API Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      final url = Uri.parse(
          '$googleBooksBaseUrl/volumes/$bookId?key=$googleBooksApiKey');
      
      print('Fetching book details for ID: $bookId');
      
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final dynamic item = json.decode(response.body);
        final volumeInfo = item['volumeInfo'] ?? {};
        
        // Debug print for image URL
        print('Book cover URL for ${volumeInfo['title']}: ${volumeInfo['imageLinks']?['thumbnail'] ?? 'No cover available'}');
        
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
        print('Book with ID $bookId not found');
        return null;
      } else {
        print('API Error: Status code ${response.statusCode}, Response: ${response.body}');
        throw Exception('API Error: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching book by ID: $e');
      rethrow;
    }
  }

  Future<List<Book>> getRecommendedBooks(List<String> preferredGenres) async {
    List<Book> recommendedBooks = [];
    
    final genres = preferredGenres.isEmpty ? ['fiction'] : preferredGenres.take(3).toList();
    
    print('Getting recommendations for genres: $genres');
    
    for (String genre in genres) {
      try {
        final url = Uri.parse(
            '$googleBooksBaseUrl/volumes?q=subject:$genre&maxResults=5&key=$googleBooksApiKey');
        
        final response = await http.get(url).timeout(_timeout);
        
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> items = data['items'] ?? [];
          
          print('Found ${items.length} books for genre: $genre');
          
          for (final item in items) {
            final volumeInfo = item['volumeInfo'] ?? {};
            
            // Debug print for image URL
            print('Book cover URL for ${volumeInfo['title']}: ${volumeInfo['imageLinks']?['thumbnail'] ?? 'No cover available'}');
            
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
        } else {
          print('API Error for genre $genre: Status code ${response.statusCode}');
        }
      } catch (e) {
        print('Error getting recommendations for genre $genre: $e');
      }
    }
    
    return recommendedBooks.take(10).toList();
  }

  Future<List<Book>> getTrendingBooks() async {
    try {
      final url = Uri.parse(
          '$googleBooksBaseUrl/volumes?q=subject:fiction&orderBy=newest&maxResults=10&key=$googleBooksApiKey');
      
      print('Fetching trending books');
      
      final response = await http.get(url).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        print('Found ${items.length} trending books');
        
        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          
          // Debug print for image URL
          print('Book cover URL for ${volumeInfo['title']}: ${volumeInfo['imageLinks']?['thumbnail'] ?? 'No cover available'}');
          
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
        print('Failed to get trending books: ${response.statusCode}, Response: ${response.body}');
        throw Exception('Failed to get trending books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting trending books: $e');
      return [];
    }
  }
}