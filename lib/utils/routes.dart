import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/book_details_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/reading_list_screen.dart';
import '../screens/review_screen.dart';
import '../screens/discussion_screen.dart';
import '../screens/discussion_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/filter_screen.dart';

class Routes {
  static const String home = '/';
  static const String search = '/search';
  static const String bookDetails = '/book-details';
  static const String profile = '/profile';
  static const String readingList = '/reading-list';
  static const String review = '/review';
  static const String discussion = '/discussion';
  static const String discussionDetail = '/discussion-detail';
  static const String login = '/login';
  static const String register = '/register';
  static const String filter = '/filter';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    search: (context) => const SearchScreen(),
    bookDetails: (context) => const BookDetailsScreen(),
    profile: (context) => const ProfileScreen(),
    readingList: (context) => const ReadingListScreen(),
    review: (context) => const ReviewScreen(),
    discussion: (context) => const DiscussionScreen(),
    discussionDetail: (context) => const DiscussionDetailScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    filter: (context) => const FilterScreen(),
  };
}