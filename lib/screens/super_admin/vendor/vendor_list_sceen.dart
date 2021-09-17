import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/vendor_model.dart';
import 'package:card_app_admin/screens/super_admin/vendor/add_vendor_screen.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({Key? key}) : super(key: key);

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final vendorRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.vendors)
      .withConverter<VendorModel>(
        fromFirestore: (snapshots, _) =>
            VendorModel.fromJson(snapshots.data()!),
        toFirestore: (vendor, _) => vendor.toJson(),
      );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Vendors'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AddVendorScreen()));
              },
              icon: Icon(Icons.add, size: 20)),
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<VendorModel>>(
        stream: vendorRef
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
              child: Text(StringConstant.no_data_found),
            );
          }

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Dismissible(
                    key: ValueKey<String>(data.docs[index].data().vendorId),
                    confirmDismiss: (DismissDirection direction) async {
                      showConfirmationDialog(
                          context, StringConstant.confirm_delete, () async {
                        DatabaseHelper.shared
                            .deleteVendor(data.docs[index].data().vendorId);
                      });
                    },
                    onDismissed: (direction) {},
                    background: Container(
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
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
                                    AddVendorScreen(
                                        vendorModel: data.docs[index].data())));
                      },
                      child: Container(
                        width: double.infinity,
                        child: Card(
                            child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text(data.docs[index].data().vendorName),
                                SizedBox(height: 5),
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
