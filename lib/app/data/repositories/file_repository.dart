import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

class FileRepository {
  static final _directory = path_provider.getApplicationDocumentsDirectory();

  static Future<File> _useFile(String fileName) async {
    final directoryPath = (await _directory).path;
    return File(path.join(directoryPath, fileName));
  }

  Future<String?> readFromFile(String fileName) async {
    final file = await _useFile(fileName);

    if (!await file.exists()) {
      return null;
    }

    return await file.readAsString();
  }

  Future<void> writeToFile(String fileName, String contents) async {
    final file = await _useFile(fileName);

    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    await file.writeAsString(contents);
  }
}
