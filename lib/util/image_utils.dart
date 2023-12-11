import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as image_library;

class ImageUtils {
  static Future<String?> compressImage(String path, double length, int quality) async {

    if (File(path).lengthSync() < length) {
      return path;
    }

    if (quality <= 10) {
      return path;
    }

    String targetPath = "${(await getApplicationDocumentsDirectory()).path}/compressImg.jpeg";
    if (File(targetPath).existsSync()) {
      File(targetPath).deleteSync();
    }

    XFile? imageFile =  await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: quality,
      // minHeight: 1000,
      // minWidth: 1000
      // minHeight: 768,
      // minWidth: 768
    );
    if (imageFile == null) return null;

    debugPrint('压缩前 length: \n ${(File(path).lengthSync() / (1024 * 1024))}');
    debugPrint('压缩后 length: \n ${(File(imageFile.path).lengthSync() / (1024 * 1024))}');

    if ((await imageFile.length()) > length) {
      quality -= 1;
      return compressImage(path, length, quality);
    } else {
      return imageFile.path;
    }

  }

  // static Future<String> reSizeImage(String filePath) async {
  //
  //   var image = image_library.decodeImage(File(filePath).readAsBytesSync());
  //
  //   if (image!.width < 768 || image.height < 768) {
  //     final scaleW = image.width / 768;
  //     final scaleH = image.height / 768;
  //     if (max(scaleW, scaleH) == scaleW) {
  //       image = image_library.copyResize(image,
  //           width: (image.width * scaleW).toInt(),
  //           height: (image.height * scaleW).toInt());
  //     } else {
  //       //
  //       image = image_library.copyResize(image,
  //           width: (image.width * scaleH).toInt(),
  //           height: (image.height * scaleH).toInt());
  //     }
  //   }
  //
  //   // image_picker 已限制
  //   // if (image.width > 2048 || image.height > 2048) {
  //   //   final scaleW = 2048 / image.width;
  //   //   final scaleH = 2048 / image.height;
  //   //   if (min(scaleW, scaleH) == scaleW) {
  //   //     image = image_library.copyResize(image,
  //   //         width: (image.width * scaleW).toInt(),
  //   //         height: (image.height * scaleW).toInt());
  //   //   } else {
  //   //     image = image_library.copyResize(image,
  //   //         width: (image.width * scaleH).toInt(),
  //   //         height: (image.height * scaleH).toInt());
  //   //   }
  //   // }
  //
  //   debugPrint('image width: ${image.width}, height: ${image.height}');
  //
  //   String resizePath = "${(await getApplicationDocumentsDirectory()).path}/resize.jpeg";
  //
  //   File file = File(resizePath);
  //
  //   if (file.existsSync()) {
  //     file.deleteSync();
  //   }
  //
  //   File newFile = await file.writeAsBytes(image_library.encodeJpg(image));
  //
  //   debugPrint('newFile path: ${newFile.path}');
  //
  //   return newFile.path;
  //
  // }

}