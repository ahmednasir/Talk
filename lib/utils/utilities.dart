
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Utils{
  static String getUsername(String email){
    return "live:${email.split('@')[0]}";
  }
  static getInitials(String name){
    List<String> nameSplit = name.split(" ");
    return nameSplit[0][0]+ nameSplit[1][0];
  }

  static Future<File> pickImage({@required ImageSource source}) async{
    File selectedImage = await ImagePicker.pickImage(source: source);
    return compressImage(selectedImage);
  }

  static Future<File> compressImage(File fileToCompress) async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    int random = Random().nextInt(1000000);
    Im.Image image = Im.decodeImage(fileToCompress.readAsBytesSync());
    Im.copyResize(image, width: 500, height: 500);
    return new File('$path/img$random.jpg')..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

  }

}