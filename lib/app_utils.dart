// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

enum AppPermissionStatus {
  Granted,
  Denied,
  Restricted,
  NotAvailable,
  PermanentlyDenied
}

class AppUtils {
  AppUtils._();

  static Future<void> saveImageToGallery({
    required BuildContext context,
    required Uint8List pngBytes,
    String? errorMessage,
    String? sucessMessage,
  }) async {
    try {
      final status = await SaveToGallery().saveImage(pngBytes);
      if (status) {
        print(sucessMessage);
      } else {
        print(errorMessage);
      }
    } catch (e) {
      print(errorMessage);
    }
  }
}

class AppPermission {
  static final _instance = AppPermission._privateConstructor();
  AppPermission._privateConstructor();
  factory AppPermission() => _instance;

  Future<AppPermissionStatus> askForPhotoGalleryPermission(
      BuildContext context) async {
    var status = Platform.isIOS
        ? await Permission.photos.request()
        : await Permission.storage.request();
    AppPermissionStatus permissionStatus = AppPermissionStatus.NotAvailable;

    if (status.isGranted) {
      permissionStatus = AppPermissionStatus.Granted;
      return permissionStatus;
    } else if (status.isDenied) {
      permissionStatus = AppPermissionStatus.Denied;
      return permissionStatus;
    } else if (status.isRestricted) {
      permissionStatus = AppPermissionStatus.Restricted;
      return permissionStatus;
    } else if (status.isPermanentlyDenied) {
      permissionStatus = AppPermissionStatus.PermanentlyDenied;
    }
    return permissionStatus;
  }
}

class SaveToGallery {
  static final _instance = SaveToGallery._privateConstructor();
  SaveToGallery._privateConstructor();
  factory SaveToGallery() => _instance;

  Future<bool> saveImage(Uint8List pngBytes) async {
    try {
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
      );
      if (result['isSuccess'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
