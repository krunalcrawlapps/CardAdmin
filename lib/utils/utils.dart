import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/screens/auth_screens/login_screen.dart';
import 'package:card_app_admin/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

showProgressDialog(BuildContext context) => showDialog(
    context: context, builder: (BuildContext context) => LoaderDialog());

showLoader(BuildContext context) {
  showProgressDialog(context);
}

hideLoader(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}

String getRandomId() {
  var uuid = Uuid();
  return uuid.v1();
}

showAlert(BuildContext context, String msg) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(msg),
          actions: [
            ElevatedButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to logout?"),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                DatabaseHelper.shared.clearUserData();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false);
              },
              child: const Text("YES")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("NO"),
          ),
        ],
      );
    },
  );
}

Future<bool> deleteConfirmDialog(
    BuildContext context, Function onDelete) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to delete?"),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onDelete();
              },
              child: const Text("DELETE")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("CANCEL"),
          ),
        ],
      );
    },
  );
}
