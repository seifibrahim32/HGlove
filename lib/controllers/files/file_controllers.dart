import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

Future<String?> filePicker(BuildContext context) async {
  FilePickerResult? result;
  try {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpeg',
        'png'
      ],
    );
  } catch (e) {
    log(e.toString());
  }
  if (result != null) {
    //Returns the file path to store it into Firebase
    File file = File(result.files.single.path!);
    log('File ${file.path}');
    return file.path;
  } else {
    // User canceled the picker
    return null;
  }
}
