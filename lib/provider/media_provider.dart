import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multimedia_picker/provider/media_cloud_manager.dart';
import 'package:flutter_multimedia_picker/provider/media_file.dart';
import 'package:flutter_multimedia_picker/widgets/media_item_widget.dart';
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

    if(mediaFile.type == 'video') {
      await _cloudManager.compressAndUploadVideoFile(mediaFile, () => null);
    }

  }

  Future<void> clear() async {
    medias.clear();
    notifyListeners();
  }

  Future<void> delete(MediaFile mediaFile) async {
    if(mediaFile.type == 'video'){
      VideoCompress.cancelCompression();
    }
    medias.remove(mediaFile);
    notifyListeners();
  }
}
