import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final Function(int)? onDotTapped;

  const DotIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => GestureDetector(
          onTap: () => onDotTapped?.call(index),
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
