import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/screens/auth_screens/login_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/widgets/loader_widget.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

showLoader(BuildContext context) => showDialog(
    context: context, builder: (BuildContext context) => LoaderDialog());

hideLoader(BuildContext context) {
  //if (Navigator.of(context).canPop()) {
  Navigator.of(context).pop();
  //}
}

String getRandomId() {
  var uuid = Uuid();
  return uuid.v1();
}

showAlert(BuildContext context, String msg, {Function? onClick}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppTranslations.of(context)!.text("Alert")),
          content: Text(AppTranslations.of(context)!.text(msg)),
          actions: [
            ElevatedButton(
              child: Text(AppTranslations.of(context)!.text("Ok")),
              onPressed: () {
                Navigator.of(context).pop();

                if (onClick != null) {
                  onClick();
                }
              },
            )
          ],
        );
      });
}

showLogoutDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppTranslations.of(context)!.text("Confirm")),
        content: Text(AppTranslations.of(context)!
            .text("Are you sure you want to logout?")),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                DatabaseHelper.shared.clearUserData();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              },
              child: Text(AppTranslations.of(context)!.text("YES"))),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.of(context)!.text("NO")),
          ),
        ],
      );
    },
  );
}

Future<bool> showConfirmationDialog(
    BuildContext context, String message, Function onConfirm) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppTranslations.of(context)!.text("Confirm")),
        content: Text(AppTranslations.of(context)!.text(message)),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm();
              },
              child: Text(AppTranslations.of(context)!.text("Yes"))),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.of(context)!.text("No")),
          ),
        ],
      );
    },
  );
}
