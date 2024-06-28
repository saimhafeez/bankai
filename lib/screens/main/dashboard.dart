import 'dart:convert';
import 'dart:developer';
import 'package:bankai/components/bank_card_detailed.dart';
import 'package:bankai/components/dashboard/drawer_profile.dart';
import 'package:bankai/components/dashboard/recent_transactions.dart';
import 'package:bankai/components/plugins/string_extension.dart';
import 'package:bankai/methods/fomat_currency.dart';
import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pay/pay.dart';
import 'package:requests/requests.dart';

import '../../methods/helping.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class Destination {
  final String label;
  final Widget icon;
  final Widget selectedIcon;
  const Destination(this.label, this.icon, this.selectedIcon);
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  dynamic stats = {
    "loan": "-- --",
    "spent": "-- --",
  };

  dynamic bankaiCard = {
    "cardHolderName": "---- ---",
    "cardNumber": "0000000000000000",
    "cvv": "---",
    "issueDate": "**/**",
    "expiryDate": "**/**",
    "wallet_amount": "---"
  };
  int balance = 0;
  bool loadingBankaiCard = false;
  TextEditingController recharge_amount = TextEditingController();

  final Future<PaymentConfiguration> _googlePayConfigFuture =
      PaymentConfiguration.fromAsset('google_pay.json');

  fetchBankaiCard() async {
    setState(() {
      loadingBankaiCard = true;
    });

    try {
      var response = await Requests.get("$apiURL/card/user/virtual_card",
          timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: $res');

      if (response.success) {
        setState(() {
          bankaiCard = res['userVirtualCard'];
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['msg'])));
      }
    } catch (e) {
      log("exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
    }

    setState(() {
      loadingBankaiCard = false;
    });
  }

  calculateStats() async {
    List<dynamic> myTransactions = [];

    DateTime dateTime = DateTime.now();
    log('--> fetchRecentTransactions');
    try {
      var reqBody = {
        "month": "${dateTime.year}-${dateTime.month}",
      };
      log('--> $reqBody');
      var response = await Requests.post(
          "$apiURL/user_transactions/allTransactions",
          json: reqBody,
          timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      if (response.success) {
        myTransactions = res['transactions'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['msg'].toString().toTitleCase())));
      }
    } catch (e) {
      log("exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
    }

    //   calculating stats
    double loan = 0;
    double spent = 0;

    for (final transaction in myTransactions) {
      if (transaction['isVirtualCardUsed']) {
        loan = loan + double.parse(transaction['amount'].toString());
      }
      spent = spent + double.parse(transaction['amount'].toString());
    }

    log("loan: $loan :: spent: $spent");

    setState(() {
      stats = {"loan": loan, "spent": spent};
    });
  }

  getRemainingDays() {
    DateTime now = DateTime.now();
    int totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return totalDaysInMonth - now.day;
  }

  void onGooglePayResult(paymentResult) async {
    // Send the resulting Google Pay token to your server / PSP
    try {
      log('----> $paymentResult');
      var reqBody = {"recharge_amount": int.parse(recharge_amount.text)};

      log("----> $reqBody");

      var response = await Requests.post("$apiURL/card/user/recharge_wallet",
          json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: $res');

      if (res['msg'] != null) {
        fetchBankaiCard();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['msg'])));
        Navigator.of(context).pop();
        setState(() {
          recharge_amount.text = "";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void onGooglePayError(error) {
    log('----> $error');
  }

  rechargeWalletModal() {
    recharge_amount.text = "";
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10),
                        child: Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: HexColor("#314BCE")),
                            'Recharge Bankai Wallet'),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 10),
                    child: TextFormField(
                      controller: recharge_amount,
                      decoration: InputDecoration(
                        fillColor: HexColor("#f5f6fa"),
                        filled: true,
                        border: InputBorder.none,
                        labelText: "Enter Amount",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 10),
                    child: recharge_amount.text != ""
                        ? FutureBuilder<PaymentConfiguration>(
                            future: _googlePayConfigFuture,
                            builder: (context, snapshot) => snapshot.hasData
                                ? GooglePayButton(
                                    width: 300,
                                    paymentConfiguration: snapshot.data!,
                                    paymentItems: [
                                      PaymentItem(
                                        label: 'Total',
                                        amount: recharge_amount.text != ""
                                            ? recharge_amount.text
                                            : "0",
                                        status: PaymentItemStatus.final_price,
                                      )
                                    ],
                                    type: GooglePayButtonType.pay,
                                    margin: const EdgeInsets.only(top: 15.0),
                                    onPaymentResult: onGooglePayResult,
                                    onError: onGooglePayError,
                                    loadingIndicator: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : SizedBox.fromSize(
                                    size: const Size(300, 300),
                                    child: const Text(
                                        "Google Pay Not Supported on This Device")))
                        : const SizedBox(),
                  ),
                ],
              ),
            ));
    // showMaterialModalBottomSheet(
    //   context: context,
    //
    //   builder: (context) => SafeArea(
    //     top: false,
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         TextFormField(
    //           controller: recharge_amount,
    //           decoration: InputDecoration(
    //             fillColor: HexColor("#f5f6fa"),
    //             filled: true,
    //             border: InputBorder.none,
    //             labelText: "Amount",
    //             hintText: 'Amount in PKR',
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  @override
  void initState() {
    super.initState();
    IsLoggedIn.instance.getCurrentUser();
    fetchBankaiCard();
    calculateStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          size: 20,
        ),
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            backgroundColor:
                WidgetStateProperty.resolveWith((states) => Colors.white),
          ),
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)))),
              backgroundColor:
                  WidgetStateProperty.resolveWith((states) => Colors.white),
            ),
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              setState((){
              stats = {
              "loan": "-- --",
              "spent": "-- --",
              };;
                  bankaiCard = {
                  "cardHolderName": "---- ---",
                  "cardNumber": "0000000000000000",
                  "cvv": "---",
                  "issueDate": "**/**",
                  "expiryDate": "**/**",
                  "wallet_amount": "---"
                  };
              });
              fetchBankaiCard();
              calculateStats();
            },
          ),
        ],
      ),
      drawer: const Drawer(
        child: DrawerProfile(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BankCardDetailed(
                  cardNumber:
                      formatCardNumber(bankaiCard['cardNumber'].toString())
                          .toString(),
                  expiryDate: bankaiCard['expiryDate'] == '**/**'
                      ? bankaiCard['expiryDate']
                      : formatDate(bankaiCard['expiryDate']),
                  issueDate: bankaiCard['issueDate'] == '**/**'
                      ? bankaiCard['issueDate']
                      : formatDate(bankaiCard['issueDate']),
                  cardHolderName: bankaiCard['cardHolderName'],
                  cvvCode: bankaiCard['cvv'].toString(),
                  bankName: "Bankai",
                  cardType: "V.Card"),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                children: [
                  Column(
                    children: [
                      IconButton(
                          iconSize: 20,
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.white)),
                          onPressed: () {
                            // Navigator.pushNamed(context, '/my-cards');
                            context.push('/my-cards');
                          },
                          icon: const Icon(Icons.credit_card_rounded)),
                      const Text('My Cards')
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          iconSize: 20,
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.white)),
                          onPressed: () {
                            context.push('/transactions');
                          },
                          icon: const Icon(Icons.receipt_long_rounded)),
                      const Text('Transactions')
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          iconSize: 20,
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.white)),
                          onPressed: () {
                            context.push('/notifications');
                          },
                          icon: const Icon(Icons.notifications_outlined)),
                      const Text('Notifications')
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: 40,
                            decoration: BoxDecoration(
                              color: HexColor("#314BCE"),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    "Wallet Balance"),
                                Text(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    "${bankaiCard['wallet_amount'] is int ? formatCurrency(bankaiCard['wallet_amount']) : bankaiCard['wallet_amount']} PKR"),
                                GestureDetector(
                                  onTap: rechargeWalletModal,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.white),
                                        color: Colors.white70,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Text(
                                        style: TextStyle(
                                            color: HexColor("#314BCE"),
                                            fontWeight: FontWeight.bold),
                                        "Recharge 💳"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: 40,
                            decoration: BoxDecoration(
                              color: HexColor("#FF897E"),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    "Pending Loan"),
                                Text(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    "${bankaiCard['loan_taken'] is int ? formatCurrency(bankaiCard['loan_taken']) : "---" } PKR"),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Text(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      (bankaiCard['loan_taken'] is int && bankaiCard['loan_taken'] <= 0)
                                          ? "🥳"
                                          : "Charged in ${getRemainingDays()} Days"),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      "Recent Transactions"),
                ),
              ),
              loadingBankaiCard ? Container(
                padding: const EdgeInsets.all(10),
                child: SpinKitFoldingCube(size: 30, color: HexColor("#314BCE")),
              ) : RecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }
}
