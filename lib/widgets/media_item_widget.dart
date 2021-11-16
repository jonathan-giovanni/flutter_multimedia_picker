import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_multimedia_picker/provider/media_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaItemWidget extends StatefulWidget {
  final MediaFile media;
  MediaItemWidget({Key? key, required this.media}) : super(key: key);

  @override
  _MediaItemWidgetState createState() => _MediaItemWidgetState();
}

class _MediaItemWidgetState extends State<MediaItemWidget> with AutomaticKeepAliveClientMixin  {

  @override
  void initState() {
    super.initState();
  }

  Future<File> getThumbnail() async {
    print('getThumbnail: ' + widget.media.type);
    if (widget.media.type == 'video') {
      return await getThumbnailVideo();
    } else {
      return await getThumbnailImage();
    }
  }

  Future<File> getThumbnailImage() async {
    print('getThumbnailImage: ' + widget.media.path);
    var dir = await getTemporaryDirectory();
    var tempPath = dir.absolute.path;

    var now = DateTime.now().microsecondsSinceEpoch;
    var random = new Random().nextInt(100);
    tempPath += '/$now$random.jpg';

    print('tempPath: ' + tempPath);

    final thumbnailFile = await FlutterImageCompress.compressAndGetFile(
      widget.media.path,
      tempPath,
      quality: 60,
      format: CompressFormat.jpeg,
    );

    return thumbnailFile!;
  }

  Future<File> getThumbnailVideo() async {
    print('getThumbnailVideo: ' + widget.media.path);
    final thumbnailFile = await VideoThumbnail.thumbnailFile(
      video: widget.media.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 512,
      quality: 75,
    );
    return File(thumbnailFile!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: FutureBuilder(
          future: Future.wait([getThumbnail()]),
          builder: (context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                leading: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(snapshot.data![0]),
                ),
                title: Text(widget.media.description),
              );
            } else {
              return ListTile(
                leading: const CircularProgressIndicator(),
                title: Text(widget.media.description),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
