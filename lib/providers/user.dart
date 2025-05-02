import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/reading_list.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  User? _currentUser;
  List<ReadingListItem> _wantToReadList = [];
  List<ReadingListItem> _currentlyReadingList = [];
  List<ReadingListItem> _finishedList = [];
  bool _isLoading = false;
  String _error = '';

  User? get currentUser => _currentUser;
  List<ReadingListItem> get wantToReadList => _wantToReadList;
  List<ReadingListItem> get currentlyReadingList => _currentlyReadingList;
  List<ReadingListItem> get finishedList => _finishedList;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _currentUser != null;

  UserProvider() {
    _authService.user.listen((user) {
      _currentUser = user;
      if (user != null) {
        fetchReadingLists(user.id);
      } else {
        _wantToReadList = [];
        _currentlyReadingList = [];
        _finishedList = [];
      }
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signUp(email, password, displayName);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signIn(email, password);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateUserProfile(user);
      _currentUser = user;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchReadingLists(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _wantToReadList = await _databaseService.getUserReadingList(
          userId, ReadingStatus.wantToRead);
      
      _currentlyReadingList = await _databaseService.getUserReadingList(
          userId, ReadingStatus.currentlyReading);
      
      _finishedList = await _databaseService.getUserReadingList(
          userId, ReadingStatus.finished);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addToReadingList(ReadingListItem item) async {
    try {
      await _databaseService.addToReadingList(item);
      
      switch (item.status) {
        case ReadingStatus.wantToRead:
          _wantToReadList.add(item);
          break;
        case ReadingStatus.currentlyReading:
          _currentlyReadingList.add(item);
          break;
        case ReadingStatus.finished:
          _finishedList.add(item);
          break;
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateReadingListItem(ReadingListItem item) async {
    try {
      await _databaseService.updateReadingListItem(item);
      
      _wantToReadList = _wantToReadList.where((i) => i.id != item.id).toList();
      _currentlyReadingList = _currentlyReadingList.where((i) => i.id != item.id).toList();
      _finishedList = _finishedList.where((i) => i.id != item.id).toList();
      
      switch (item.status) {
        case ReadingStatus.wantToRead:
          _wantToReadList.add(item);
          break;
        case ReadingStatus.currentlyReading:
          _currentlyReadingList.add(item);
          break;
        case ReadingStatus.finished:
          _finishedList.add(item);
          break;
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromReadingList(String itemId) async {
    try {
      await _databaseService.removeFromReadingList(itemId);
      
      _wantToReadList = _wantToReadList.where((item) => item.id != itemId).toList();
      _currentlyReadingList = _currentlyReadingList.where((item) => item.id != itemId).toList();
      _finishedList = _finishedList.where((item) => item.id != itemId).toList();
      
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
