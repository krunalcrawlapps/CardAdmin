import 'dart:io';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/helper/image_helper.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:card_app_admin/widgets/select_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';

class AddVendorScreen extends StatefulWidget {
  final VendorModel? vendorModel;
  const AddVendorScreen({Key? key, this.vendorModel}) : super(key: key);

  @override
  _AddVendorScreenState createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  //image
  XFile? _image;
  bool isShowImageValidation = false;
  int _radioSelected = 1;
  bool isDirectCharge = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.vendorModel != null) {
      nameController.text = widget.vendorModel?.vendorName ?? '';
      isDirectCharge = widget.vendorModel?.isDirectCharge ?? false;
      if (isDirectCharge) {
        _radioSelected = 2;
      } else {
        _radioSelected = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.vendorModel != null ? 'Edit Vendor' : 'Add Vendor')),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_name_validation),
                ),
                SizedBox(height: 20),
                getImagePickerWidget(
                    context,
                    _image,
                    widget.vendorModel?.imageUrl,
                    isShowImageValidation, (file) {
                  setState(() {
                    _image = file;
                  });
                }),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Prepaid Card'),
                    Radio(
                      value: 1,
                      groupValue: _radioSelected,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          _radioSelected = 1;
                          isDirectCharge = false;
                        });
                      },
                    ),
                    Text('Direct Charge'),
                    Radio(
                      value: 2,
                      groupValue: _radioSelected,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          _radioSelected = 2;
                          isDirectCharge = true;
                        });
                      },
                    )
                  ],
                ),
                SizedBox(height: 50),
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange)),
                          onPressed: () {
                            if (widget.vendorModel == null) {
                              if (_image == null) {
                                setState(() {
                                  isShowImageValidation = true;
                                });
                              } else {
                                setState(() {
                                  isShowImageValidation = false;
                                });
                              }
                            }
                            if (_formKey.currentState!.validate()) {
                              if (widget.vendorModel != null) {
                                _updateVendor();
                              } else {
                                if (_image == null) {
                                  setState(() {
                                    isShowImageValidation = true;
                                  });
                                } else {
                                  _addVendor();
                                }
                              }
                            }
                          },
                          child: Text(
                              widget.vendorModel != null ? 'Save' : 'Submit',
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  _addVendor() async {
    try {
      showLoader(context);
      String randomId = getRandomId();
      String? imgUrl = await ImageUploadHelper.shared
          .uploadImage(randomId, File(_image!.path));
      VendorModel vendor = VendorModel(
          randomId,
          nameController.text,
          DatabaseHelper.shared.getLoggedInUserModel()?.adminId ?? '',
          imgUrl ?? '',
          isDirectCharge);
      DatabaseHelper.shared.addNewVendor(vendor);
      hideLoader(context);
      showAlert(context, 'Vendor added successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      hideLoader(context);
      showAlert(context, error.toString());
    }
  }

  _updateVendor() async {
    try {
      showLoader(context);

      VendorModel? vendor = widget.vendorModel;
      if (_image != null) {
        String? imgUrl = await ImageUploadHelper.shared.uploadImage(
            widget.vendorModel?.vendorId ?? '', File(_image!.path));
        vendor?.imageUrl = imgUrl ?? '';
      }

      vendor?.vendorName = nameController.text;
      vendor?.isDirectCharge = isDirectCharge;
      DatabaseHelper.shared.addNewVendor(vendor!);
      hideLoader(context);
      showAlert(context, 'Vendor updated successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      hideLoader(context);
      showAlert(context, error.toString());
    }
  }
}
