import 'dart:async';
import 'dart:io';

class MockPathProvider {
  static Future<Directory> getApplicationDocumentsDirectory() async {
    return Directory.systemTemp.createTemp();
  }
}
