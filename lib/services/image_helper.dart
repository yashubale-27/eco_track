import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageHelper {

  static Future<String> compressImage(File file) async {

    final compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 20,
      minWidth: 600,
      minHeight: 600,
    );

    return base64Encode(compressed!);
  }
}