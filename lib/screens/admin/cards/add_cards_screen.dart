import 'dart:convert';
import 'dart:typed_data';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/category_model.dart';
import 'package:card_app_admin/models/subcategory_model.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddCardsScreen extends StatefulWidget {
  final CardModel? cardModel;
  const AddCardsScreen({Key? key, this.cardModel}) : super(key: key);

  @override
  _AddCardsScreenState createState() => _AddCardsScreenState();
}

class _AddCardsScreenState extends State<AddCardsScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController cardNumberController = TextEditingController();
  // TextEditingController cardAmountController = TextEditingController();

  String? selectedCardVendor;
  String? selectedCardVendorId;

  String? selectedCategory;
  String? selectedCategoryId;

  String? selectedSubCategory;
  String? selectedSubCategoryId;

  bool isVendorLoading = true;
  bool isLoading = false;
  List<VendorModel> arrVendors = [];
  List<CategoryModel> arrCategory = [];
  List<SubCategoryModel> arrSubCategory = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAllData();
  }

  getAllData() async {
    arrVendors = await DatabaseHelper.shared.getAllVendors();
    arrCategory = await DatabaseHelper.shared.getAllCategory();
    arrSubCategory = await DatabaseHelper.shared.getAllSubCategory();

    if (widget.cardModel != null) {
      selectedCardVendor = widget.cardModel?.vendorName;
      selectedCardVendorId = widget.cardModel?.vendorId;

      selectedCategory = widget.cardModel?.catName;
      selectedCategoryId = widget.cardModel?.catId;

      selectedSubCategory = widget.cardModel?.subCatName;
      selectedSubCategoryId = widget.cardModel?.subCatId;

      String cardNumber = "";
      if (widget.cardModel?.cardNumber is int) {
        cardNumber = widget.cardModel?.cardNumber.toString() ?? "";
      } else {
        Latin1Decoder latin1Decoder = Latin1Decoder();

        cardNumber = latin1Decoder.convert(
            base64Decode(widget.cardModel?.cardNumber.toString() ?? ""));
      }

      cardNumberController.text = cardNumber;
      // cardAmountController.text = widget.cardModel?.amount.toString() ?? '';
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
            title: Text(AppTranslations.of(context)!
                .text(widget.cardModel == null ? 'Add Card' : 'Edit Card'))),
        body: isVendorLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              AppTranslations.of(context)!.text('Card Number'),
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppTranslations.of(context)!
                                .text(StringConstant.enter_number_validation)),
                        MinLengthValidator(14,
                            errorText: AppTranslations.of(context)!.text(
                                StringConstant.enter_valid_number_validation))
                      ]),
                    ),
                    SizedBox(height: 20),
                    // TextFormField(
                    //   controller: cardAmountController,
                    //   keyboardType: TextInputType.numberWithOptions(
                    //     decimal: true,
                    //     signed: false,
                    //   ),
                    //   decoration: InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       labelText: 'Card Amount',
                    //       labelStyle: TextStyle(fontSize: 15)),
                    //   validator: RequiredValidator(
                    //       errorText: StringConstant.enter_amount_validation),
                    // ),
                    Container(
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      alignment: Alignment.center,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration.collapsed(hintText: ''),
                        value: selectedCardVendor,
                        items: arrVendors
                            .map((e) => e.vendorName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(label.toString()),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text(AppTranslations.of(context)!
                            .text('Select Card Vendor')),
                        onChanged: (value) {
                          setState(() {
                            selectedCardVendor = value;
                            String vendorId = arrVendors
                                .where((element) =>
                                    element.vendorName == selectedCardVendor)
                                .toList()
                                .first
                                .vendorId;
                            selectedCardVendorId = vendorId;
                          });
                        },
                        validator: (value) => value == null
                            ? AppTranslations.of(context)!
                                .text(StringConstant.enter_vendor_validation)
                            : null,
                      ),
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
                        value: selectedCategory,
                        items: arrCategory
                            .where((element) =>
                                element.vendorId == selectedCardVendorId)
                            .toList()
                            .map((e) => e.catName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(AppTranslations.of(context)!
                                      .text(label.toString())),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text(AppTranslations.of(context)!
                            .text('Select Card Category')),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            String catId = arrCategory
                                .where((element) =>
                                    element.catName == selectedCategory)
                                .toList()
                                .first
                                .catId;
                            selectedCategoryId = catId;
                          });
                        },
                        validator: (value) => value == null
                            ? AppTranslations.of(context)!
                                .text(StringConstant.select_category_validation)
                            : null,
                      ),
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
                        value: selectedSubCategory,
                        items: arrSubCategory
                            .where((element) =>
                                element.catId == selectedCategoryId)
                            .toList()
                            .map((e) => e.subCatName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(AppTranslations.of(context)!
                                      .text(label.toString())),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text(AppTranslations.of(context)!
                            .text('Select Card Vendor')),
                        onChanged: (value) {
                          setState(() {
                            selectedSubCategory = value;
                            String subCatId = arrSubCategory
                                .where((element) =>
                                    element.subCatName == selectedSubCategory)
                                .toList()
                                .first
                                .subCatId;
                            selectedSubCategoryId = subCatId;
                          });
                        },
                        validator: (value) => value == null
                            ? AppTranslations.of(context)!.text(
                                StringConstant.select_subcategory_validation)
                            : null,
                      ),
                    ),
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
                                if (_formKey.currentState!.validate()) {
                                  if (widget.cardModel == null) {
                                    _addNewCard();
                                  } else {
                                    _editCard();
                                  }
                                }
                              },
                              child: Text(
                                  AppTranslations.of(context)!.text(
                                      widget.cardModel == null
                                          ? 'Submit'
                                          : 'Save'),
                                  style: TextStyle(fontSize: 18)),
                            ),
                          )
                  ]),
                ))));
  }

  _addNewCard() async {
    setState(() {
      isLoading = true;
    });

    try {
      Latin1Encoder latin1Encoder = Latin1Encoder();
      Uint8List cardNumber = latin1Encoder.convert(cardNumberController.text);
      CardModel card = CardModel(
          getRandomId(),
          base64Encode(cardNumber),
          // double.parse(cardAmountController.text),
          CardStatus.available,
          DatabaseHelper.shared.getLoggedInUserModel()?.adminId ?? '',
          selectedCardVendorId ?? '',
          selectedCategoryId ?? '',
          selectedSubCategoryId ?? '',
          selectedCardVendor ?? '',
          selectedCategory ?? '',
          selectedSubCategory ?? '',
          DateTime.now().millisecondsSinceEpoch);

      await DatabaseHelper.shared.addCardData(card);
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showAlert(context, error.toString());
    }
  }

  _editCard() async {
    setState(() {
      isLoading = true;
    });

    try {
      String vendorId = arrVendors
          .where((element) => element.vendorName == selectedCardVendor)
          .toList()
          .first
          .vendorId;

      String catId = arrCategory
          .where((element) => element.catName == selectedCategory)
          .toList()
          .first
          .catId;

      String subCatId = arrSubCategory
          .where((element) => element.subCatName == selectedSubCategory)
          .toList()
          .first
          .subCatId;

      CardModel model = widget.cardModel!;

      Latin1Encoder latin1Encoder = Latin1Encoder();
      Uint8List cardNumber = latin1Encoder.convert(cardNumberController.text);
      model.cardNumber = base64Encode(cardNumber);
      // model.amount = double.parse(cardAmountController.text);

      model.vendorId = vendorId;
      model.catId = catId;
      model.subCatId = subCatId;

      model.vendorName = selectedCardVendor ?? '';
      model.catName = selectedCategory ?? '';
      model.subCatName = selectedSubCategory ?? '';

      await DatabaseHelper.shared.updateCardDetails(model);

      setState(() {
        isLoading = false;
      });

      showAlert(context, 'Card details updated.', onClick: () {
        Navigator.of(context).pop();
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showAlert(context, error.toString());
    }
  }
}
