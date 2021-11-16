import 'package:flutter/material.dart';
import 'package:flutter_multimedia_picker/widgets/media_item_widget.dart';


class MediaProvider extends ChangeNotifier{

  List<MediaItemWidget> medias  = [];

  Future<void> addMedia(MediaItemWidget widget) async {
    medias.add(widget);
    notifyListeners();
  }

}