import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/discussion.dart';
import '../utils/constants.dart';

class DiscussionCard extends StatelessWidget {
  final Discussion discussion;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool canDelete;

  const DiscussionCard({
    Key? key,
    required this.discussion,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardBorderRadius),
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
                      discussion.userDisplayName.isNotEmpty 
                          ? discussion.userDisplayName.substring(0, 1).toUpperCase()
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
                          discussion.userDisplayName.isNotEmpty 
                              ? discussion.userDisplayName 
                              : 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(discussion.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canDelete)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Text(
                discussion.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: smallPadding),
              Text(
                discussion.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${discussion.replies} replies',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${discussion.likes} likes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
