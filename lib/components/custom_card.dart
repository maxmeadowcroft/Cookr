import 'package:flutter/material.dart';
import '../util/colors.dart';

class CustomCard extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl;
  final String? title; // Made title optional
  final double titleSize;
  final List<Widget> children;
  final double? imageHeight; // Optional parameter for image height
  final EdgeInsetsGeometry padding; // Optional parameter for padding
  final VoidCallback? onTap;
  final bool isAddButton; // New parameter to indicate if this is the add button

  const CustomCard({
    super.key,
    required this.width,
    required this.height,
    this.imageUrl,
    this.title, // title is now optional
    this.titleSize = 24, // Default title size
    required this.children,
    this.imageHeight, // Initialize imageHeight
    this.padding = const EdgeInsets.all(8.0), // Default padding
    this.onTap,
    this.isAddButton = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    double paddingValue = width * 0.03; // 5% of width for padding
    EdgeInsetsGeometry dynamicPadding = EdgeInsets.all(paddingValue);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6.0,
        margin: const EdgeInsets.all(8.0), // Adjusted to make cards slightly shorter
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: Colors.black, width: 4), // Black border
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: dynamicPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
              children: [
                if (imageUrl != null && !isAddButton)
                  Padding(
                    padding: EdgeInsets.only(top: paddingValue, left: paddingValue, right: paddingValue), // Reduced padding
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.0), // Slightly smaller radius to show the border
                        child: Image.network(
                          imageUrl!,
                          width: width - 2 * paddingValue, // Adjust width for padding
                          height: imageHeight ?? height * 0.4, // Use imageHeight if provided, otherwise default to 40% of card height
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/placeholder.jpg',
                            width: width - 2 * paddingValue,
                            height: imageHeight ?? height * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (title != null)
                  Padding(
                    padding: EdgeInsets.all(paddingValue), // Adjusted padding
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: isAddButton ? 64 : titleSize, // Increase font size for the add button
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center, // Center the text
                    ),
                  ),
                if (!isAddButton)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: paddingValue), // Adjusted padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
