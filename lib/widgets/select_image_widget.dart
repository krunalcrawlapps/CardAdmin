import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_app_admin/helper/image_helper.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget getImagePickerWidget(BuildContext context, XFile? image,
    String? imageUrl, bool isShowValidation, Function(XFile?) onPickImage) {
  bool isFromEdit = false;
  if (imageUrl == null) {
    isFromEdit = false;
  } else {
    isFromEdit = true;
  }
  return Column(
    children: [
      Container(
          height: image == null
              ? isFromEdit
                  ? 200
                  : 60
              : 200,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          alignment: image == null
              ? isFromEdit
                  ? Alignment.center
                  : Alignment.centerLeft
              : Alignment.center,
          child: InkWell(
              child: image == null
                  ? isFromEdit
                      ? CachedNetworkImage(
                          imageUrl: imageUrl ?? '',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )
                      : Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.centerLeft,
                          child: Row(children: [
                            Text(AppTranslations.of(context)!
                            .text('Select Image'),
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 16)),
                            Spacer(),
                            Icon(Icons.photo_camera_back, color: Colors.black54)
                          ]))
                  : Image.file(
                      File(image.path),
                      fit: BoxFit.fitHeight,
                    ),
              onTap: () {
                ImageUploadHelper.shared.showImagePicker(context, (file) {
                  //picked image
                  onPickImage(file);
                });
              })),
      if (isShowValidation) _getImageValidation(context)
    ],
  );
}

Widget _getImageValidation(BuildContext context) {
  return Column(children: [
    SizedBox(height: 5),
    Align(
      alignment: Alignment.centerLeft,
      child: Text("  "+AppTranslations.of(context)!
                            .text('Please select image'),
          style: TextStyle(color: Colors.red, fontSize: 12)),
    )
  ]);
}
