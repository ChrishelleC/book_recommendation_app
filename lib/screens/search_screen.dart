import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = '';
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty && _selectedGenre.isEmpty) {
      return;
    }
    
    setState(() {
      _searching = true;
    });
    
    String searchQuery = query;
    
    if (_selectedGenre.isNotEmpty) {
      searchQuery += ' subject:$_selectedGenre';
    }
    
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    await bookProvider.searchBooks(searchQuery);
    
    setState(() {
      _searching = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, or keywords',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              Provider.of<BookProvider>(context, listen: false)
                                  .clearSearchResults();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(buttonBorderRadius),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: smallPadding),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGenreChip(''),
                      ...genres.map((genre) => _buildGenreChip(genre)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    final isSelected = _selectedGenre == genre;
    final label = genre.isEmpty ? 'All' : genre;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedGenre = selected ? genre : '';
          });
          _performSearch();
        },
        backgroundColor: Colors.grey[200],
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
      ),
    );
  }
  Widget _buildSearchResults() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (_searching) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (bookProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${bookProvider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                  onPressed: () {
                    bookProvider.clearError();
                    _performSearch();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (bookProvider.searchResults.isEmpty) {
          return const Center(
            child: Text('No search results yet. Try searching for a book!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: bookProvider.searchResults.length,
          itemBuilder: (context, index) {
            final book = bookProvider.searchResults[index];
            return BookCard(
              book: book,
              isHorizontal: true,
              onTap: () {
                bookProvider.fetchBookByIdAndSelect(book.id);
                Navigator.pushNamed(
                  context,
                  Routes.bookDetails,
                );
              },
            );
          },
        );
      },
    );
  }
}