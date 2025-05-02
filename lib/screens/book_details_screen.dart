import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../models/reading_list.dart';
import '../widgets/rating_widget.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final book = bookProvider.selectedBook;
        
        if (book == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  background: book.coverUrl.isNotEmpty
                      ? Image.network(
                          book.coverUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.book,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'by ${book.author}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: smallPadding),
                      Row(
                        children: [
                          RatingWidget(
                            rating: book.averageRating,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${book.averageRating.toStringAsFixed(1)} (${book.totalRatings} ratings)',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: smallPadding),
                      Wrap(
                        spacing: 8,
                        children: book.categories.map((category) {
                          return Chip(
                            label: Text(category),
                            backgroundColor: Colors.grey[200],
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: defaultPadding),
                      const Text(
                        'Description',
                        style: subheadingStyle,
                      ),
                      const SizedBox(height: smallPadding),
                      Text(book.description),
                      const SizedBox(height: largePadding),
                      _buildActionButtons(context, book.id),
                      const SizedBox(height: largePadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reviews',
                            style: subheadingStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.review,
                                arguments: book.id,
                              );
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: defaultPadding),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.review,
                              arguments: {'bookId': book.id, 'isAdding': true},
                            );
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Write a Review'),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discussions',
                            style: subheadingStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                Routes.discussion,
                                arguments: book.id,
                              );
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: defaultPadding),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.discussion,
                              arguments: {'bookId': book.id, 'isAdding': true},
                            );
                          },
                          icon: const Icon(Icons.forum),
                          label: const Text('Start a Discussion'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, String bookId) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isAuthenticated) {
          return ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.login);
            },
            child: const Text('Log in to add to reading list'),
          );
        }

        final userId = userProvider.currentUser!.id;
        final wantToRead = userProvider.wantToReadList
            .any((item) => item.bookId == bookId);
        final currentlyReading = userProvider.currentlyReadingList
            .any((item) => item.bookId == bookId);
        final finished = userProvider.finishedList
            .any((item) => item.bookId == bookId);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildReadingButton(
              context,
              'Want to Read',
              Icons.bookmark,
              wantToRead,
              () => _addToReadingList(
                context,
                bookId,
                userId,
                ReadingStatus.wantToRead,
              ),
            ),
            _buildReadingButton(
              context,
              'Reading',
              Icons.book,
              currentlyReading,
              () => _addToReadingList(
                context,
                bookId,
                userId,
                ReadingStatus.currentlyReading,
              ),
            ),
            _buildReadingButton(
              context,
              'Finished',
              Icons.check_circle,
              finished,
              () => _addToReadingList(
                context,
                bookId,
                userId,
                ReadingStatus.finished,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadingButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? primaryColor : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black,
      ),
    );
  }

  void _addToReadingList(
    BuildContext context,
    String bookId,
    String userId,
    ReadingStatus status,
  ) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final existingWantToRead = userProvider.wantToReadList
        .where((item) => item.bookId == bookId)
        .firstOrNull;
    final existingCurrentlyReading = userProvider.currentlyReadingList
        .where((item) => item.bookId == bookId)
        .firstOrNull;
    final existingFinished = userProvider.finishedList
        .where((item) => item.bookId == bookId)
        .firstOrNull;

    if (existingWantToRead != null) {
      userProvider.removeFromReadingList(existingWantToRead.id);
    }
    if (existingCurrentlyReading != null) {
      userProvider.removeFromReadingList(existingCurrentlyReading.id);
    }
    if (existingFinished != null) {
      userProvider.removeFromReadingList(existingFinished.id);
    }

    if ((status == ReadingStatus.wantToRead && existingWantToRead != null) ||
        (status == ReadingStatus.currentlyReading && existingCurrentlyReading != null) ||
        (status == ReadingStatus.finished && existingFinished != null)) {
      return;
    }
    
    final now = DateTime.now();
    final item = ReadingListItem(
      id: const Uuid().v4(),
      bookId: bookId,
      userId: userId,
      status: status,
      dateAdded: now,
      dateStarted: status == ReadingStatus.currentlyReading ? now : null,
      dateFinished: status == ReadingStatus.finished ? now : null,
    );
    
    userProvider.addToReadingList(item);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to "${status.name}" list'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}