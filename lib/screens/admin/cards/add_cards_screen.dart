import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddCardsScreen extends StatefulWidget {
  const AddCardsScreen({Key? key}) : super(key: key);

  @override
  _AddCardsScreenState createState() => _AddCardsScreenState();
}

class _AddCardsScreenState extends State<AddCardsScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardVendorController = TextEditingController();
  TextEditingController cardAmountController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add Card')),
        body: Form(
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
                        errorText: StringConstant.enter_valid_number_validation)
                  ]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: cardVendorController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Card Vendor',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_vendor_validation),
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
                SizedBox(height: 30),
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
                            if (_formKey.currentState!.validate()) {
                              _addNewCard();
                            }
                          },
                          child: const Text('Submit',
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
          cardVendorController.text,
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
}
