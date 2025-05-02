import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/discussion.dart';
import '../services/database_service.dart';

class DiscussionProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = Uuid();
  
  List<Discussion> _discussions = [];
  bool _isLoading = false;
  String _error = '';

  List<Discussion> get discussions => _discussions;
  bool get isLoading => _isLoading;
  String get error => _error;
  Future<void> _executeWithLoadingState(Future<void> Function() action) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await action();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchBookDiscussions(String bookId) async {
    await _executeWithLoadingState(() async {
      _discussions = await _databaseService.getBookDiscussions(bookId);
    });
  }

  Future<void> fetchAllDiscussions() async {
    await _executeWithLoadingState(() async {
      _discussions = await _databaseService.getAllDiscussions();
    });
  }

  Future<void> addDiscussion({
    required String bookId,
    required String userId,
    required String userDisplayName,
    required String title,
    required String content,
  }) async {
    try {
      final discussion = Discussion(
        id: _uuid.v4(),
        bookId: bookId,
        userId: userId,
        userDisplayName: userDisplayName,
        title: title,
        content: content,
        timestamp: DateTime.now(),
      );

      await _databaseService.addDiscussion(discussion);
      _discussions.insert(0, discussion);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDiscussion(Discussion discussion) async {
    try {
      await _databaseService.updateDiscussion(discussion);
      
      final index = _discussions.indexWhere((d) => d.id == discussion.id);
      if (index >= 0) {
        _discussions[index] = discussion;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteDiscussion(String discussionId) async {
    try {
      await _databaseService.deleteDiscussion(discussionId);
      _discussions.removeWhere((d) => d.id == discussionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}