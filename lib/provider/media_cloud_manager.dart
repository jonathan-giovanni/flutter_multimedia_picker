import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_multimedia_picker/util/app_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'media_file.dart';

class MediaCloudManager {


  Future<File?> compressAndUploadImageFile(
    MediaFile media,
    Function() progressIndicatorFunction,
  ) async {
    print('compressAndUploadImageFile');
    print(media.type + '-----------------------------------');
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.absolute.path;

    final name = AppUtil.generateUUID();
    tempPath += '/$name.jpg';

    print(media.file.absolute.path + ' ABSOLUTE PATH');
    print(tempPath + ' TEMPATH');

    final result = await FlutterImageCompress.compressAndGetFile(
      media.file.absolute.path,
      tempPath,
      quality: 60,
    );

    print('result $result');

    return result;
  }

  Future<void> compressAndUploadVideoFile(
    MediaFile media,
    Function() progressIndicatorFunction,
  ) async {

    print('compressAndUploadVideoFile');
    print(media.type + '-----------------------------------');

    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      media.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );

    media.file = File(mediaInfo!.path!);
    print('MediaInfo: ${mediaInfo.toJson()}');
    final aspectRatio = mediaInfo.height! / mediaInfo.width!;
    print('completed: ' + media.path);

    return;
  }

}
