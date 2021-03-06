import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_multimedia_picker/provider/media_file.dart';
import 'package:flutter_multimedia_picker/provider/media_provider.dart';
import 'package:flutter_multimedia_picker/util/app_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:provider/provider.dart';

class MediaItemWidget extends StatefulWidget {
  final MediaFile media;
  MediaItemWidget({Key? key, required this.media}) : super(key: key);

  @override
  _MediaItemWidgetState createState() => _MediaItemWidgetState();
}



class _MediaItemWidgetState extends State<MediaItemWidget>
    with AutomaticKeepAliveClientMixin {
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
    final name = AppUtil.generateUUID();
    tempPath += '/$name.jpg';

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

  Widget _progressIcon() {
    //switch status
    switch (widget.media.status) {
      case FileStatus.PENDING:
      case FileStatus.COMPRESSING:
      case FileStatus.UPLOADING:
        return CircularProgressIndicator();
      case FileStatus.COMPLETED:
        return Image.file(widget.media.file);
      default:
        return Icon(Icons.image);
    }
  }

  Widget _trailingIcon() {
    switch (widget.media.status) {
      case FileStatus.PENDING:
      case FileStatus.COMPRESSING:
      case FileStatus.UPLOADING:
        return InkWell(
            child: const Icon(Icons.cancel),
            onTap: () {
              Provider.of<MediaProvider>(context, listen: false)
                  .cancelUpload(widget.media);
            },
          );
      case FileStatus.CANCELED:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: const Icon(Icons.refresh),
              onTap: () {
                Provider.of<MediaProvider>(context, listen: false)
                    .retryUpload(widget.media);
              },
            ),
            const SizedBox(width: 15),
            InkWell(
              child: const Icon(Icons.delete),
              onTap: () {
                Provider.of<MediaProvider>(context, listen: false)
                    .delete(widget.media);
              },
            ),
          ],
        );
      default:
        return InkWell(
          child: const Icon(Icons.delete),
          onTap: () {
            Provider.of<MediaProvider>(context, listen: false)
                .delete(widget.media);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('**** build ****');
    super.build(context);
    return Card(
      child: Container(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: ListTile(
            //leading circular progress
            leading:  _progressIcon(),


            title: Text(widget.media.description),
            trailing: _trailingIcon(),
            onTap: () {
              //change widget.media.description value on setState
              setState(() {
                //widget.media.description = 'Changed';
                //widget.media.compressionStatus = FileStatus.CANCELED;
                //delete with MediaProvider using context.read
                context.read<MediaProvider>().delete(widget.media);
              });
            },
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
