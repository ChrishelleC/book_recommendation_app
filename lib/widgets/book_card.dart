import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../utils/constants.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final bool isHorizontal;

  const BookCard({
    Key? key,
    required this.book,
    required this.onTap,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    } else {
      return _buildVerticalCard(context);
    }
  }

  Widget _buildVerticalCard(BuildContext context) {
    // Print for debugging
    print('Book cover URL for ${book.title}: ${book.coverUrl}');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardBorderRadius),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl.isNotEmpty
                      ? book.coverUrl
                      : fallbackBookCoverUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Add caching parameters
                  maxHeightDiskCache: 1500,
                  memCacheWidth: 600,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    // Print the error for debugging
                    print('Error loading image from URL: $url - Error: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 40),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: smallPadding),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    // Print for debugging
    print('Book cover URL for ${book.title} (horizontal): ${book.coverUrl}');
    
    return Card(
      margin: const EdgeInsets.only(bottom: smallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius),
                bottomLeft: Radius.circular(cardBorderRadius),
              ),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl.isNotEmpty
                    ? book.coverUrl
                    : fallbackBookCoverUrl,
                fit: BoxFit.cover,
                width: 100,
                height: 150,
                // Add caching parameters
                maxHeightDiskCache: 1500,
                memCacheWidth: 600,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  width: 100,
                  height: 150,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) {
                  // Print the error for debugging
                  print('Error loading horizontal image from URL: $url - Error: $error');
                  return Container(
                    color: Colors.grey[300],
                    width: 100,
                    height: 150,
                    child: const Icon(Icons.book, size: 40),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (book.averageRating > 0) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              Text(
                                book.averageRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                        Text(
                          book.genre,
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
          ],
        ),
      ),
    );
  }
}