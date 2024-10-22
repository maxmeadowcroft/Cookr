import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/colors.dart';

class CustomCalendarWeek extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final DateTime startDate;
  final DateTime endDate;

  const CustomCalendarWeek({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.startDate,
    required this.endDate,
  });

  @override
  _CustomCalendarWeekState createState() => _CustomCalendarWeekState();
}

class _CustomCalendarWeekState extends State<CustomCalendarWeek> {
  late DateTime _selectedDate;
  late DateTime _currentStartDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentStartDate = widget.initialDate.subtract(Duration(days: widget.initialDate.weekday - 1));
  }

  void _selectPreviousWeek() {
    setState(() {
      _currentStartDate = _currentStartDate.subtract(const Duration(days: 7));
    });
  }

  void _selectNextWeek() {
    setState(() {
      _currentStartDate = _currentStartDate.add(const Duration(days: 7));
    });
  }

  Widget _buildDateButton(DateTime date) {
    bool isSelected = date == _selectedDate;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        widget.onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            Text(
              DateFormat.E().format(date),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black45),
            ),
            Text(
              DateFormat.d().format(date),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentStartDate.isAfter(widget.startDate) ? _selectPreviousWeek : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    DateTime date = _currentStartDate.add(Duration(days: index));
                    return (date.isAfter(widget.startDate.subtract(const Duration(days: 1))) && date.isBefore(widget.endDate.add(const Duration(days: 1))))
                        ? _buildDateButton(date)
                        : Container();
                  }),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentStartDate.isBefore(widget.endDate.subtract(const Duration(days: 6))) ? _selectNextWeek : null,
            ),
          ],
        ),
      ],
    );
  }
}
