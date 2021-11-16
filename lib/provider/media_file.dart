import 'dart:io';

import 'package:async/async.dart';

enum FileStatus { PENDING, COMPRESSING, UPLOADING, COMPLETED, CANCELED }

class MediaFile {
  String description = "Pending";
  final String type;
  final String path;
  late final File file;
  final int duration;
  FileStatus compressionStatus = FileStatus.PENDING;
  late Stream compressionStatusStream;
  late CancelableCompleter completer;

  MediaFile({
    required this.type,
    required this.path,
    required this.file,
    required this.duration,
    this.compressionStatus = FileStatus.PENDING,
  });

  Stream<MediaFile> init() async* {

    await Future.delayed(Duration(seconds: 3), () => {
          print("pending"),
        });


    compressionStatus = FileStatus.PENDING;
    yield this;

    //yield FileStatus.PENDING;

    await Future.delayed(Duration(seconds: 2), () => {
      print("compressing"),
    });


    compressionStatus = FileStatus.COMPRESSING;

   // yield FileStatus.COMPRESSING;

    await Future.delayed(Duration(seconds: 3), () => {
      print("uploading"),
    });


    compressionStatus = FileStatus.UPLOADING;

    //yield FileStatus.UPLOADING;

    await Future.delayed(Duration(seconds: 3), () => {
      print("completed"),
    });


    compressionStatus = FileStatus.COMPLETED;

    //yield FileStatus.COMPLETED;
  }
}
