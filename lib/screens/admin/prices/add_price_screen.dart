import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/category_model.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:card_app_admin/models/price_model.dart';
import 'package:card_app_admin/models/subcategory_model.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/utils/date_utils.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddPricesScreen extends StatefulWidget {
  final PricesModel? cardModel;
  const AddPricesScreen({Key? key, this.cardModel}) : super(key: key);

  @override
  _AddPricesScreenState createState() => _AddPricesScreenState();
}

class _AddPricesScreenState extends State<AddPricesScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountCurrencyController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  String? selectedCardVendor;
  String? selectedCardVendorId;

  String? selectedCategory;
  String? selectedCategoryId;

  String? selectedSubCategory;
  String? selectedSubCategoryId;

  String? selectedCustmoer;
  String? selectedCustmoerId;

  bool isVendorLoading = true;
  bool isLoading = false;
  List<VendorModel> arrVendors = [];
  List<CategoryModel> arrCategory = [];
  List<SubCategoryModel> arrSubCategory = [];
  List<CustomerModel> custmoers = [];

  @override
  void initState() {
    super.initState();

    getAllData();
  }

  getAllData() async {
    arrVendors = await DatabaseHelper.shared.getAllVendors();
    arrCategory = await DatabaseHelper.shared.getAllCategory();
    arrSubCategory = await DatabaseHelper.shared.getAllSubCategory();
    custmoers = await DatabaseHelper.shared.getAllCustmoers();

    if (widget.cardModel != null) {
      selectedCardVendor = widget.cardModel?.vendorName;
      selectedCardVendorId = widget.cardModel?.vendorId;

      selectedCategory = widget.cardModel?.catName;
      selectedCategoryId = widget.cardModel?.catId;

      selectedSubCategory = widget.cardModel?.subCatName;
      selectedSubCategoryId = widget.cardModel?.subCatId;

      selectedCustmoer = widget.cardModel?.custName;
      selectedCustmoerId = widget.cardModel?.custId;

      amountController.text = widget.cardModel?.price.toString() ?? '';
      amountCurrencyController.text = widget.cardModel?.currencyName ?? "";
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
            title: Text(AppTranslations.of(context)!.text(
                widget.cardModel == null ? 'Add Prices' : 'Edit Prices'))),
        body: isVendorLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(children: <Widget>[
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
                                  child: Text(AppTranslations.of(context)!
                                      .text(label.toString())),
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
                        value: arrCategory
                                .where((element) =>
                                    element.vendorId == selectedCardVendorId)
                                .toList()
                                .isEmpty
                            ? null
                            : selectedCategory,
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
                        value: arrSubCategory
                                .where((element) =>
                                    element.catId == selectedCategoryId)
                                .toList()
                                .isEmpty
                            ? null
                            : selectedSubCategory,
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
                            .text('Select Card Sub Category')),
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
                        value: custmoers.isEmpty ? null : selectedCustmoer,
                        items: custmoers
                            .map((e) => e.custName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(AppTranslations.of(context)!
                                      .text(label.toString())),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text(AppTranslations.of(context)!
                            .text('Select Custmoer')),
                        onChanged: (value) {
                          setState(() {
                            selectedCustmoer = value;
                            print(custmoers.map((e) => e.custId));
                            String subCatId = custmoers
                                .where((element) =>
                                    element.custName == selectedCustmoer)
                                .toList()
                                .first
                                .custId;
                            selectedCustmoerId = subCatId;
                          });
                        },
                        validator: (value) => value == null
                            ? AppTranslations.of(context)!
                                .text(StringConstant.select_customer_validation)
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              AppTranslations.of(context)!.text('Amount'),
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppTranslations.of(context)!
                                .text(StringConstant.enter_amount_validation)),
                      ]),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: amountCurrencyController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              AppTranslations.of(context)!.text('Currency'),
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppTranslations.of(context)!
                                .text(StringConstant.enter_number_validation)),
                      ]),
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
      PricesModel prices = PricesModel(
          getRandomId(),
          selectedCustmoerId ?? "",
          selectedCustmoer ?? "",
          double.parse(amountController.text),
          amountCurrencyController.text,
          DatabaseHelper.shared.getLoggedInUserModel()?.adminId ?? '',
          selectedCardVendorId ?? '',
          selectedCategoryId ?? '',
          selectedSubCategoryId ?? '',
          selectedCardVendor ?? '',
          selectedCategory ?? '',
          selectedSubCategory ?? '',
          DateTimeUtils.getDateTime(DateTime.now().millisecondsSinceEpoch));

      await DatabaseHelper.shared.addPricesData(prices);
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

      String subCustId = custmoers
          .where((element) => element.custName == selectedCustmoer)
          .toList()
          .first
          .custId;

      PricesModel model = widget.cardModel!;
      model.price = double.parse(amountController.text);
      // model.amount = double.parse(cardAmountController.text);
      model.custId = subCustId;

      model.vendorId = vendorId;
      model.catId = catId;
      model.subCatId = subCatId;

      model.vendorName = selectedCardVendor ?? '';
      model.catName = selectedCategory ?? '';
      model.subCatName = selectedSubCategory ?? '';
      model.custName = selectedCustmoer ?? "";

      model.currencyName = amountCurrencyController.text;
      await DatabaseHelper.shared.updatePricesData(model);

      setState(() {
        isLoading = false;
      });

      showAlert(context, 'Prices details updated.', onClick: () {
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
