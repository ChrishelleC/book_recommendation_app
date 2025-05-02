import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/discussion.dart';
import '../models/reply.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class DiscussionDetailScreen extends StatefulWidget {
  const DiscussionDetailScreen({Key? key}) : super(key: key);

  @override
  State<DiscussionDetailScreen> createState() => _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = Uuid();
  
  Discussion? _discussion;
  List<Reply> _replies = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Discussion) {
      _discussion = args;
      _loadReplies();
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    if (_discussion == null) return;
    setState(() => _isLoading = true);
    try {
      _replies = await _databaseService.getDiscussionReplies(_discussion!.id);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading replies: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _discussion == null) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to reply')),
      );
      return;
    }
    
    setState(() => _isSending = true);
    try {
      final reply = Reply(
        id: _uuid.v4(),
        discussionId: _discussion!.id,
        userId: userProvider.currentUser!.id,
        userDisplayName: userProvider.currentUser!.displayName,
        content: text,
        timestamp: DateTime.now(),
      );
      
      await _databaseService.addReply(reply);
      
      final updatedDiscussion = Discussion(
        id: _discussion!.id,
        bookId: _discussion!.bookId,
        userId: _discussion!.userId,
        userDisplayName: _discussion!.userDisplayName,
        title: _discussion!.title,
        content: _discussion!.content,
        timestamp: _discussion!.timestamp,
        likes: _discussion!.likes,
        replies: _discussion!.replies + 1,
      );
      
      await _databaseService.updateDiscussion(updatedDiscussion);
      
      setState(() {
        _replies.add(reply);
        _discussion = updatedDiscussion;
        _replyController.clear();
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleLike() async {
    if (_discussion == null) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like')),
      );
      return;
    }
    
    try {
      final hasLiked = await _databaseService.hasUserLikedDiscussion(
          _discussion!.id, userProvider.currentUser!.id);
      
      if (hasLiked) {
        await _databaseService.unlikeDiscussion(_discussion!.id, userProvider.currentUser!.id);
        setState(() {
          _discussion = Discussion(
            id: _discussion!.id,
            bookId: _discussion!.bookId,
            userId: _discussion!.userId,
            userDisplayName: _discussion!.userDisplayName,
            title: _discussion!.title,
            content: _discussion!.content,
            timestamp: _discussion!.timestamp,
            likes: _discussion!.likes - 1,
            replies: _discussion!.replies,
          );
        });
      } else {
        await _databaseService.likeDiscussion(_discussion!.id, userProvider.currentUser!.id);
        setState(() {
          _discussion = Discussion(
            id: _discussion!.id,
            bookId: _discussion!.bookId,
            userId: _discussion!.userId,
            userDisplayName: _discussion!.userDisplayName,
            title: _discussion!.title,
            content: _discussion!.content,
            timestamp: _discussion!.timestamp,
            likes: _discussion!.likes + 1,
            replies: _discussion!.replies,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_discussion == null) {
      return const Scaffold(body: Center(child: Text('Discussion not found')));
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: Column(
        children: [
          _buildDiscussionHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRepliesList(),
          ),
          _buildReplyForm(),
        ],
      ),
    );
  }

  Widget _buildDiscussionHeader() {
    return Card(
      margin: const EdgeInsets.all(defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Text(
                    _discussion!.userDisplayName.isNotEmpty
                        ? _discussion!.userDisplayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _discussion!.userDisplayName.isNotEmpty
                            ? _discussion!.userDisplayName : 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat.yMMMd().format(_discussion!.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Text(
              _discussion!.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: smallPadding),
            Text(_discussion!.content),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                InkWell(
                  onTap: _handleLike,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${_discussion!.likes}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Text(
                  '${_replies.length} replies',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesList() {
    if (_replies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: defaultPadding),
            const Text('No replies yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: defaultPadding),
            const Text('Be the first to reply', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      itemCount: _replies.length,
      itemBuilder: (context, index) {
        final reply = _replies[index];
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final canDelete = userProvider.isAuthenticated &&
            userProvider.currentUser!.id == reply.userId;
        
        return Card(
          margin: const EdgeInsets.only(bottom: defaultPadding),
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 16,
                      child: Text(
                        reply.userDisplayName.isNotEmpty
                            ? reply.userDisplayName[0].toUpperCase() : '?',
                        style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: smallPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply.userDisplayName.isNotEmpty
                                ? reply.userDisplayName : 'Anonymous',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            DateFormat.yMMMd().format(reply.timestamp),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (canDelete)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () async {
                          await _databaseService.deleteReply(reply.id);
                          _discussion = Discussion(
                            id: _discussion!.id,
                            bookId: _discussion!.bookId,
                            userId: _discussion!.userId,
                            userDisplayName: _discussion!.userDisplayName,
                            title: _discussion!.title,
                            content: _discussion!.content,
                            timestamp: _discussion!.timestamp,
                            likes: _discussion!.likes,
                            replies: _discussion!.replies - 1,
                          );
                          await _databaseService.updateDiscussion(_discussion!);
                          setState(() => _replies.removeAt(index));
                        },
                      ),
                  ],
                ),
                const SizedBox(height: smallPadding),
                Text(reply.content),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplyForm() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isAuthenticated;
    
    if (!isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(defaultPadding),
        color: Colors.grey[100],
        child: const Center(child: Text('Please log in to reply')),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(width: smallPadding),
          ElevatedButton(
            onPressed: _isSending ? null : _submitReply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
            ),
            child: _isSending
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}