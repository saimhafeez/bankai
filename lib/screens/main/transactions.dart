import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/plugins/string_extension.dart';
import 'package:bankai/components/single_transaction_wide.dart';
import 'package:bankai/methods/format_date.dart';
import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/common_logos.dart';
import 'package:bankai/statics/months.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:requests/requests.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  bool _loading = false;
  List<dynamic> myTransactions = [];
  String date = "${DateTime.now().year}-${DateTime.now().month}";

  fetchRecentTransactions() async {
    setState(() {
      _loading = true;
    });

    log('--> fetchRecentTransactions');
    try {
      var reqBody = {
        "month": date,
      };
      log('--> $reqBody');
      var response = await Requests.post(
          "$apiURL/user_transactions/allTransactions",
          json: reqBody,
          timeoutSeconds: CONNECTION_TIMEOUT_SECONDS
      );
      dynamic res = jsonDecode(response.body);
      if (response.success) {
        myTransactions = res['transactions'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['msg'].toString().toTitleCase())));
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      log("exception: $e");
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecentTransactions();
  }

  @override
  Widget build(BuildContext context) {

    showPicker() async {
      showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      ).then((_date) {
        if (_date != null) {
          setState(() {
            date = "${_date.year}-${_date.month}";
          });
          fetchRecentTransactions();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('Transactions'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)))),
                  ),
                  // icon: const ImageIcon(
                  //   AssetImage("assets/images/card_gear.png"),
                  //   color: Colors.black87,
                  //   size: 27,
                  // ),
                  icon: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded),
                      Text(MonthsShort[int.parse(date.split('-')[1])].toString().toUpperCase())
                    ],
                  ),
                  onPressed: showPicker
              ),
            ),
          ]),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _loading
              ? Container(
                  padding: const EdgeInsets.all(10),
                  child: SpinKitFoldingCube(
                      size: 30, color: HexColor("#314BCE")),
                )
              : Column(
                  children: [
                    myTransactions.isEmpty ? Center(child: Text("No Transactions for $date")) : SizedBox(),
                    for (final transaction in myTransactions.reversed)
                      SingleTransactionWide(
                        data: transaction,
                        title: transaction['merchant'],
                        amount: transaction['amount'],
                        date: formatTransactionDate(DateTime.parse(transaction['createdAt'])),
                        // logo: CommonLogos.commons[transaction['merchant']
                        //         .toString()
                        //         .toLowerCase()] ??
                        //     CommonLogos.default_logo,
                        logo: CommonLogos.commons.entries.firstWhere((element) => transaction['merchant'].toString().toLowerCase().contains(element.key.toLowerCase()), orElse: () => CommonLogos.commons.entries.first).value,
                        bottomMargin:
                            transaction['_id'] == myTransactions.first['_id']
                                ? 0
                                : 10,
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
