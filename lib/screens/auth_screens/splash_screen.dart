import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/admin_model.dart';
import 'package:card_app_admin/screens/admin/home_screen.dart';
import 'package:card_app_admin/screens/super_admin/super_admin_home.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;
  bool isBlock = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 10), () {
      _checkLoggedInUserAndNavigate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Image.asset(ImageConstant.logo_img,
                fit: BoxFit.scaleDown, width: 80, height: 80),
            SizedBox(height: 30),
            Text(
              'Welcome To Card app!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : isBlock
                    ? Text(
                        'Your account has been blocked!. Please contact super admin.',
                        style: TextStyle(color: Colors.red))
                    : Container()
          ])),
    );
  }

  Future<Widget?> _checkLoggedInUserAndNavigate(BuildContext context) async {
    // User? user = FirebaseAuth.instance.currentUser;

    AdminModel? admin = DatabaseHelper.shared.getLoggedInUserModel();

    if (admin != null) {
      AdminModel? currentUser =
          await DatabaseHelper.shared.getUserDataFromFirebase(admin.adminId);

      if (currentUser != null) {
        if (currentUser.isBlock) {
          isBlock = true;
          showAlert(context, 'Your account has been blocked!');
        } else {
          DatabaseHelper.shared.saveUserModel(currentUser);

          if (currentUser.isSuperAdmin) {
            //user is super admin
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => SuperAdminHome()));
          } else {
            //user is normal admin
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen()));
          }
        }
      } else {
        showAlert(context, ErrorMessage.something_wrong);
      }
    } else {
      //do login
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
    }

    setState(() {
      isLoading = false;
    });
  }
}
