import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MockPathProvider {
  static Future<Directory> getApplicationDocumentsDirectory() async {
    return Directory.systemTemp.createTemp();
  }
}
