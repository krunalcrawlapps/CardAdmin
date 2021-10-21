import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/models/price_model.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        title: Text(AppTranslations.of(context)!.text('Prices')),
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
              child: Text(
                  AppTranslations.of(context)!.text(snapshot.error.toString())),
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
              return Dismissible(
                direction: DismissDirection.endToStart,
                resizeDuration: Duration(milliseconds: 200),
                key: ObjectKey(data.docs.elementAt(index)),
                confirmDismiss: (direction) async {
                  showConfirmationDialog(context, StringConstant.confirm_delete,
                      () async {
                    await DatabaseHelper.shared
                        .deletePrices(data.docs[index].data());
                  });
                },
                onDismissed: (direction) {},
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
                                Text(AppTranslations.of(context)!
                                        .text('Customer: ') +
                                    data.docs[index].data().custName),
                                SizedBox(height: 5),
                                Text(AppTranslations.of(context)!
                                        .text('Date: ') +
                                    DateFormat(
                                            'dd/MM/yyyy, hh:mm a',
                                            Localizations.localeOf(context)
                                                .languageCode)
                                        .format(
                                            DateFormat('dd/MM/yyyy, hh:mm a')
                                                .parse(data.docs[index]
                                                    .data()
                                                    .timestamp))),
                                SizedBox(height: 5),
                                Text(AppTranslations.of(context)!
                                        .text('Vendor: ') +
                                    data.docs[index].data().vendorName),
                                SizedBox(height: 5),
                                Text(AppTranslations.of(context)!
                                        .text('Category: ') +
                                    data.docs[index].data().catName),
                                SizedBox(height: 5),
                                Text(AppTranslations.of(context)!
                                        .text('Sub Category: ') +
                                    data.docs[index].data().subCatName),
                                SizedBox(height: 5),
                                Text(AppTranslations.of(context)!
                                        .text('Amount: ') +
                                    data.docs[index].data().price.toString()),
                                SizedBox(height: 5),
                                Text(AppTranslations.of(context)!
                                        .text('Currency: ') +
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
