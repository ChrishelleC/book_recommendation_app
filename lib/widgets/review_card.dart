import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import 'rating_widget.dart';
import '../utils/constants.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;
  final bool canDelete;

  const ReviewCard({
    Key? key,
    required this.review,
    this.onLike,
    this.onDelete,
    this.canDelete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
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
                    review.userDisplayName.isNotEmpty
                        ? review.userDisplayName.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userDisplayName.isNotEmpty 
                            ? review.userDisplayName 
                            : 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(review.timestamp),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingWidget(
                  rating: review.rating,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: smallPadding),
            Text(
              review.content,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('${review.likes}'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: smallPadding,
                    ),
                  ),
                ),
                if (canDelete)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: smallPadding,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}