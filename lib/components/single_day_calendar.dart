import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../util/colors.dart';

class SingleDayCalendarIcon extends StatelessWidget {
  final DateTime date;
  final bool isSelected;

  const SingleDayCalendarIcon({
    super.key,
    required this.date,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.buttonColor : Colors.transparent,
        borderRadius: BorderRadius.circular(30.0), // High border radius for oval shape
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              DateFormat.E().format(date),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black45),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0), // Adjusted padding for top and bottom
            decoration: BoxDecoration(
              color: isSelected ? AppColors.buttonColor : Colors.transparent,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              DateFormat.d().format(date),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
