// ignore_for_file: prefer_const_constructors_in_immutables, must_be_immutable

import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  RatingStars({
    required this.rating,
    super.key,
    this.iconSize = 30,
    this.color = Colors.amber,
    this.stars = 3,
  });

  final double iconSize;
  final Color color;
  final double rating;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          stars,
          (index) => Icon(
            Icons.star_rate_rounded,
            size: iconSize,
            color: rating > index ? color : Colors.grey,
          ),
        ),
      ),
    );
  }
}
