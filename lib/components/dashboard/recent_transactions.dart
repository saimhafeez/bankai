import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/plugins/string_extension.dart';
import 'package:bankai/components/single_transaction_wide.dart';
import 'package:bankai/methods/format_date.dart';
import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/common_logos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:requests/requests.dart';

class RecentTransactions extends StatefulWidget {
  const RecentTransactions({super.key});

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {

  bool _loading = false;
  List<dynamic> myTransactions = [];

  fetchRecentTransactions() async {
    setState(() {
      _loading = true;
    });
    DateTime dateTime = DateTime.now();
    log('--> fetchRecentTransactions');
    try {
      var reqBody = {
        "month": "${dateTime.year}-${dateTime.month}",
      };
      log('--> $reqBody');
      var response = await Requests.post("$apiURL/user_transactions/allTransactions", json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      if(response.success){
        myTransactions = res['transactions'];
      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['msg'].toString().toTitleCase())));
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: _loading ? Container(
        padding: const EdgeInsets.all(10),
        child: SpinKitFoldingCube(size: 30, color: HexColor("#314BCE")),
      ) : Column(
        children: [
          for(final transaction in myTransactions.reversed)
            SingleTransactionWide(
              data: transaction,
              title: transaction['merchant'],
              amount: transaction['amount'],
              date: formatTransactionDate(DateTime.parse(transaction['createdAt'])),
              // logo: CommonLogos.commons[transaction['merchant'].toString().toLowerCase()] ?? CommonLogos.default_logo,
              logo: CommonLogos.commons.entries.firstWhere((element) => transaction['merchant'].toString().toLowerCase().contains(element.key.toLowerCase()), orElse: () => CommonLogos.commons.entries.first).value,
              bottomMargin: transaction['_id'] == myTransactions.first['_id'] ? 0 : 10,
            )
        ],
      ),
    );
  }
}
