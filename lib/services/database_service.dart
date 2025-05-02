import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../models/reading_list.dart';
import '../models/book.dart';
import '../utils/constants.dart';
import '../models/discussion.dart';
import '../models/reply.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Future<User> getUserById(String userId) async {
    final doc = await _firestore.collection(usersCollection).doc(userId).get();
    
    if (!doc.exists) {
      throw Exception('User not found');
    }
    
    return User.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Future<void> createUser(User user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(user.toJson());
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection(usersCollection).doc(user.id).update(user.toJson());
  }
  
  Future<void> updateUserDisplayNameInPosts(String userId, String newDisplayName) async {
    final discussionSnapshot = await _firestore
        .collection(discussionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    final replySnapshot = await _firestore
        .collection('replies')
        .where('userId', isEqualTo: userId)
        .get();
    
    final reviewSnapshot = await _firestore
        .collection(reviewsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    final batch = _firestore.batch();
        for (var doc in discussionSnapshot.docs) {
      batch.update(doc.reference, {'userDisplayName': newDisplayName});
    }
    
    for (var doc in replySnapshot.docs) {
      batch.update(doc.reference, {'userDisplayName': newDisplayName});
    }
        for (var doc in reviewSnapshot.docs) {
      batch.update(doc.reference, {'userDisplayName': newDisplayName});
    }
        await batch.commit();
  }

  Future<List<Review>> getBookReviews(String bookId) async {
    final snapshot = await _firestore
        .collection(reviewsCollection)
        .where('bookId', isEqualTo: bookId)
        .get();
    
    final reviews = snapshot.docs.map((doc) {
      return Review.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    
    reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return reviews;
  }

  Future<void> addReview(Review review) async {
    await _firestore.collection(reviewsCollection).doc(review.id).set(review.toJson());
  }

  Future<void> updateReview(Review review) async {
    await _firestore.collection(reviewsCollection).doc(review.id).update(review.toJson());
  }

  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection(reviewsCollection).doc(reviewId).delete();
  }
    Future<List<ReadingListItem>> getUserReadingList(String userId, ReadingStatus status) async {
    final snapshot = await _firestore
        .collection(readingListsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status.name)
        .get();
    
    final items = snapshot.docs.map((doc) {
      return ReadingListItem.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    
    items.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    return items;
  }

  Future<void> addToReadingList(ReadingListItem item) async {
    await _firestore.collection(readingListsCollection).doc(item.id).set(item.toJson());
  }

  Future<void> updateReadingListItem(ReadingListItem item) async {
    await _firestore.collection(readingListsCollection).doc(item.id).update(item.toJson());
  }

  Future<void> removeFromReadingList(String itemId) async {
    await _firestore.collection(readingListsCollection).doc(itemId).delete();
  }
    Future<List<Discussion>> getBookDiscussions(String bookId) async {
    final snapshot = await _firestore
        .collection(discussionsCollection)
        .where('bookId', isEqualTo: bookId)
        .get();
    
    final discussions = snapshot.docs.map((doc) {
      return Discussion.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    
    discussions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return discussions;
  }
  
  Future<List<Discussion>> getAllDiscussions() async {
    final snapshot = await _firestore
        .collection(discussionsCollection)
        .get();
    
    final discussions = snapshot.docs.map((doc) {
      return Discussion.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    
    discussions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return discussions;
  }

  Future<void> addDiscussion(Discussion discussion) async {
    await _firestore.collection(discussionsCollection).doc(discussion.id).set(discussion.toJson());
  }

  Future<void> updateDiscussion(Discussion discussion) async {
    await _firestore.collection(discussionsCollection).doc(discussion.id).update(discussion.toJson());
  }

  Future<void> deleteDiscussion(String discussionId) async {
    await _firestore.collection(discussionsCollection).doc(discussionId).delete();
  }
    Future<List<Reply>> getDiscussionReplies(String discussionId) async {
    final snapshot = await _firestore
        .collection('replies')
        .where('discussionId', isEqualTo: discussionId)
        .get();
    
    final replies = snapshot.docs.map((doc) {
      return Reply.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    
    replies.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return replies;
  }

  Future<void> addReply(Reply reply) async {
    await _firestore.collection('replies').doc(reply.id).set(reply.toJson());
  }

  Future<void> deleteReply(String replyId) async {
    await _firestore.collection('replies').doc(replyId).delete();
  }
    Future<bool> hasUserLikedDiscussion(String discussionId, String userId) async {
    final snapshot = await _firestore
        .collection('discussion_likes')
        .where('discussionId', isEqualTo: discussionId)
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  Future<void> likeDiscussion(String discussionId, String userId) async {
    final likeId = '$discussionId-$userId';
    
    await _firestore.collection('discussion_likes').doc(likeId).set({
      'discussionId': discussionId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    await _firestore.collection(discussionsCollection).doc(discussionId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> unlikeDiscussion(String discussionId, String userId) async {
    final likeId = '$discussionId-$userId';
    
    await _firestore.collection('discussion_likes').doc(likeId).delete();
    
    await _firestore.collection(discussionsCollection).doc(discussionId).update({
      'likes': FieldValue.increment(-1),
    });
  }
  
  Future<bool> hasUserLikedReply(String replyId, String userId) async {
    final snapshot = await _firestore
        .collection('reply_likes')
        .where('replyId', isEqualTo: replyId)
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }
  
  Future<void> likeReply(String replyId, String userId) async {
    final likeId = '$replyId-$userId';
    
    await _firestore.collection('reply_likes').doc(likeId).set({
      'replyId': replyId,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    await _firestore.collection('replies').doc(replyId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> unlikeReply(String replyId, String userId) async {
    final likeId = '$replyId-$userId';
    
    await _firestore.collection('reply_likes').doc(likeId).delete();
    
    await _firestore.collection('replies').doc(replyId).update({
      'likes': FieldValue.increment(-1),
    });
  }
    Future<List<ReadingListItem>> getUserCompletedBooks(String userId) async {
    return await getUserReadingList(userId, ReadingStatus.finished);
  }
  
  Future<List<Review>> getUserReviews(String userId) async {
    final snapshot = await _firestore
        .collection(reviewsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    final reviews = snapshot.docs.map((doc) {
      return Review.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
    
    reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return reviews;
  }
}