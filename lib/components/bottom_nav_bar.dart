import 'package:flutter/material.dart';
import '../util/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<IconData> icons;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.icons,
    required this.onTap, required Color backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 15, left: 10, right: 10), // Add padding to the top and bottom
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: icons.asMap().entries.map((entry) {
          int index = entry.key;
          IconData icon = entry.value;
          return IconButton(
            iconSize: 40, // Set icon size to 40x40
            icon: Icon(
              icon,
              color: index == currentIndex ? Colors.black : Colors.grey,
            ),
            onPressed: () => onTap(index),
          );
        }).toList(),
      ),
    );
  }
}
