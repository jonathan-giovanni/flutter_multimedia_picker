
import 'package:flutter/material.dart';
import 'package:flutter_multimedia_picker/provider/media.dart';
import 'package:flutter_multimedia_picker/provider/media_provider.dart';
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
  final ScrollController _scrollController = new ScrollController();
  late final GalleryController controller;

  _onPressed(BuildContext context) {
    print('pressed');
  }

  void _scrollToBeginning() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {



      Provider.of<MediaProvider>(context,listen: false).addListener(() {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent+700,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 400),
        );
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scrollToBeginning();

    controller = GalleryController(

      headerSetting: HeaderSetting(),
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


          videoDuration: Duration(seconds: 30),
          child: Container(
              color: Colors.white,
              child: Icon(
                Icons.camera_alt,
                size: 40,
              )),
          onCapture: (element) async {
            print('captured ' + element.toString());
            print('duration ' +
                element.entity.videoDuration.inSeconds.toString());
            var file = await element.entity.file;
            print('path ' + file!.path);
            print('DURATION ' +
                element.entity.videoDuration.inSeconds.toString());
            Provider.of<MediaProvider>(context, listen: false).addMedia(
              MediaItemWidget(
                media: Media(
                  file: file,
                  path: file.path,
                  type: element.entity.type
                      .toString()
                      .toLowerCase()
                      .contains('video')
                      ? 'video'
                      : 'image',
                  duration: element.entity.videoDuration.inSeconds,
                ),
              ),
            );

            Navigator.of(context).pop();
          },
        ),
        actionButton:
        null, //Center(child: FloatingActionButton(child: Text("data"),onPressed: _onPressed(context),)),
        //cameraItemWidget: CameraView(videoDuration: Duration(seconds: 30))
      ),
      panelSetting: PanelSetting(maxHeight: 24.0),
    );


    print('cameraItemWidget ' + controller.setting.cameraItemWidget.toString());
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
                        print('element');
                        var file = await element.entity.file;
                        print('TYPE     ' + element.entity.type.toString());
                        print('PATH     ' + file!.path.toString());
                        print('DURATION ' +
                            element.entity.videoDuration.inSeconds.toString());
                        Provider.of<MediaProvider>(context, listen: false)
                            .addMedia(
                          MediaItemWidget(
                            media: Media(
                              file: file,
                              path: file.path,
                              type: element.entity.type
                                  .toString()
                                  .toLowerCase()
                                  .contains('video')
                                  ? 'video'
                                  : 'image',
                              duration: element.entity.videoDuration.inSeconds,
                            ),
                          ),
                        );
                      });
                      //controller.clearSelection();
                    },
                    child: Text('Imagenes o fotos de lista')),
                SizedBox(height: 20),
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
      child: Text('default'),
    );
  }
}
