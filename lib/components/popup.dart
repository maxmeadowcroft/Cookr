import 'package:flutter/material.dart';
import '../util/colors.dart'; // Adjust the path if necessary

class PopupDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  final List<Widget> children; // Add children parameter

  const PopupDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    required this.children, // Initialize children
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: Colors.black, width: 4.0), // Add border side
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // Set the width to 90% of the screen width
        ),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.black, width: 4.0), // Add border
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...children, // Add children widgets here
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
