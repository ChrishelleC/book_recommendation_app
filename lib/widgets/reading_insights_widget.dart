import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../utils/constants.dart';

class ReadingInsightsWidget extends StatefulWidget {
  const ReadingInsightsWidget({Key? key}) : super(key: key);

  @override
  State<ReadingInsightsWidget> createState() => _ReadingInsightsWidgetState();
}

class _ReadingInsightsWidgetState extends State<ReadingInsightsWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isAuthenticated) {
      setState(() {
        _isLoading = true;
      });
      
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      
      List<Book> readBooks = [];
      for (final item in userProvider.finishedList) {
        final book = await bookProvider.getBookById(item.bookId);
        if (book != null) {
          readBooks.add(book);
        }
      }
            List<Review> userReviews = [];
            await bookProvider.generateReadingInsights(readBooks, userReviews);
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, BookProvider>(
      builder: (context, userProvider, bookProvider, child) {
        if (!userProvider.isAuthenticated) {
          return const SizedBox.shrink();
        }

        if (_isLoading || bookProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final insights = bookProvider.readingInsights;
        
        if (insights == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No reading insights available yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                  onPressed: _loadInsights,
                  child: const Text('Generate Insights'),
                ),
              ],
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Reading Profile',
                  style: subheadingStyle,
                ),
                const Divider(),
                _buildInsightTile(
                  Icons.book,
                  'Books Read',
                  '${insights['books_read']}',
                ),
                _buildInsightTile(
                  Icons.my_library_books_outlined,
                  'Pages Read',
                  '${insights['pages_read']}',
                ),
                _buildInsightTile(
                  Icons.category,
                  'Favorite Genre',
                  insights['favorite_genre'],
                ),
                _buildInsightTile(
                  Icons.person,
                  'Favorite Author',
                  insights['favorite_author'],
                ),
                _buildInsightTile(
                  Icons.star,
                  'Average Rating',
                  insights['average_rating'],
                ),
                _buildInsightTile(
                  Icons.rate_review,
                  'Reviews Written',
                  '${insights['reviews_written']}',
                ),
                const SizedBox(height: smallPadding),
                const Text(
                  'Genres Explored',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: smallPadding),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (insights['genres_explored'] as List<dynamic>)
                      .map((genre) => Chip(
                            label: Text(genre),
                            backgroundColor: primaryColor.withOpacity(0.1),
                          ))
                      .toList(),
                ),
                const SizedBox(height: defaultPadding),
                Center(
                  child: TextButton.icon(
                    onPressed: _loadInsights,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Insights'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: smallPadding),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: smallPadding),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: smallPadding),
          Text(value),
        ],
      ),
    );
  }
}