import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/book_provider.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../models/review.dart';
import '../widgets/review_card.dart';
import '../widgets/rating_widget.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _reviewController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  double _rating = 0;
  bool _isSubmitting = false;
  List<Review> _reviews = [];
  bool _isLoading = true;
  String _error = '';
  bool _isAddingReview = false;
  String? _bookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is String) {
      _bookId = args;
      _isAddingReview = false;
    } else if (args is Map<String, dynamic>) {
      _bookId = args['bookId'] as String;
      _isAddingReview = args['isAdding'] as bool? ?? false;
    }
    
    if (_bookId != null) {
      _loadReviews(_bookId!);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews(String bookId) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final reviews = await _databaseService.getBookReviews(bookId);
      
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (!userProvider.isAuthenticated || _bookId == null) {
        setState(() {
          _isSubmitting = false;
          _error = 'You must be logged in to submit a review';
        });
        return;
      }
      
      try {
        final review = Review(
          id: const Uuid().v4(),
          bookId: _bookId!,
          userId: userProvider.currentUser!.id,
          userDisplayName: userProvider.currentUser!.displayName,
          rating: _rating,
          content: _reviewController.text.trim(),
          timestamp: DateTime.now(),
        );
                await _databaseService.addReview(review);
        
        setState(() {
          _reviews.insert(0, review);
          _reviewController.clear();
          _rating = 0;
          _isSubmitting = false;
          _isAddingReview = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        setState(() {
          _isSubmitting = false;
          _error = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAddingReview ? 'Write a Review' : 'Reviews'),
        actions: [
          if (!_isAddingReview)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isAddingReview = true;
                });
              },
            ),
        ],
      ),
      body: _isAddingReview ? _buildReviewForm() : _buildReviewsList(),
    );
  }

  Widget _buildReviewForm() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isAuthenticated) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Please log in to submit a review',
                  style: subheadingStyle,
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<BookProvider>(
                  builder: (context, bookProvider, child) {
                    final book = bookProvider.selectedBook;
                    
                    if (book == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review for: ${book.title}',
                          style: subheadingStyle,
                        ),
                        Text(
                          'by ${book.author}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                      ],
                    );
                  },
                ),
                const Text(
                  'Your Rating',
                  style: subheadingStyle,
                ),
                const SizedBox(height: smallPadding),
                Center(
                  child: RatingWidget(
                    rating: _rating,
                    size: 40,
                    isInteractive: true,
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: defaultPadding),
                const Text(
                  'Your Review',
                  style: subheadingStyle,
                ),
                const SizedBox(height: smallPadding),
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts about this book...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: Validators.validateReviewContent,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: largePadding),
                CustomButton(
                  text: 'Submit Review',
                  onPressed: _submitReview,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: smallPadding),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isAddingReview = false;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                if (_bookId != null) {
                  _loadReviews(_bookId!);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAddingReview = true;
                });
              },
              child: const Text('Be the first to review'),
            ),
          ],
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            final canDelete = userProvider.isAuthenticated &&
                userProvider.currentUser!.id == review.userId;
            
            return ReviewCard(
              review: review,
              canDelete: canDelete,
              onLike: () {
              },
              onDelete: canDelete
                  ? () async {
                      await _databaseService.deleteReview(review.id);
                      setState(() {
                        _reviews.removeAt(index);
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Review deleted'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}