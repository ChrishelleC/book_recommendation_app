import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      try {
        return await _databaseService.getUserById(firebaseUser.uid);
      } catch (e) {
        final newUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
        );
        
        return newUser;
      }
    });
  }

  Future<User> signUp(String email, String password, String displayName) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = result.user;
      
      if (firebaseUser == null) {
        throw Exception('Registration failed');
      }
      
      await firebaseUser.updateDisplayName(displayName);
      
      final user = User(
        id: firebaseUser.uid,
        email: email,
        displayName: displayName,
      );
      
      await _databaseService.createUser(user);
      
      return user;
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }
  Future<User> signIn(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = result.user;
      
      if (firebaseUser == null) {
        throw Exception('Login failed');
      }
      
      try {
        return await _databaseService.getUserById(firebaseUser.uid);
      } catch (e) {
        final newUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
        );
        
        await _databaseService.createUser(newUser);
        return newUser;
      }
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateUserProfile(User user) async {
    await _databaseService.updateUser(user);
    
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null && currentUser.uid == user.id) {
      await currentUser.updateDisplayName(user.displayName);
    }
  }
}