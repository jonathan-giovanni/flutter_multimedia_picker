import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_multimedia_picker/provider/media_file.dart';
import 'package:flutter_multimedia_picker/provider/media_provider.dart';
import 'package:flutter_multimedia_picker/util/app_util.dart';
import 'package:flutter_multimedia_picker/widgets/media_item_widget.dart';
import 'package:likk_picker/likk_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MediaProvider()),
    ],
    child: MyApp(),
  ));
}

///
// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PickerDemo(),
    );
  }
}

class _PickerDemo extends StatefulWidget {
  @override
  State<_PickerDemo> createState() => _PickerDemoState();
}

class _PickerDemoState extends State<_PickerDemo> {
  final ScrollController _scrollController = ScrollController();
  late final GalleryController controller;

  void _scrollToBeginning() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<MediaProvider>(context, listen: false).addListener(() {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 400),
        );
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saveFilePicked(LikkEntity data) async {
    File? file = await data.entity.file;
    data.entity.videoDuration.inSeconds.toString();
    Provider.of<MediaProvider>(context, listen: false).addMedia(
      MediaItemWidget(
        media: MediaFile(
          file: file!,
          path: file.path,
          type: AppUtil.mediaType(data.entity.type.toString()),
          duration: data.entity.videoDuration.inSeconds,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollToBeginning();
    controller = GalleryController(
      headerSetting: const HeaderSetting(),
      gallerySetting: GallerySetting(
        backAndUnselect: () {
          return true;
        },
        selectionCountRingColor: Colors.amberAccent,
        selectionCountRingSize: 6,
        enableCamera: true,
        maximum: 30,
        requestType: RequestType.all,
        cameraItemWidget: CameraViewField(
          videoDuration: const Duration(seconds: 30),
          child: Container(
              color: Colors.white,
              child: const Icon(
                Icons.camera_alt,
                size: 40,
              )),
          onCapture: (element) async {
            await _saveFilePicked(element);
            Navigator.of(context).pop();
          },
        ),
        actionButton: null,
      ),
      panelSetting: const PanelSetting(maxHeight: 24.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('cameraItemWidget ' + controller.setting.cameraItemWidget.toString());

    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.grey[400],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      print('clear');
                      controller.clearSelection();
                      print('calling picker');
                      List<LikkEntity> data = await controller.pick(context);
                      data.forEach((element) async {
                        await _saveFilePicked(element);
                      });
                    },
                    child: const Text('Pick images and videos')),
                const SizedBox(height: 20),
                Expanded(child: mediaListWidget())
              ],
            ),
          )),
    );
  }

  Widget mediaListWidget() {
    return Consumer<MediaProvider>(
      builder: (_, provider, widget) => ListView.builder(
        cacheExtent: 50,
        controller: _scrollController,
        itemCount: provider.medias.length,
        itemBuilder: (context, index) {
          return provider.medias[index];
        },
      ),
      child: const Text('default'),
    );
  }
}
