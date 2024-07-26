import 'package:flutter/material.dart';
import '../util/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.buttonTextColor,
        backgroundColor: AppColors.buttonColor, // Use color from palette
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        shadowColor: Colors.black.withOpacity(0.25), // Shadow color
        elevation: 4, // Elevation value for the shadow
      ),
      child: Text(text),
    );
  }
}
