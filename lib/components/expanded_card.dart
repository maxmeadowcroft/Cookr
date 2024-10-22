import 'package:flutter/material.dart';

class SlidingPanel extends StatelessWidget {
  final String imageUrl;
  final List<Widget> children;
  final Widget bottomComponent;

  const SlidingPanel({
    super.key,
    required this.imageUrl,
    required this.children,
    required this.bottomComponent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
            child: Center(child: bottomComponent), // Center the bottom component
          ),
        ],
      ),
    );
  }
}
