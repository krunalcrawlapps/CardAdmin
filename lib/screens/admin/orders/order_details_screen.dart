import 'dart:convert';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/models/card_model.dart';
import 'package:card_app_admin/models/order_model.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:card_app_admin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';

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
      appBar: AppBar(
          title: Text(AppTranslations.of(context)!.text('Order Details'))),
      body: Container(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(AppTranslations.of(context)!.text('Order By:'),
                      style: TextStyle(fontSize: 16)),
                  SizedBox(width: 5),
                  Text(widget.orderModel.custName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                ]),
                SizedBox(height: 10),
                Row(children: [
                  Text(AppTranslations.of(context)!.text('Order Date:'),
                      style: TextStyle(fontSize: 16)),
                  SizedBox(width: 5),
                  Text(
                      DateFormat('dd/MM/yyyy, hh:mm a',
                              Localizations.localeOf(context).languageCode)
                          .format(DateFormat('dd/MM/yyyy, hh:mm a')
                              .parse(widget.orderModel.transactionDateTime)),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                ]),
                SizedBox(height: 10),
                SizedBox(height: 10),
                Row(children: [
                  Text(AppTranslations.of(context)!.text('Amount:'),
                      style: TextStyle(fontSize: 16)),
                  SizedBox(width: 5),
                  Text(widget.orderModel.amount.toString(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                ]),
                SizedBox(height: 10),
                Text(AppTranslations.of(context)!.text('Ordered Cards:'),
                    style: TextStyle(fontSize: 16)),
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
              child: Text(AppTranslations.of(context)!.text('No Cards Found!')),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(AppTranslations.of(context)!.text('Vendor: ') +
                        card.vendorName),
                    SizedBox(height: 5),
                    Text(AppTranslations.of(context)!.text('Category: ') +
                        card.catName),
                    SizedBox(height: 5),
                    Text(AppTranslations.of(context)!.text('Sub Category: ') +
                        card.subCatName),
                    SizedBox(height: 5),
                    Text(AppTranslations.of(context)!.text('Card Number: ') +
                        cardNumber),
                    // Text(card.amount.toString()),
                  ]),
            ),
            IconButton(
                onPressed: () async {
                  try {
                    PrinterBluetoothManager printerManager =
                        PrinterBluetoothManager();
                    printerManager.startScan(Duration(seconds: 10));
                    PrinterBluetooth? printer;
                    // store found printers
                    await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Scaffold(
                          body: StreamBuilder<List<PrinterBluetooth>>(
                              stream: printerManager.scanResults,
                              builder: (context, snapshot) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Select Printer",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22),
                                    ),
                                    const SizedBox(height: 30),
                                    (snapshot.data?.isEmpty ?? true)
                                        ? Center(
                                            child: Text(
                                                StringConstant.no_data_found))
                                        : Expanded(
                                            child: ListView.builder(
                                              itemCount: snapshot.data?.length,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: ListTile(
                                                    onTap: () {
                                                      printer =
                                                          snapshot.data?[index];
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    title: Text(snapshot
                                                            .data?[index]
                                                            .name ??
                                                        "-"),
                                                    subtitle: Text(snapshot
                                                            .data?[index]
                                                            .address ??
                                                        "-"),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                );
                              }),
                        );
                      },
                    );
                    printerManager.stopScan();
                    print(printer);
                    if (printer != null) {
                      printerManager.selectPrinter(printer!);
                      List<int> ticket = await testTicket(card);
                      final PosPrintResult res =
                          await printerManager.printTicket(ticket);

                      // print('Print result: ${res.msg}');
                    }
                  } catch (e) {
                    showAlert(context, e.toString());
                  }
                },
                icon: Icon(Icons.print))
          ],
        ),
      )),
    );
  }

  Future<List<int>> testTicket(CardModel card) async {
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    String tranDate = DateFormat(
            'dd/MM/yyyy, hh:mm a', Localizations.localeOf(context).languageCode)
        .format(DateFormat('dd/MM/yyyy, hh:mm a')
            .parse(widget.orderModel.transactionDateTime));

    bytes += generator.text(card.vendorName,
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.text('Card Number: ${card.cardNumber}');
    bytes += generator.text('Name: ${widget.orderModel.custName}');
    bytes += generator.text('Tel: ${widget.orderModel.custMobile}');
    bytes += generator.text('Date Time: $tranDate');
    bytes +=
        generator.text('Serial Number: ${card.serialNumber}', linesAfter: 1);
    bytes += generator.text(
      card.vendorName,
      styles: PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(card.subCatName,
        styles: PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += generator.hr(linesAfter: 1);
    bytes += generator.text('Denomination : ${widget.orderModel.amount}',
        linesAfter: 1);
    bytes += generator.hr();
    bytes += generator.text('Serial Number: ${card.serialNumber}');
    bytes += generator.text('Cashier Id: Admin');

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}
