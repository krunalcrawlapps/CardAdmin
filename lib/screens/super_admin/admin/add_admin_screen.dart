import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/admin_model.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddAdminScreen extends StatefulWidget {
  const AddAdminScreen({Key? key}) : super(key: key);

  @override
  _AddAdminScreenState createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  //variables
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool pwdVisible = false;
  bool confirmPwdVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                AppTranslations.of(context)!.text(StringConstant.add_admin))),
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
                      labelText: AppTranslations.of(context)!.text('Name'),
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: AppTranslations.of(context)!
                          .text(StringConstant.enter_name_validation)),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppTranslations.of(context)!.text('Address'),
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: RequiredValidator(
                      errorText: AppTranslations.of(context)!
                          .text(StringConstant.enter_address_validation)),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppTranslations.of(context)!
                          .text(StringConstant.email_address),
                      labelStyle: TextStyle(fontSize: 15)),
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: AppTranslations.of(context)!
                            .text(StringConstant.enter_email_validation)),
                    EmailValidator(
                        errorText: AppTranslations.of(context)!
                            .text(StringConstant.enter_valid_email_validation))
                  ]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !pwdVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppTranslations.of(context)!
                          .text(StringConstant.password),
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
                        errorText: AppTranslations.of(context)!
                            .text(StringConstant.enter_pwd_validation)),
                    MinLengthValidator(6,
                        errorText: AppTranslations.of(context)!
                            .text(StringConstant.enter_valid_pwd_validation))
                  ]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !confirmPwdVisible,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          AppTranslations.of(context)!.text('Confirm Password'),
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
                          errorText: AppTranslations.of(context)!.text(
                              StringConstant.invalid_confirm_pwd_validation))
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
                              _addNewAdmin();
                            }
                          },
                          child: Text(
                              AppTranslations.of(context)!.text('Submit'),
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  _addNewAdmin() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = await DatabaseHelper.shared
          .registerUser(emailController.text, passwordController.text);

      if (user != null) {
        AdminModel model = AdminModel(
            user.uid,
            nameController.text,
            addressController.text,
            emailController.text,
            passwordController.text,
            false,
            false,
            DatabaseHelper.shared.getLoggedInUserModel()?.adminId);

        await DatabaseHelper.shared.addAdminData(model);

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
