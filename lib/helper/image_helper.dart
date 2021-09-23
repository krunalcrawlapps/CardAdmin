import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadHelper {
  static ImageUploadHelper _instance = ImageUploadHelper._();
  ImageUploadHelper._();
  static ImageUploadHelper get shared => _instance;

  final ImagePicker _picker = ImagePicker();

  ///Image Picker
  Future<void> showImagePicker(
      BuildContext context, Function(XFile?) onImagePicked) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () async {
                        Navigator.of(context).pop();
                        XFile? file = await _imgFromGallery();
                        onImagePicked(file);
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      XFile? file = await _imgFromCamera();
                      onImagePicked(file);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<XFile?> _imgFromGallery() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    return image;
  }

  Future<XFile?> _imgFromCamera() async {
    XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    return image;
  }

  Future<String?> uploadImage(String id, File image) async {
    try {
      final task =
          await FirebaseStorage.instance.ref(id + ".jpg").putFile(image);
      final url = await task.ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
    }
  }
}
