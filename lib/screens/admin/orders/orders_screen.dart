import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final custRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.orders)
      .withConverter<OrderModel>(
        fromFirestore: (snapshots, _) => OrderModel.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        actions: [
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<OrderModel>>(
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
                    key: ValueKey<String>(data.docs[index].data().adminId),
                    confirmDismiss: (DismissDirection direction) async {
                      deleteConfirmDialog(context, () {});
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
                              Text('Order By: ' +
                                  data.docs[index].data().custName),
                              SizedBox(height: 5),
                              Text('Card Number: ' +
                                  data.docs[index]
                                      .data()
                                      .cardNumber
                                      .toString()),
                              SizedBox(height: 5),
                              Text('Card Vendor: ' +
                                  data.docs[index].data().cardVendor),
                              SizedBox(height: 5),
                              Text('Order Date: ' +
                                  getDateTime(data.docs[index]
                                      .data()
                                      .transactionDateTime)),
                            ]),
                      )),
                    ),
                  ));
            },
          );
        },
      ),
    );
  }

  String getDateTime(int timestamp) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy, hh:mm a').format(dt);
  }
}
