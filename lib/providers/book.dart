import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../services/book_service.dart';
import '../services/ai_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  final AIService _aiService = AIService();
  
  List<Book> _recommendedBooks = [];
  List<Book> _trendingBooks = [];
  List<Book> _searchResults = [];
  Book? _selectedBook;
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _readingInsights;

  // Getters
  List<Book> get recommendedBooks => _recommendedBooks;
  List<Book> get trendingBooks => _trendingBooks;
  List<Book> get searchResults => _searchResults;
  Book? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, dynamic>? get readingInsights => _readingInsights;

  // Helper method to reduce code repetition
  Future<T> _executeWithLoadingState<T>(Future<T> Function() action) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final result = await action();
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchRecommendedBooks(
      List<String> preferredGenres, List<String> readBookIds, String userId) async {
    try {
      await _executeWithLoadingState(() async {
        if (preferredGenres.isEmpty && readBookIds.isEmpty) {
          _recommendedBooks = await _bookService.getTrendingBooks();
        } else {
          final recommendations = await _aiService.getAIRecommendations(
              preferredGenres, readBookIds);
                        _recommendedBooks = [];
          for (final title in recommendations) {
            final results = await _bookService.searchBooks(title, maxResults: 1);
            if (results.isNotEmpty) {
              _recommendedBooks.add(results.first);
            }
          }
                    if (_recommendedBooks.length < 5) {
            final genreBooks = await _bookService.getRecommendedBooks(preferredGenres);
            
            for (final book in genreBooks) {
              if (!_recommendedBooks.any((b) => b.id == book.id)) {
                _recommendedBooks.add(book);
                if (_recommendedBooks.length >= 10) break;
              }
            }
          }
        }
      });
    } catch (e) {
      _fetchFallbackRecommendations(preferredGenres);
    }
  }

  Future<void> _fetchFallbackRecommendations(List<String> preferredGenres) async {
    try {
      _recommendedBooks = await _bookService.getRecommendedBooks(preferredGenres);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get recommendations: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> fetchTrendingBooks() async {
    await _executeWithLoadingState(() async {
      _trendingBooks = await _bookService.getTrendingBooks();
    });
  }

  Future<void> searchBooks(String query) async {
    await _executeWithLoadingState(() async {
      _searchResults = await _bookService.searchBooks(query);
    });
  }

  Future<void> fetchBookById(String bookId) async {
    await _executeWithLoadingState(() async {
      final book = await _bookService.getBookById(bookId);
      if (book != null) {
        _selectedBook = book;
      } else {
        throw Exception('Book not found');
      }
    });
  }
  Future<Book?> fetchBookByIdAndSelect(String bookId) async {
    try {
      return await _executeWithLoadingState(() async {
        final book = await _bookService.getBookById(bookId);
        
        if (book != null) {
          _selectedBook = book;
          return book;
        } else {
          throw Exception('Book not found');
        }
      });
    } catch (e) {
      return null;
    }
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      return await _bookService.getBookById(bookId);
    } catch (e) {
      print('Error fetching book $bookId: $e');
      return null;
    }
  }
  Future<void> generateReadingInsights(List<Book> readBooks, List<Review> userReviews) async {
    await _executeWithLoadingState(() async {
      _readingInsights = await _aiService.generateReadingInsights(readBooks, userReviews);
    });
  }
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearSelectedBook() {
    _selectedBook = null;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}