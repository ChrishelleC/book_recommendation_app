import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final ValueChanged<double>? onRatingUpdate;

  const RatingWidget({
    Key? key,
    this.rating = 0,
    this.size = 24,
    this.isInteractive = false,
    this.onRatingUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive
              ? () {
                  if (onRatingUpdate != null) {
                    onRatingUpdate!(index + 1);
                  }
                }
              : null,
          child: Icon(
            index < rating.floor()
                ? Icons.star
                : (index < rating.ceil() && index >= rating.floor())
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}
