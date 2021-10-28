import 'package:flutter/material.dart';


class MediaProvider extends ChangeNotifier{

  List<Widget> medias  = [];

  Future<void> addMedia(Widget widget) async {
    medias.add(widget);
    notifyListeners();
  }

}