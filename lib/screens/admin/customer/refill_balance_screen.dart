import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:card_app_admin/screens/admin/home_screen.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class RefillCustomerBalanceScreen extends StatefulWidget {
  final CustomerModel customerModel;
  const RefillCustomerBalanceScreen(this.customerModel, {Key? key})
      : super(key: key);

  @override
  _RefillCustomerBalanceScreenState createState() =>
      _RefillCustomerBalanceScreenState();
}

class _RefillCustomerBalanceScreenState
    extends State<RefillCustomerBalanceScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController balanceController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    balanceController.text = widget.customerModel.custBalance.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Update Balance')),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(children: <Widget>[
                TextFormField(
                  controller: balanceController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Balance',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_balance_validation),
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
                            if (_formKey.currentState!.validate()) {
                              widget.customerModel.custBalance =
                                  double.parse(balanceController.text);
                              updateCustomerBalance(widget.customerModel);
                            }
                          },
                          child: Text('Update', style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  updateCustomerBalance(CustomerModel customer) async {
    setState(() {
      isLoading = true;
    });
    await DatabaseHelper.shared.updateCustomerBalance(customer);
    setState(() {
      isLoading = false;
    });
    showAlert(context, 'Customer balance updated.', onClick: () {
      //user is normal admin
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    });
  }
}
