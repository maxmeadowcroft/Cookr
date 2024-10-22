import 'package:flutter/material.dart';
// Adjust the path if necessary

class CustomForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const CustomForm({super.key, required this.onSubmit});

  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(color: Colors.grey), // Grey placeholder text
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: const TextStyle(color: Colors.grey), // Grey placeholder text
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onSubmit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
