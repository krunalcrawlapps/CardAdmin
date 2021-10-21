import 'dart:convert';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/screens/admin/cards/add_cards_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final cardsRef = FirebaseFirestore.instance
      .collection(FirebaseCollectionConstant.cards)
      .withConverter<CardModel>(
        fromFirestore: (snapshots, _) => CardModel.fromJson(snapshots.data()!),
        toFirestore: (card, _) => card.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context)!.text(StringConstant.cards)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AddCardsScreen()));
              },
              icon: Icon(Icons.add, size: 20)),
          IconButton(
              onPressed: () {
                showLogoutDialog(context);
              },
              icon: Icon(Icons.logout, size: 20))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<CardModel>>(
        stream: cardsRef
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
                    direction:
                        data.docs[index].data().cardStatus == CardStatus.used
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                    key: ValueKey<String>(data.docs[index].data().adminId),
                    confirmDismiss: (DismissDirection direction) async {
                      showConfirmationDialog(
                          context, StringConstant.confirm_delete, () {
                        try {
                          DatabaseHelper.shared
                              .deleteCard(data.docs[index].data().cardId);
                        } catch (error) {
                          showAlert(context, error.toString());
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
                                      AddCardsScreen(
                                          cardModel: data.docs[index].data())));
                        },
                        child: getCard(data.docs[index].data())),
                  ));
            },
          );
        },
      ),
    );
  }

  Widget getCard(CardModel card) {
    String cardNumber = "";
    if (card.cardNumber is int) {
      cardNumber = card.cardNumber.toString();
    } else {
      Latin1Decoder latin1Decoder = Latin1Decoder();

      cardNumber = latin1Decoder.convert(base64Decode(card.cardNumber));
    }
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
              Text(AppTranslations.of(context)!.text(card.vendorName)),
              SizedBox(height: 5),
              Text(AppTranslations.of(context)!.text(card.catName)),
              SizedBox(height: 5),
              Text(AppTranslations.of(context)!.text(card.subCatName)),
              SizedBox(height: 5),
              Text(AppTranslations.of(context)!.text(cardNumber)),
              SizedBox(height: 5),
              Text(AppTranslations.of(context)!.text(card.cardStatus))
            ]),
      )),
    );
  }
}
