import 'dart:io';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/helper/image_helper.dart';
import 'package:card_app_admin/models/category_model.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:card_app_admin/widgets/select_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? categoryModel;
  const AddCategoryScreen({Key? key, this.categoryModel}) : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController catNameController = TextEditingController();
  String? vendorName;

  bool isVendorLoading = true;
  bool isLoading = false;
  List<VendorModel> arrVendors = [];

  //image
  XFile? _image;
  bool isShowImageValidation = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAllVendor();
  }

  getAllVendor() async {
    arrVendors = await DatabaseHelper.shared.getAllVendors();
    if (widget.categoryModel != null) {
      vendorName = arrVendors
          .where(
              (element) => element.vendorId == widget.categoryModel!.vendorId)
          .toList()
          .first
          .vendorName;
      catNameController.text = widget.categoryModel?.catName ?? '';
    }
    setState(() {
      isVendorLoading = false;
      arrVendors = arrVendors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.categoryModel == null
                ? 'Add Category'
                : 'Edit Category')),
        body: isVendorLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: catNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Category Name',
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: RequiredValidator(
                          errorText:
                              StringConstant.enter_category_name_validation),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      alignment: Alignment.center,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration.collapsed(hintText: ''),
                        value: vendorName,
                        items: arrVendors
                            .map((e) => e.vendorName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(label.toString()),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text('Select Vendor'),
                        onChanged: (value) {
                          setState(() {
                            vendorName = value;
                          });
                        },
                        validator: (value) => value == null
                            ? StringConstant.enter_vendor_validation
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    getImagePickerWidget(
                        context,
                        _image,
                        widget.categoryModel?.imageUrl,
                        isShowImageValidation, (file) {
                      setState(() {
                        _image = file;
                      });
                    }),
                    SizedBox(height: 30),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.orange)),
                              onPressed: () {
                                if (widget.categoryModel == null) {
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
                                  if (widget.categoryModel != null) {
                                    _updateCategory();
                                  } else {
                                    if (_image == null) {
                                      setState(() {
                                        isShowImageValidation = true;
                                      });
                                    } else {
                                      _addCategory();
                                    }
                                  }
                                }
                              },
                              child: Text(
                                  widget.categoryModel == null
                                      ? 'Submit'
                                      : 'Save',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          )
                  ]),
                ))));
  }

  _addCategory() async {
    try {
      showLoader(context);
      String randomId = getRandomId();
      String? imgUrl = await ImageUploadHelper.shared
          .uploadImage(randomId, File(_image!.path));

      String vendorId = arrVendors
          .where((element) => element.vendorName == vendorName)
          .toList()
          .first
          .vendorId;
      CategoryModel category = CategoryModel(
          randomId, vendorId, catNameController.text, imgUrl ?? '');
      DatabaseHelper.shared.addUpdateCategory(category);
      hideLoader(context);
      showAlert(context, 'Category added successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      hideLoader(context);
      showAlert(context, error.toString());
    }
  }

  _updateCategory() async {
    try {
      showLoader(context);

      CategoryModel? category = widget.categoryModel;
      if (_image != null) {
        String? imgUrl = await ImageUploadHelper.shared
            .uploadImage(category?.catId ?? '', File(_image!.path));
        category?.imageUrl = imgUrl ?? '';
      }

      String vendorId = arrVendors
          .where((element) => element.vendorName == vendorName)
          .toList()
          .first
          .vendorId;
      category?.vendorId = vendorId;
      category?.catName = catNameController.text;
      DatabaseHelper.shared.addUpdateCategory(category!);
      hideLoader(context);
      showAlert(context, 'Category updated successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      hideLoader(context);
      showAlert(context, error.toString());
    }
  }
}
