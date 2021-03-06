import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/customer_model.dart';
import 'package:card_app_admin/screens/admin/customer/add_customer_screen.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final custRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.customer)
      .withConverter<CustomerModel>(
        fromFirestore: (snapshots, _) =>
            CustomerModel.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(StringConstant.customers),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AddCustomerScreen()));
              },
              icon: Icon(Icons.add, size: 20)),
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<CustomerModel>>(
        stream: custRef
            .where('admin_id',
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
                    direction: data.docs[index].data().isBlock
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    key: ValueKey<String>(data.docs[index].data().custId),
                    confirmDismiss: (DismissDirection direction) async {
                      showConfirmationDialog(
                          context, 'Are you sure you want block this customer?',
                          () async {
                        try {
                          showProgressDialog(
                              _scaffoldKey.currentContext ?? context);
                          await DatabaseHelper.shared
                              .blockCustomer(data.docs[index].data());
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
                                    AddCustomerScreen(
                                        customerModel:
                                            data.docs[index].data())));
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
                                    Text(data.docs[index].data().custName),
                                    SizedBox(height: 5),
                                    Text(data.docs[index].data().custEmail),
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
