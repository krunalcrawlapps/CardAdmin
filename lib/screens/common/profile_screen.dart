import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/admin_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ProfileScreen extends StatefulWidget {
  final AdminModel? adminModel;
  const ProfileScreen({Key? key, this.adminModel}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  bool isFromMyProfile = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.adminModel != null) {
      isFromMyProfile = false;
      //from admin list
      nameController.text = widget.adminModel?.name ?? '';
      addressController.text = widget.adminModel?.address ?? '';
      emailController.text = widget.adminModel?.email ?? '';
      passwordController.text = widget.adminModel?.password ?? '';
      confirmPasswordController.text = widget.adminModel?.password ?? '';
    } else {
      isFromMyProfile = true;
      //from my profile
      AdminModel? admin = DatabaseHelper.shared.getLoggedInUserModel();
      nameController.text = admin?.name ?? '';
      addressController.text = admin?.address ?? '';
      emailController.text = admin?.email ?? '';
      passwordController.text = admin?.password ?? '';
      confirmPasswordController.text = admin?.password ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.adminModel == null
              ? StringConstant.my_profile
              : 'Edit Admin'),
          actions: [
            widget.adminModel == null
                ? IconButton(
                    onPressed: () {
                      showLogoutDialog(context);
                    },
                    icon: Icon(Icons.logout, size: 20))
                : Container()
          ],
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(children: <Widget>[
                widget.adminModel?.isBlock ?? false
                    ? Row(
                        children: [
                          Text('This Admin is Blocked!',
                              style: TextStyle(color: Colors.red)),
                          SizedBox(width: 10),
                          Container(
                            width: 80,
                            height: 30,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red)),
                              onPressed: () {
                                showConfirmationDialog(context,
                                    'Are you sure you want unblock this admin?',
                                    () {
                                  DatabaseHelper.shared
                                      .unblockAdmin(widget.adminModel!);
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text('Unblock',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          )
                        ],
                      )
                    : Container(),
                SizedBox(height: 10),
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
                  enabled: false,
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
                            color: Theme.of(context).primaryColorDark),
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
                              _updateAdmin();
                            }
                          },
                          child: const Text('Save',
                              style: TextStyle(fontSize: 18)),
                        ),
                      )
              ]),
            ))));
  }

  _updateAdmin() async {
    setState(() {
      isLoading = true;
    });
    AdminModel? admin;

    String oldPwd;

    if (isFromMyProfile) {
      admin = DatabaseHelper.shared.getLoggedInUserModel();
      oldPwd = admin?.password ?? '';
    } else {
      admin = widget.adminModel;
      oldPwd = admin?.password ?? '';
    }

    admin?.name = nameController.text;
    admin?.address = addressController.text;
    admin?.password = passwordController.text;
    await DatabaseHelper.shared.updateAdmin(admin!, oldPwd, isFromMyProfile);
    setState(() {
      isLoading = false;
    });

    if (isFromMyProfile) {
      showAlert(context, 'Profile Updated.');
    } else {
      showAlert(context, 'Admin details updated.', onClick: () {
        Navigator.of(context).pop();
      });
    }
  }
}
