import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final String initialValue;
  final Function(String) onChanged;
  final double width; // Custom width

  const CustomDropdown({
    super.key,
    required this.options,
    required this.initialValue,
    required this.onChanged,
    this.width = 200.0, // Default width
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          iconSize: 24,
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white, // Background color of dropdown items
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue!;
            });
            widget.onChanged(newValue!);
          },
          items: widget.options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.black), // Ensure black text
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
