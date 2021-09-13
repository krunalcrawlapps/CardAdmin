import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool pwdVisible = false;
  bool confirmPwdVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Add Customer')),
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
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Address',
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: StringConstant.enter_address_validation),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: StringConstant.email_address,
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: StringConstant.enter_email_validation),
                    EmailValidator(
                        errorText: StringConstant.enter_valid_email_validation)
                  ]),
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !pwdVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: StringConstant.password,
                      labelStyle: TextStyle(fontSize: 15),
                      suffixIcon: IconButton(
                        icon: Icon(
                          pwdVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            pwdVisible = !pwdVisible;
                          });
                        },
                      )),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: StringConstant.enter_pwd_validation),
                    MinLengthValidator(6,
                        errorText: StringConstant.enter_valid_pwd_validation)
                  ]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !confirmPwdVisible,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(fontSize: 15),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          confirmPwdVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            confirmPwdVisible = !confirmPwdVisible;
                          });
                        },
                      )),
                  validator: (val) => MatchValidator(
                          errorText:
                              StringConstant.invalid_confirm_pwd_validation)
                      .validateMatch(passwordController.text, val ?? ''),
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
                              _addNewCustomer();
                            }
                          },
                          child: const Text('Submit',
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  _addNewCustomer() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = await DatabaseHelper.shared
          .registerUser(emailController.text, passwordController.text);

      if (user != null) {
        CustomerModel model = CustomerModel(
            user.uid,
            nameController.text,
            double.parse(balanceController.text),
            DatabaseHelper.shared.getLoggedInUserModel()?.adminId ?? '',
            addressController.text,
            passwordController.text,
            emailController.text);

        await DatabaseHelper.shared.addCustomerData(model);

        Navigator.pop(context);
      } else {
        showAlert(context, ErrorMessage.something_wrong);
      }

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
