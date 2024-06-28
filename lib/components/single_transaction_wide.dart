import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/bank_card_detailed.dart';
import 'package:bankai/methods/fomat_currency.dart';
import 'package:bankai/methods/format_date.dart';
import 'package:bankai/methods/helping.dart';
import 'package:bankai/methods/show_loading.dart';
import 'package:bankai/statics/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:requests/requests.dart';
import 'package:shimmer/shimmer.dart';

import '../json/json.dart';

class SingleTransactionWide extends StatelessWidget {
  final int amount;
  final String logo;
  final String date;
  final String title;
  final double bottomMargin;
  final dynamic data;
  SingleTransactionWide(
      {required this.title,
      required this.date,
      required this.amount,
      required this.logo,
      this.bottomMargin = 10,
      this.data = "",
      super.key});

  @override
  Widget build(BuildContext context) {
    displayReceipt() async {

      LoadingObj loadingObj = LoadingObj(context: context, message: "wait...");
      showLoading(loadingObj);

      dynamic card = "";
      String cardId = data['isVirtualCardUsed'] ? data['transaction_virtual_card'] : data['transaction_card'];
      log('** ${data['isVirtualCardUsed']} ** ${data['transaction_virtual_card']} ** ${data['transaction_card']}');
      log('cardId --> $cardId');

      try {
        var URL = data['isVirtualCardUsed'] ? "$apiURL/card/user/virtual_card" : "$apiURL/card/$cardId";
        var response = await Requests.get(URL, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
        dynamic res = jsonDecode(response.body);
        log('response: ${res}');

        if(response.success){
          card = data['isVirtualCardUsed'] ? res['userVirtualCard'] : res['card'];
        }

      } catch (e) {

        log("exception: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("exception: $e")));

      }

      Navigator.pop(loadingObj.dialogContext!);

      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(
                              0.2), // Adjust for desired opacity
                          spreadRadius: 2, // Adjust for desired spread
                          blurRadius: 4, // Adjust for desired blur
                          offset: const Offset(
                              0, 2), // Adjust for desired offset (x, y)
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: CachedNetworkImage(
                      width: 35,
                      height: 35,
                      imageUrl: logo,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: const SizedBox(
                          width: 35,
                          height: 35,
                          child: Icon(Icons.credit_card),
                        ),
                      ),
                    ),
                  ),
                  Text(data['merchant'], style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24
                    // color: HexColor("#314BCE")
                  )),
                  Text(formatTransactionDate(DateTime.parse(data['createdAt'])), style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    // color: HexColor("#FF897E")
                  )),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(style: const TextStyle(fontSize: 16),data['isVirtualCardUsed'] && !data['isWalletUsed'] ? "Loaned ": "Paid "),
                    Text(style: TextStyle(fontSize: 16, color: HexColor("#FF897E"), fontWeight: FontWeight.bold),"PKR ${formatCurrency(data['amount'])}"),
                    const Text(style: TextStyle(fontSize: 16), " From"),
                  ]),
                  if(card != "")
                    BankCardDetailed(
                        cardNumber: formatCardNumber(card['cardNumber'].toString()),
                        expiryDate: formatDate(card['expiryDate']),
                        issueDate: formatDate(card['issueDate']),
                        cardHolderName: card['cardHolderName'],
                        cvvCode: card['cvv'].toString(),
                        bankName: data['isVirtualCardUsed'] ? "Bankai" : card['bankName'],
                        cardType: data['isVirtualCardUsed'] ? "V.Card" : card['cardType']
                    )

                ],
              ),
            ),
          );
        },
      );

    }

    return GestureDetector(
      onTap: data == "" ? () {} : displayReceipt,
      child: Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey
                        .withOpacity(0.2), // Adjust for desired opacity
                    spreadRadius: 2, // Adjust for desired spread
                    blurRadius: 4, // Adjust for desired blur
                    offset:
                        const Offset(0, 2), // Adjust for desired offset (x, y)
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: CachedNetworkImage(
                width: 35,
                height: 35,
                imageUrl: logo,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: const SizedBox(
                    width: 35,
                    height: 35,
                    child: Icon(Icons.credit_card),
                  ),
                ),
              ),
            ),
            Container(
              width: 5,
            ),
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        title),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        date),
                  )
                ],
              ),
            ),
            Text(
                style: const TextStyle(fontWeight: FontWeight.bold),
                "${formatCurrency(amount)} PKR"),
          ],
        ),
      ),
    );
  }
}
