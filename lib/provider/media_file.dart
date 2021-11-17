import 'dart:io';

import 'package:async/async.dart';

enum FileStatus { PENDING, COMPRESSING, UPLOADING, COMPLETED, CANCELED }

class FileType{
  static const String IMAGE = "image";
  static const String VIDEO = "video";
}

class MediaFile {
  String description = "Pendiente";
  final String type;
  final String path;
  late File file;
  final int duration;
  late FileStatus status = FileStatus.PENDING;
  late Stream compressionStatusStream;
  late CancelableCompleter completer;
  late double aspectRatio = 0;

  MediaFile({
    required this.type,
    required this.path,
    required this.file,
    required this.duration,
    this.status = FileStatus.PENDING,
  });

  Stream<MediaFile> init() async* {

    await Future.delayed(Duration(seconds: 3), () => {
          print("pending"),
        });


    status = FileStatus.PENDING;
    yield this;

    //yield FileStatus.PENDING;

    await Future.delayed(Duration(seconds: 2), () => {
      print("compressing"),
    });


    status = FileStatus.COMPRESSING;

   // yield FileStatus.COMPRESSING;

    await Future.delayed(Duration(seconds: 3), () => {
      print("uploading"),
    });


    status = FileStatus.UPLOADING;

    //yield FileStatus.UPLOADING;

    await Future.delayed(Duration(seconds: 3), () => {
      print("completed"),
    });


    status = FileStatus.COMPLETED;

    //yield FileStatus.COMPLETED;
  }
}
