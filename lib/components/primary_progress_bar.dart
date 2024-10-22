import 'package:flutter/material.dart';
import '../util/colors.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Progress value from 0 to 1
  final double height;
  final double width;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    double progressWidth = (progress * (width - 4.0)).clamp(0.0, width - 4.0); // Adjust for border width

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black, width: 2.0), // Border for the whole progress bar
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Adjust border radius for inner content
        child: Stack(
          children: [
            Container(
              width: progressWidth, // Adjust based on provided width
              decoration: BoxDecoration(
                color: AppColors.buttonColor, // Adjust color as needed
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8.0),
                  bottomLeft: const Radius.circular(8.0),
                  topRight: progress == 1.0 ? const Radius.circular(8.0) : Radius.zero,
                  bottomRight: progress == 1.0 ? const Radius.circular(8.0) : Radius.zero,
                ),
                border: progress == 1.0 ? null : const Border(
                  right: BorderSide(color: Colors.black, width: 2.0), // Border for the right side of the progress fill only if not full
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
