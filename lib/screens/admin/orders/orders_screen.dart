import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/screens/admin/orders/order_details_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
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
        title: Text(AppTranslations.of(context)!.text('Orders')),
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
            .where('isDirectCharge', isEqualTo: false)
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
                  child: Container(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OrderDetailsScreen(
                                        data.docs[index].data())));
                      },
                      child: Card(
                          child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(AppTranslations.of(context)!
                                      .text('Order By: ') +
                                  data.docs[index].data().custName),
                              SizedBox(height: 5),
                              Text(AppTranslations.of(context)!
                                      .text('Order Date: ') +
                                  DateFormat(
                                          'dd/MM/yyyy, hh:mm a',
                                          Localizations.localeOf(context)
                                              .languageCode)
                                      .format(DateFormat('dd/MM/yyyy, hh:mm a')
                                          .parse(data.docs[index]
                                              .data()
                                              .transactionDateTime))),
                              SizedBox(height: 5),
                              Text(AppTranslations.of(context)!
                                      .text('Amount: ') +
                                  data.docs[index].data().amount.toString()),
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
}
