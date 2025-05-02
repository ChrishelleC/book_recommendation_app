import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/discussion_provider.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';
import '../widgets/discussion_card.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/routes.dart';

class DiscussionScreen extends StatefulWidget {
  const DiscussionScreen({Key? key}) : super(key: key);

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isAddingDiscussion = false;
  String? _bookId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllDiscussions();
    });
  }

  Future<void> _loadAllDiscussions() async {
    if (!_isInitialized) {
      final discussionProvider = Provider.of<DiscussionProvider>(context, listen: false);
      try {
        await discussionProvider.fetchAllDiscussions();
        setState(() {
          _isInitialized = true;
        });
      } catch (e) {
        print('Error loading discussions: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is String) {
      _bookId = args;
      _isAddingDiscussion = false;
      
      Provider.of<DiscussionProvider>(context, listen: false)
          .fetchBookDiscussions(_bookId!);
    } else if (args is Map<String, dynamic>) {
      _bookId = args['bookId'] as String;
      _isAddingDiscussion = args['isAdding'] as bool? ?? false;
      
      if (_bookId != null) {
        Provider.of<DiscussionProvider>(context, listen: false)
            .fetchBookDiscussions(_bookId!);
      }
    } else if (!_isInitialized) {
      _loadAllDiscussions();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitDiscussion() async {
    if (_formKey.currentState?.validate() ?? false) {
      final discussionProvider = Provider.of<DiscussionProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (!userProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to start a discussion'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final targetBookId = _bookId ?? 'general';
      
      await discussionProvider.addDiscussion(
        bookId: targetBookId,
        userId: userProvider.currentUser!.id,
        userDisplayName: userProvider.currentUser!.displayName,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );
      
      if (discussionProvider.error.isEmpty) {
        _titleController.clear();
        _contentController.clear();
        
        setState(() {
          _isAddingDiscussion = false;
        });
        
        if (_bookId != null) {
          discussionProvider.fetchBookDiscussions(_bookId!);
        } else {
          discussionProvider.fetchAllDiscussions();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discussion started successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${discussionProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
        discussionProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isAuthenticated;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAddingDiscussion ? 'Start a Discussion' : 'Discussions'),
        actions: [
          if (!_isAddingDiscussion && isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isAddingDiscussion = true;
                });
              },
            ),
        ],
      ),
      body: _isAddingDiscussion
          ? _buildDiscussionForm(isLoggedIn)
          : _buildDiscussionsList(isLoggedIn),
    );
  }

  Widget _buildDiscussionForm(bool isLoggedIn) {
    if (!isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please log in to start a discussion',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_bookId != null)
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
                        'Discussion for: ${book.title}',
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
              'Discussion Title',
              style: subheadingStyle,
            ),
            const SizedBox(height: smallPadding),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter a title for your discussion',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateDiscussionTitle,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: defaultPadding),
            const Text(
              'Discussion Content',
              style: subheadingStyle,
            ),
            const SizedBox(height: smallPadding),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts or questions...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: Validators.validateReviewContent,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: largePadding),
            Consumer<DiscussionProvider>(
              builder: (context, discussionProvider, child) {
                return CustomButton(
                  text: 'Start Discussion',
                  onPressed: _submitDiscussion,
                  isLoading: discussionProvider.isLoading,
                );
              },
            ),
            const SizedBox(height: smallPadding),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isAddingDiscussion = false;
                  });
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDiscussionsList(bool isLoggedIn) {
    return Consumer<DiscussionProvider>(
      builder: (context, discussionProvider, child) {
        if (discussionProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (discussionProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${discussionProvider.error}'),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                  onPressed: () {
                    discussionProvider.clearError();
                    if (_bookId != null) {
                      discussionProvider.fetchBookDiscussions(_bookId!);
                    } else {
                      discussionProvider.fetchAllDiscussions();
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (discussionProvider.discussions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: defaultPadding),
                const Text(
                  'No discussions yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: defaultPadding),
                if (isLoggedIn)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingDiscussion = true;
                      });
                    },
                    child: const Text('Start a Discussion'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.login);
                    },
                    child: const Text('Log in to Start a Discussion'),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(defaultPadding),
          itemCount: discussionProvider.discussions.length,
          itemBuilder: (context, index) {
            final discussion = discussionProvider.discussions[index];
            final canDelete = isLoggedIn &&
                Provider.of<UserProvider>(context, listen: false).currentUser!.id == discussion.userId;
            
            return DiscussionCard(
                discussion: discussion,
                canDelete: canDelete,
                onTap: () async {
  // Navigate to discussion details and wait for result
  await Navigator.pushNamed(
    context,
    Routes.discussionDetail,
    arguments: discussion,
  );
  
  // Refresh discussions when returning from detail screen
  if (_bookId != null) {
    Provider.of<DiscussionProvider>(context, listen: false)
        .fetchBookDiscussions(_bookId!);
  } else {
    Provider.of<DiscussionProvider>(context, listen: false)
        .fetchAllDiscussions();
  }
},
                onDelete: canDelete
      ? () async {
          await discussionProvider
              .deleteDiscussion(discussion.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Discussion deleted'),
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