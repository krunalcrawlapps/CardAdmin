import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DirectChargeOrders extends StatefulWidget {
  const DirectChargeOrders({Key? key}) : super(key: key);

  @override
  _DirectChargeOrdersState createState() => _DirectChargeOrdersState();
}

class _DirectChargeOrdersState extends State<DirectChargeOrders> {
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
        title: Text('Direct Charge Orders'),
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
            .where('isDirectCharge', isEqualTo: true)
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
                  child: Container(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () {},
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
                              Text('Order Date: ' +
                                  data.docs[index].data().transactionDateTime),
                              SizedBox(height: 5),
                              Text('Vendor: ' +
                                  data.docs[index].data().vendorName),
                              SizedBox(height: 5),
                              Text('Category: ' +
                                  data.docs[index].data().catName),
                              SizedBox(height: 5),
                              Text('Amount: ' +
                                  data.docs[index].data().amount.toString()),
                              SizedBox(height: 5),
                              Row(children: [
                                Expanded(
                                  child: Text('Fulfillment Status: ' +
                                      data.docs[index].data().fulfilmentStatus),
                                ),
                                if (data.docs[index].data().fulfilmentStatus ==
                                    'Open')
                                  Container(
                                    width: 90,
                                    height: 30,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.orange)),
                                      onPressed: () {
                                        DatabaseHelper.shared
                                            .updateDirectChargeStatus(data
                                                .docs[index]
                                                .data()
                                                .orderId);
                                      },
                                      child: const Text('Complete',
                                          style: TextStyle(fontSize: 12)),
                                    ),
                                  )
                              ])
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
