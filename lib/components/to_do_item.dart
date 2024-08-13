import 'package:flutter/material.dart';
import '../util/colors.dart'; // Import the AppColors

class TodoItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onToggle;

  const TodoItem({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0), // Adjust padding to reduce space between items
      child: ListTile(
        contentPadding: EdgeInsets.zero, // Remove default padding
        leading: GestureDetector(
          onTap: onToggle,
          child: Container(
            height: 40.0, // Make the checkbox larger and more square
            width: 40.0, // Make the checkbox larger and more square
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.buttonColor : Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0), // Adjust for rounded corners
            ),
            child: isCompleted
                ? Icon(
              Icons.check,
              size: 24.0, // Adjust the size of the check icon
              color: Colors.white,
            )
                : null,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            color: isCompleted ? Colors.grey : Colors.black,
            fontSize: 18.0, // Adjust font size for better visibility
          ),
        ),
      ),
    );
  }
}
