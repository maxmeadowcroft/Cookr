import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReplacePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Replace',
          style: GoogleFonts.encodeSans(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          'This is the Replace page.',
          style: GoogleFonts.encodeSans(
            textStyle: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}