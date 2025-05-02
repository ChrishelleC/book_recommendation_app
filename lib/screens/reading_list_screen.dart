import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../models/reading_list.dart';
import '../models/book.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({Key? key}) : super(key: key);

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Book?> _bookCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _preloadBookData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _preloadBookData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    final allItems = [
      ...userProvider.wantToReadList,
      ...userProvider.currentlyReadingList,
      ...userProvider.finishedList,
    ];
    
    if (allItems.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    for (var item in allItems) {
      if (!_bookCache.containsKey(item.bookId)) {
        try {
          final book = await bookProvider.getBookById(item.bookId);
          if (mounted) {
            setState(() {
              _bookCache[item.bookId] = book;
            });
          }
        } catch (e) {
          print('Error loading book ${item.bookId}: $e');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reading Lists'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Want to Read'),
            Tab(text: 'Currently Reading'),
            Tab(text: 'Finished'),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (!userProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Please log in to view your reading lists',
                    style: subheadingStyle,
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.login);
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
            );
          }

          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReadingListTab(
                userProvider.wantToReadList,
                'Want to Read',
                Icons.bookmark,
              ),
              _buildReadingListTab(
                userProvider.currentlyReadingList,
                'Currently Reading',
                Icons.book,
              ),
              _buildReadingListTab(
                userProvider.finishedList,
                'Finished',
                Icons.check_circle,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReadingListTab(
    List<ReadingListItem> items,
    String listType,
    IconData icon,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'No books in your $listType list',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.search);
              },
              child: const Text('Discover Books'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _preloadBookData,
      child: ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final book = _bookCache[item.bookId];
          
          return Card(
            margin: const EdgeInsets.only(bottom: defaultPadding),
            child: ListTile(
              leading: _buildBookCover(book, icon),
              title: Text(book?.title ?? 'Unknown Book'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book != null) Text(book.author),
                  const SizedBox(height: 4),
                  _buildSubtitle(item),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _removeFromReadingList(item.id);
                },
              ),
              onTap: () {
                _viewBookDetails(item.bookId);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookCover(Book? book, IconData defaultIcon) {
    if (book == null || book.coverUrl.isEmpty) {
      return Icon(defaultIcon, size: 40);
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        book.coverUrl,
        width: 40,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(defaultIcon, size: 40);
        },
      ),
    );
  }

  Widget _buildSubtitle(ReadingListItem item) {
    switch (item.status) {
      case ReadingStatus.wantToRead:
        return Text('Added on ${_formatDate(item.dateAdded)}');
      case ReadingStatus.currentlyReading:
        final progress = item.currentPage != null && item.totalPages != null && item.totalPages! > 0
            ? '${((item.currentPage! / item.totalPages!) * 100).toStringAsFixed(0)}% complete'
            : 'In progress';
        return Text('Started on ${_formatDate(item.dateStarted ?? item.dateAdded)} - $progress');
      case ReadingStatus.finished:
        return Text('Finished on ${_formatDate(item.dateFinished ?? item.dateAdded)}');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  void _removeFromReadingList(String itemId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Reading List'),
        content: const Text('Are you sure you want to remove this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userProvider.removeFromReadingList(itemId);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _viewBookDetails(String bookId) {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    bookProvider.fetchBookByIdAndSelect(bookId)
      .then((_) {
        Navigator.pushNamed(context, Routes.bookDetails);
      })
      .catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading book details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
  }
}