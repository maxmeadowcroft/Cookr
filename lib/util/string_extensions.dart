// string_extensions.dart
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String truncateWithEllipsis(int maxLength) {
    return (this.length <= maxLength) ? this : '${this.substring(0, maxLength)}...';
  }
}
