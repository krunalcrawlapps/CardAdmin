import 'dart:io';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/helper/image_helper.dart';
import 'package:card_app_admin/models/category_model.dart';
import 'package:card_app_admin/models/subcategory_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:card_app_admin/widgets/select_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';

class AddSubCategoryScreen extends StatefulWidget {
  final SubCategoryModel? subCategoryModel;

  const AddSubCategoryScreen({Key? key, this.subCategoryModel})
      : super(key: key);

  @override
  _AddSubCategoryScreenState createState() => _AddSubCategoryScreenState();
}

class _AddSubCategoryScreenState extends State<AddSubCategoryScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController subCatNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  String? categoryName;

  bool isCategoryLoading = true;
  bool isLoading = false;
  List<CategoryModel> arrCategory = [];

  //image
  XFile? _image;
  bool isShowImageValidation = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAllCategory();
  }

  getAllCategory() async {
    arrCategory = await DatabaseHelper.shared.getAllCategory();
    if (widget.subCategoryModel != null) {
      categoryName = arrCategory
          .where((element) => element.catId == widget.subCategoryModel!.catId)
          .toList()
          .first
          .catName;
      subCatNameController.text = widget.subCategoryModel?.subCatName ?? '';
      amountController.text = widget.subCategoryModel?.amount.toString() ?? '';
      currencyController.text = widget.subCategoryModel?.currency ?? '';
    }
    setState(() {
      isCategoryLoading = false;
      arrCategory = arrCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.subCategoryModel == null
                ? 'Add Sub Category'
                : 'Edit Sub Category')),
        body: isCategoryLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: subCatNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Sub Category Name',
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: RequiredValidator(
                          errorText:
                              StringConstant.enter_subcategory_name_validation),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Amount',
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: RequiredValidator(
                          errorText:
                              StringConstant.enter_sub_amount_validation),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: currencyController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Currency',
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: RequiredValidator(
                          errorText: StringConstant.enter_currency_validation),
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
                        value: categoryName,
                        items: arrCategory
                            .map((e) => e.catName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(label.toString()),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text('Select Category'),
                        onChanged: (value) {
                          setState(() {
                            categoryName = value;
                          });
                        },
                        validator: (value) => value == null
                            ? StringConstant.select_category_validation
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    getImagePickerWidget(
                        context,
                        _image,
                        widget.subCategoryModel?.imageUrl,
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
                                if (widget.subCategoryModel == null) {
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
                                  if (widget.subCategoryModel != null) {
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
                                  widget.subCategoryModel == null
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

      String catId = arrCategory
          .where((element) => element.catName == categoryName)
          .toList()
          .first
          .catId;
      SubCategoryModel subCategory = SubCategoryModel(
          randomId,
          catId,
          subCatNameController.text,
          imgUrl ?? '',
          double.parse(amountController.text),
          currencyController.text);
      DatabaseHelper.shared.addUpdateSubCategory(subCategory);
      hideLoader(context);
      showAlert(context, 'Sub Category added successfully.', onClick: () {
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

      SubCategoryModel? subCategory = widget.subCategoryModel;
      if (_image != null) {
        String? imgUrl = await ImageUploadHelper.shared
            .uploadImage(subCategory?.catId ?? '', File(_image!.path));
        subCategory?.imageUrl = imgUrl ?? '';
      }

      subCategory?.subCatName = subCatNameController.text;
      subCategory?.amount = double.parse(amountController.text);
      subCategory?.currency = currencyController.text;
      DatabaseHelper.shared.addUpdateSubCategory(subCategory!);
      hideLoader(context);
      showAlert(context, 'Sub Category updated successfully.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      hideLoader(context);
      showAlert(context, error.toString());
    }
  }
}
