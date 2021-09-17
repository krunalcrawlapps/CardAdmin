import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/vendor_model.dart';
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
  TextEditingController cardAmountController = TextEditingController();

  String? cardVendor;

  bool isVendorLoading = true;
  bool isLoading = false;
  List<VendorModel> arrVendors = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAllVendor();
  }

  getAllVendor() async {
    arrVendors = await DatabaseHelper.shared.getAllVendors();
    if (widget.cardModel != null) {
      cardVendor = widget.cardModel?.cardVendor;
      cardNumberController.text = widget.cardModel?.cardNumber.toString() ?? '';
      cardAmountController.text = widget.cardModel?.amount.toString() ?? '';
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
            title: Text(widget.cardModel != null ? 'Add Card' : 'Edit Card')),
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
                      maxLength: 10,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Card Number',
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: StringConstant.enter_number_validation),
                        MinLengthValidator(10,
                            errorText:
                                StringConstant.enter_valid_number_validation)
                      ]),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: cardAmountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Card Amount',
                          labelStyle: TextStyle(fontSize: 15)),
                      validator: RequiredValidator(
                          errorText: StringConstant.enter_amount_validation),
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
                        value: cardVendor,
                        items: arrVendors
                            .map((e) => e.vendorName)
                            .map((label) => DropdownMenuItem(
                                  child: Text(label.toString()),
                                  value: label,
                                ))
                            .toList(),
                        hint: Text('Select Card Vendor'),
                        onChanged: (value) {
                          setState(() {
                            cardVendor = value;
                          });
                        },
                        validator: (value) => value == null
                            ? StringConstant.enter_vendor_validation
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
                                  widget.cardModel == null ? 'Submit' : 'Save',
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
      CardModel card = CardModel(
          getRandomId(),
          cardVendor ?? '',
          int.parse(cardNumberController.text),
          double.parse(cardAmountController.text),
          CardStatus.available,
          DatabaseHelper.shared.getLoggedInUserModel()?.adminId ?? '');

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
      CardModel model = widget.cardModel!;
      model.cardNumber = int.parse(cardNumberController.text);
      model.cardVendor = cardVendor ?? '';
      model.amount = double.parse(cardAmountController.text);

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
