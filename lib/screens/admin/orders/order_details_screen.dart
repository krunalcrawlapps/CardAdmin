import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/utils/date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel orderModel;
  const OrderDetailsScreen(this.orderModel, {Key? key}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final cardsRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.cards)
      .withConverter<CardModel>(
        fromFirestore: (snapshots, _) => CardModel.fromJson(snapshots.data()!),
        toFirestore: (card, _) => card.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Order By:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 5),
                  Text(widget.orderModel.custName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                ]),
                SizedBox(height: 10),
                Row(children: [
                  Text('Order Date:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 5),
                  Text(
                      DateTimeUtils.getDateTime(
                          widget.orderModel.transactionDateTime),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                ]),
                SizedBox(height: 10),
                Text('Ordered Cards:', style: TextStyle(fontSize: 16)),
                getCardList()
              ]),
        ),
      ),
    );
  }

  Widget getCardList() {
    return StreamBuilder<QuerySnapshot<CardModel>>(
      stream: cardsRef
          .where('card_id',
              whereIn: widget.orderModel.arrCards.length == 0
                  ? ['']
                  : widget.orderModel.arrCards)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return Container(
              padding: EdgeInsets.all(20),
              child: const Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.requireData;

        if (data.size == 0) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text('No Cards Found!'),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: getCard(data.docs[index].data()));
            },
          ),
        );
      },
    );
  }

  Widget getCard(CardModel card) {
    return Container(
      width: double.infinity,
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(card.cardVendor),
              SizedBox(height: 5),
              Text(card.cardNumber.toString()),
              SizedBox(height: 5),
              Text(card.amount.toString()),
            ]),
      )),
    );
  }
}
