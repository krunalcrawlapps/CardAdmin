import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/admin_model.dart';
import 'package:card_app_admin/screens/common/profile_screen.dart';
import 'package:card_app_admin/screens/super_admin/admin/add_admin_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({Key? key}) : super(key: key);

  @override
  _AdminListScreenState createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  final adminRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.admins)
      .withConverter<AdminModel>(
        fromFirestore: (snapshots, _) => AdminModel.fromJson(snapshots.data()!),
        toFirestore: (admin, _) => admin.toJson(),
      );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppTranslations.of(context)!
                            .text(StringConstant.admins)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AddAdminScreen()));
              },
              icon: Icon(Icons.add, size: 20)),
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<AdminModel>>(
        stream: adminRef
            .where('superAdminId',
                isEqualTo:
                    DatabaseHelper.shared.getLoggedInUserModel()?.adminId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;

          if (data.size == 0) {
            return Center(
              child: Text(AppTranslations.of(context)!
                            .text(StringConstant.no_data_found)),
            );
          }

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Dismissible(
                    direction: data.docs[index].data().isBlock
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    key: ValueKey<String>(data.docs[index].data().adminId),
                    confirmDismiss: (DismissDirection direction) async {
                      showConfirmationDialog(
                          context, 'Are you sure you want block this admin?',
                          () async {
                        try {
                          showLoader(_scaffoldKey.currentContext ?? context);
                          await DatabaseHelper.shared
                              .blockAdmin(data.docs[index].data());
                          hideLoader(_scaffoldKey.currentContext ?? context);
                        } catch (error) {
                          showAlert(context, error.toString());
                          hideLoader(_scaffoldKey.currentContext ?? context);
                        }
                      });
                    },
                    onDismissed: (direction) {},
                    background: Container(
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ProfileScreen(
                                        adminModel: data.docs[index].data())));
                      },
                      child: Container(
                        width: double.infinity,
                        child: Card(
                            color: data.docs[index].data().isBlock
                                ? Colors.red
                                : Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 5),
                                    Text(data.docs[index].data().name),
                                    SizedBox(height: 5),
                                    Text(data.docs[index].data().email),
                                  ]),
                            )),
                      ),
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}
