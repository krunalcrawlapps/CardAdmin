import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:card_app_admin/screens/admin/customer/refill_balance_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customerModel;
  const AddCustomerScreen({Key? key, this.customerModel}) : super(key: key);

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
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.customerModel != null) {
      nameController.text = widget.customerModel?.custName ?? '';
      addressController.text = widget.customerModel?.custAddress ?? '';
      emailController.text = widget.customerModel?.custEmail ?? '';
      balanceController.text =
          widget.customerModel?.custBalance.toString() ?? '';
      passwordController.text = widget.customerModel?.custPassword ?? '';
      confirmPasswordController.text = widget.customerModel?.custPassword ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(AppTranslations.of(context)!.text(
                widget.customerModel == null
                    ? 'Add Customer'
                    : 'Edit Customer'))),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(children: <Widget>[
                widget.customerModel?.isBlock ?? false
                    ? getEditView()
                    : Container(),
                SizedBox(height: 10),
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
                  enabled: widget.customerModel == null ? true : false,
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
                widget.customerModel == null
                    ? TextFormField(
                        enabled: widget.customerModel == null ? true : false,
                        controller: balanceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText:
                                AppTranslations.of(context)!.text('Balance'),
                            labelStyle: TextStyle(fontSize: 15)),
                        validator: RequiredValidator(
                            errorText: AppTranslations.of(context)!
                                .text(StringConstant.enter_balance_validation)),
                      )
                    : getRefillBalanceView(),
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
                              if (widget.customerModel == null) {
                                _addNewCustomer();
                              } else {
                                _editCustomer();
                              }
                            }
                          },
                          child: Text(
                              AppTranslations.of(context)!.text(
                                  widget.customerModel == null
                                      ? 'Submit'
                                      : 'Save'),
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  Widget getRefillBalanceView() {
    return Row(children: [
      Expanded(
        child: TextFormField(
          enabled: widget.customerModel == null ? true : false,
          controller: balanceController,
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: AppTranslations.of(context)!.text('Balance'),
              labelStyle: TextStyle(fontSize: 15)),
          validator: RequiredValidator(
              errorText: AppTranslations.of(context)!
                  .text(StringConstant.enter_balance_validation)),
        ),
      ),
      SizedBox(width: 10),
      Container(
        height: 30,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange)),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        RefillCustomerBalanceScreen(
                            widget.customerModel!, true)));
          },
          child: Text(AppTranslations.of(context)!.text('Refill Balance'),
              style: TextStyle(fontSize: 12)),
        ),
      ),
      SizedBox(width: 10),
      Container(
        height: 30,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange)),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        RefillCustomerBalanceScreen(
                            widget.customerModel!, false)));
          },
          child: Text(AppTranslations.of(context)!.text('Update Balance'),
              style: TextStyle(fontSize: 12)),
        ),
      )
    ]);
  }

  Widget getEditView() {
    return Row(
      children: [
        Text(AppTranslations.of(context)!.text('This Customer is Blocked!'),
            style: TextStyle(color: Colors.red)),
        SizedBox(width: 10),
        Container(
          width: 80,
          height: 30,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
            onPressed: () {
              showConfirmationDialog(
                  context, 'Are you sure you want unblock this customer?', () {
                DatabaseHelper.shared.unblockCustomer(widget.customerModel!);
                Navigator.of(context).pop();
              });
            },
            child: Text(AppTranslations.of(context)!.text('Unblock'),
                style: TextStyle(fontSize: 12)),
          ),
        )
      ],
    );
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
            emailController.text,
            false);

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

  _editCustomer() async {
    setState(() {
      isLoading = true;
    });

    try {
      String oldPwd = widget.customerModel?.custPassword ?? '';

      CustomerModel model = widget.customerModel!;
      model.custName = nameController.text;
      model.custAddress = addressController.text;
      model.custPassword = passwordController.text;

      await DatabaseHelper.shared.updateCustomer(oldPwd, model);

      setState(() {
        isLoading = false;
      });

      showAlert(context, 'Customer details updated.', onClick: () {
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
