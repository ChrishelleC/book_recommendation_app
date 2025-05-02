import 'package:flutter/material.dart';
const String googleBooksApiKey = 'AIzaSyBzYCEzGO4DMQ7ApNNSM2cYXGz_avTUOkQ';
const String openAiApiKey = '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';

const String googleBooksBaseUrl = 'https://www.googleapis.com/books/v1';
const String openAiBaseUrl = 'https://api.openai.com/v1';
const String usersCollection = 'users';
const String reviewsCollection = 'reviews';
const String readingListsCollection = 'readingLists';
const String discussionsCollection = 'discussions';

const Color primaryColor = Color(0xFF1A237E);
const Color accentColor = Color(0xFF4CAF50);
const Color backgroundColor = Color(0xFFF5F7FA);
const Color cardColor = Colors.white;
const Color textColor = Color(0xFF263238);
const Color secondaryTextColor = Color(0xFF607D8B);
const Color errorColor = Color(0xFFD32F2F);

const TextStyle headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: textColor,
  letterSpacing: 0.5,
);

const TextStyle subheadingStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: textColor,
  letterSpacing: 0.3,
);

const double defaultPadding = 16.0;
const double smallPadding = 8.0;
const double largePadding = 24.0;
const double cardBorderRadius = 12.0;
const double buttonBorderRadius = 8.0;

const List<String> genres = [
  'Fiction',
  'Science Fiction',
  'Fantasy',
  'Mystery',
  'Thriller',
  'Romance',
  'Non-fiction',
  'Biography',
  'History',
  'Self-help',
  'Business',
  'Science',
  'Technology',
  'Art',
  'Poetry',
];