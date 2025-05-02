import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../models/book.dart';
import '../widgets/book_card.dart';
import '../utils/routes.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
  
    await bookProvider.fetchTrendingBooks();
  
    if (userProvider.isAuthenticated) {
      final preferredGenres = userProvider.currentUser!.preferredGenres;
      final readBooks = userProvider.finishedList.map((item) => item.bookId).toList();
      await bookProvider.fetchRecommendedBooks(
          preferredGenres, 
          readBooks, 
          userProvider.currentUser!.id);
    } else {
      await bookProvider.fetchRecommendedBooks([], [], '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Recommendation App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, Routes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<BookProvider>(
          builder: (context, bookProvider, child) {
            if (bookProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (bookProvider.error.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(bookProvider.error),
                    ElevatedButton(
                      onPressed: () {
                        bookProvider.clearError();
                        _loadData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended for You',
                    style: headingStyle,
                  ),
                  const SizedBox(height: smallPadding),
                  SizedBox(
                    height: 280,
                    child: bookProvider.recommendedBooks.isEmpty
                        ? const Center(
                            child: Text('No recommendations available'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: bookProvider.recommendedBooks.length,
                            itemBuilder: (context, index) {
                              final book = bookProvider.recommendedBooks[index];
                              return BookCard(
                                book: book,
                                onTap: () {
                                  bookProvider.fetchBookByIdAndSelect(book.id);
                                  Navigator.pushNamed(
                                    context,
                                    Routes.bookDetails,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: largePadding),
                  const Text(
                    'Trending Books',
                    style: headingStyle,
                  ),
                  const SizedBox(height: smallPadding),
                  SizedBox(
                    height: 280,
                    child: bookProvider.trendingBooks.isEmpty
                        ? const Center(
                            child: Text('No trending books available'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: bookProvider.trendingBooks.length,
                            itemBuilder: (context, index) {
                              final book = bookProvider.trendingBooks[index];
                              return BookCard(
                                book: book,
                                onTap: () {
                                  bookProvider.fetchBookByIdAndSelect(book.id);
                                  Navigator.pushNamed(
                                    context,
                                    Routes.bookDetails,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, Routes.readingList);
              break;
            case 2:
              Navigator.pushNamed(context, Routes.discussion);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Reading List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Discussions',
          ),
        ],
      ),
    );
  }
}