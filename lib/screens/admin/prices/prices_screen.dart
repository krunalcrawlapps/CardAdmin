import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/models/price_model.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_price_screen.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({Key? key}) : super(key: key);

  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final custRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.prices)
      .withConverter<PricesModel>(
        fromFirestore: (snapshots, _) =>
            PricesModel.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prices'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AddPricesScreen()));
              },
              icon: Icon(Icons.add, size: 20)),
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<PricesModel>>(
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
              return Dismissible(
                direction: DismissDirection.endToStart,
                resizeDuration: Duration(milliseconds: 200),
                key: ObjectKey(data.docs.elementAt(index)),
                onDismissed: (direction) {
                  DatabaseHelper.shared.deletePrices(data.docs[index].data());
                },
                background: Container(
                  padding: EdgeInsets.only(left: 28.0),
                  alignment: AlignmentDirectional.centerStart,
                  color: Colors.red,
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Container(
                      width: double.infinity,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AddPricesScreen(
                                        cardModel: data.docs[index].data(),
                                      )));
                        },
                        child: Card(
                            child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text('Customer: ' +
                                    data.docs[index].data().custName),
                                SizedBox(height: 5),
                                Text('Date: ' +
                                    data.docs[index].data().timestamp),
                                SizedBox(height: 5),
                                Text('Vendor: ' +
                                    data.docs[index].data().vendorName),
                                SizedBox(height: 5),
                                Text('Category: ' +
                                    data.docs[index].data().catName),
                                SizedBox(height: 5),
                                Text('Sub Category: ' +
                                    data.docs[index].data().subCatName),
                                SizedBox(height: 5),
                                Text('Amount: ' +
                                    data.docs[index].data().price.toString()),
                                SizedBox(height: 5),
                                Text('Currency: ' +
                                    data.docs[index]
                                        .data()
                                        .currencyName
                                        .toString()),
                                SizedBox(height: 5),
                              ]),
                        )),
                      ),
                    )),
              );
            },
          );
        },
      ),
    );
  }
}
