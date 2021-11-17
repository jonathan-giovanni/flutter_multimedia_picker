import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_multimedia_picker/provider/media_cloud_manager.dart';
import 'package:flutter_multimedia_picker/provider/media_file.dart';
import 'package:flutter_multimedia_picker/util/app_util.dart';
import 'package:flutter_multimedia_picker/widgets/media_item_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class MediaProvider extends ChangeNotifier {
  final MediaCloudManager _cloudManager = MediaCloudManager();

  //create empty constructor
  MediaProvider() {
    print('MediaProvider constructor');
  }

  List<MediaFile> medias = [];

  Future<void> addMedia(MediaFile mediaFile) async {
    medias.add(mediaFile);
    notifyListeners();
    processMediaFile(mediaFile);
  }

  Future<void> processMediaFile(MediaFile mediaFile) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.absolute.path;

    if (mediaFile.type == FileType.VIDEO) {
      //check if video is not status COMPRESSING
      if (!VideoCompress.isCompressing) {
        print('is not compressing');

        mediaFile.status = FileStatus.COMPRESSING;
        mediaFile.description = "comprimiendo video";
        notifyListeners();

        print('compressing now');
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          mediaFile.path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
        );
        if (mediaInfo == null || mediaInfo.path == null) {
          print('stopped video compression');
          mediaFile.status = FileStatus.CANCELED;
          mediaFile.description = "compresión detenida";
          notifyListeners();
          return;
        }
        mediaFile.file = File(mediaInfo.path!);
        print('MediaInfo: ${mediaInfo.toJson()}');
        mediaFile.aspectRatio = mediaInfo.height! / mediaInfo.width!;

        print('compressing ended');
        mediaFile.status = FileStatus.COMPLETED;
        mediaFile.description = "completado";
        notifyListeners();

        //check for other videos
        medias.forEach((media) {
          if (media.type == FileType.VIDEO && media.status == FileStatus.PENDING) {
            processMediaFile(media);
            return;
          }
        });

      } else {
        print('await compress');
      }
    } else {
      print('compressing image');

      mediaFile.description = "comprimiendo imagen";
      mediaFile.status = FileStatus.COMPRESSING;

      notifyListeners();

      final name = AppUtil.generateUUID();
      tempPath += '/$name.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        mediaFile.file.absolute.path,
        tempPath,
        quality: 60,
      );

      if (result == null) {
        print('stopped image compression');
        return;
      }

      mediaFile.file = result;
      mediaFile.description = "completado";
      mediaFile.status = FileStatus.COMPLETED;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    medias.clear();
    notifyListeners();
  }

  _stopProcessing(MediaFile mediaFile) async {
    if (mediaFile.type == FileType.VIDEO) {
      if (VideoCompress.isCompressing) {
        print('cancel video compress');
        VideoCompress.cancelCompression();
      }
    } else {
      if (mediaFile.type == FileType.IMAGE &&
          mediaFile.status == FileStatus.UPLOADING) {
        print('cancel compress');
      }
    }
  }

  Future<void> delete(MediaFile mediaFile) async {
    //find mediaFile in medias list
    final i = medias.indexWhere((m) => m == mediaFile);
    if (i >= 0) {
      _stopProcessing(medias[i]);
      medias.removeAt(i);
      notifyListeners();
    }
  }

  Future<void> cancelUpload(MediaFile mediaFile) async {
    _stopProcessing(mediaFile);
    mediaFile.status = FileStatus.CANCELED;
    mediaFile.description = "cancelado";
    notifyListeners();
  }

  void retryUpload(MediaFile mediaFile) {
    processMediaFile(mediaFile);
  }
}
