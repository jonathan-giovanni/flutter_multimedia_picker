import 'dart:math';

import 'package:uuid/uuid.dart';

class AppUtil {

  static String mediaType(String path){
    if(path.toLowerCase().contains("video")){
      return "video";
    }
    return "image";
  }

  //generate uuid without r '-'
  static String generateUUID() {
    var uuid = const Uuid();
    return uuid.v4().replaceAll("-", "");
  }

}
