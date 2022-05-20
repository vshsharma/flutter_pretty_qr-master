import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:path_provider/path_provider.dart';
// // import 'package:permission_handler/permission_handler.dart';
import 'package:qr/qr.dart';

import '../app_utils.dart';
import 'pretty_qr_painter.dart';
GlobalKey qrCodeKey = GlobalKey();
class PrettyQr extends StatefulWidget {
  ///Widget size
  final double size;

  ///Qr code data
  final String data;

  ///Square color
  final Color elementColor;

  ///Error correct level
  final int errorCorrectLevel;

  ///Round the corners
  final bool roundEdges;

  ///Number of type generation (1 to 40 or null for auto)
  final int? typeNumber;

  final ImageProvider? image;

  PrettyQr(
      {Key? key,
      this.size = 100,
      required this.data,
      this.elementColor = Colors.black,
      this.errorCorrectLevel = QrErrorCorrectLevel.M,
      this.roundEdges = false,
      this.typeNumber,
      this.image})
      : super(key: key);

  @override
  _PrettyQrState createState() => _PrettyQrState();
}

class _PrettyQrState extends State<PrettyQr> {
  bool downloading = false;

  String progressString = "";

  Future<ui.Image> _loadImage(BuildContext buildContext) async {
    final completer = Completer<ui.Image>();

    final stream = widget.image!.resolve(ImageConfiguration(
      devicePixelRatio: MediaQuery.of(buildContext).devicePixelRatio,
    ));

    stream.addListener(ImageStreamListener((imageInfo, error) async {
      completer.complete(imageInfo.image);
      //-===========================================================================


      // downloadFile();

      /*  bool loading = false;

      Future<bool> _requestPermission(Permission permission) async {
        if (await permission.isGranted) {
        } else {
          var result = await permission.request();
          if (result == PermissionStatus.granted) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      }

      Future<bool> saveFile(String url, String fileName) async {
        Directory directory;
        try {
          if (Platform.isAndroid) {
            if (await _requestPermission(Permission.storage)) {
              directory = (await getExternalStorageDirectories()) as Directory;
              print("ramkeshhere>>>>>>" + directory.path);
            }
          } else {}
        } catch (e) {}
        return false;
      }

      downloadFile() async {
        setState(() {
          loading = true;
        });
      }

      bool downloaded = await saveFile(
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
          "BigBuckBunny.mp4");
      if (downloaded) {
        print("file Downloaded");
      } else {
        print("problem Downloading file");
      }

      setState(() {
        loading = false;
      });*/

      // File f = await getImageFileFromAssets('images/twitter.png');

      //-===========================================================================
    }, onError: (dynamic error, _) {
      completer.completeError(error);
    }));
    return completer.future;
  }


 /* Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/image.png');

    // final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }*/

  @override
  void initState() {
    super.initState();
    print('Hey there init');
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => saveQRCode(context),
      child: RepaintBoundary(
          key: qrCodeKey,
          child: widget.image == null
          ? CustomPaint(
              size: Size(widget.size, widget.size),
              painter: PrettyQrCodePainter(
                  data: widget.data,
                  errorCorrectLevel: widget.errorCorrectLevel,
                  elementColor: widget.elementColor,
                  roundEdges: widget.roundEdges,
                  typeNumber: widget.typeNumber),
            )
          : FutureBuilder(
              future: _loadImage(context),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: PrettyQrCodePainter(
                          image: snapshot.data,
                          data: widget.data,
                          errorCorrectLevel: widget.errorCorrectLevel,
                          elementColor: widget.elementColor,
                          roundEdges: widget.roundEdges,
                          typeNumber: widget.typeNumber),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            )
      ),
    );
  }
}

Future<Uint8List?> captureQRCode() async {
  try {
    RenderRepaintBoundary boundary =
    qrCodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 5.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  } catch (e) {
    print('Error is ${e.toString()}');
  }
  return null;
}

void saveQRCode(BuildContext context) async {
  AppPermissionStatus permissionStatus =
  await AppPermission().askForPhotoGalleryPermission(context);
  if (permissionStatus == AppPermissionStatus.Granted) {
    Uint8List? pngBytes = await captureQRCode();
    if (pngBytes != null) {
      await AppUtils.saveImageToGallery(
        context: context,
        pngBytes: pngBytes,
        sucessMessage: 'Image Saved to device',
        errorMessage: 'Image not saved due to unknown error',
      );
    }
  } else if (permissionStatus == AppPermissionStatus.Denied ||
      permissionStatus == AppPermissionStatus.PermanentlyDenied) {
    print('Permission denied go to app setting and grant permission');
  }
}
