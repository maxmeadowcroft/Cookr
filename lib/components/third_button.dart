import 'package:flutter/material.dart';
import '../util/colors.dart';

class ThirdButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ThirdButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textColor,
        backgroundColor: AppColors.thirdButtonColor, // Use color from palette
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          side: const BorderSide(color: AppColors.textColor, width: 2), // Black border
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
