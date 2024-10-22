import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/colors.dart';
import '../components/primary_button.dart';

class CustomFullPageCalendar extends StatefulWidget {
  final Function(List<DateTime>) onSelectedDates;

  const CustomFullPageCalendar({required this.onSelectedDates, super.key});

  @override
  _CustomFullPageCalendarState createState() => _CustomFullPageCalendarState();
}

class _CustomFullPageCalendarState extends State<CustomFullPageCalendar> {
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_selectedStartDate.year, _selectedStartDate.month);
  }

  void _selectPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _selectNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      if (_selectedEndDate != null) {
        _selectedStartDate = date;
        _selectedEndDate = null;
      } else if (date.isBefore(_selectedStartDate)) {
        _selectedStartDate = date;
      } else {
        _selectedEndDate = date;
      }
    });
  }

  bool _isInRange(DateTime date) {
    if (_selectedEndDate == null) return date == _selectedStartDate;
    return date.isAfter(_selectedStartDate) && date.isBefore(_selectedEndDate!) ||
        date == _selectedStartDate ||
        date == _selectedEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _selectPreviousMonth,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat.yMMMM().format(_currentMonth),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _selectNextMonth,
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day,
              itemBuilder: (context, index) {
                DateTime date = DateTime(_currentMonth.year, _currentMonth.month, index + 1);
                bool isSelected = _isInRange(date);

                return GestureDetector(
                  onTap: () => _onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.buttonColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: isSelected ? AppColors.buttonColor : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat.d().format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              text: 'Print Selected Dates',
              onPressed: () {
                List<DateTime> selectedDates = [];
                if (_selectedEndDate != null) {
                  for (DateTime date = _selectedStartDate;
                  date.isBefore(_selectedEndDate!.add(const Duration(days: 1)));
                  date = date.add(const Duration(days: 1))) {
                    selectedDates.add(date);
                  }
                } else {
                  selectedDates.add(_selectedStartDate);
                }
                widget.onSelectedDates(selectedDates);
              },
            ),
          ),
        ],
      ),
    );
  }
}
