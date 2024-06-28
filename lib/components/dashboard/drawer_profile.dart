import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/plugins/string_extension.dart';
import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pay/pay.dart';
import 'package:requests/requests.dart';
import 'package:shimmer/shimmer.dart';

class DrawerProfile extends StatefulWidget {
  const DrawerProfile({super.key});

  @override
  State<DrawerProfile> createState() => _DrawerProfileState();
}

class _DrawerProfileState extends State<DrawerProfile> {
  @override
  Widget build(BuildContext context) {
    const _paymentItems = [
      PaymentItem(
        label: 'Total',
        amount: '3000',
        status: PaymentItemStatus.final_price,
      )
    ];

    void onGooglePayResult(paymentResult) async {
      // Send the resulting Google Pay token to your server / PSP
      log('----> $paymentResult');

      try{
        var response = await Requests.get("$apiURL/user/account/premium-subscription", timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
        dynamic res = jsonDecode(response.body);
        log('response: ${res}');

        final cookieJar = await Requests.getStoredCookies("$apiURL");
        final token = cookieJar.values
            .firstWhere((element) => element.name == 'token')
            .value;
        log('------------------------------------');
        log(token);
        log('------------------------------------');
        await IsLoggedIn.instance.saveSession(token);

        if (res['msg'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg'])));
          Navigator.of(context).pop();
        }

      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }

    }

    void onGooglePayError(error) {
      log('----> $error');
    }

    final Future<PaymentConfiguration> _googlePayConfigFuture =
        PaymentConfiguration.fromAsset('google_pay.json');

    int getRemainingDaysFromPresent(String endingDate) {
      DateTime expiryDate = DateTime.parse(endingDate);

      // Get the current date and time
      DateTime now = DateTime.now();

      // Calculate the difference between the expiry date and the current date
      Duration difference = expiryDate.difference(now);

      // Extract the remaining days from the difference
      return difference.inDays;
    }

    return Column(
      children: [
        UserAccountsDrawerHeader(
          currentAccountPicture: Image.asset(
            "assets/images/user.png",
            height: 65,
            width: 65,
          ),
          accountEmail:
              Text('${(IsLoggedIn.instance.lastUpdate?.data)['email']}'),
          accountName: Row(
            children: [
              Text(
                '${(IsLoggedIn.instance.lastUpdate?.data)['firstName']} ${(IsLoggedIn.instance.lastUpdate?.data)['lastName']}'
                    .toTitleCase(),
                style: const TextStyle(fontSize: 24.0),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: HexColor("ffbf08"),
                ),
                child: Text(
                  (IsLoggedIn.instance.lastUpdate?.data)['isPremiumUser']
                      ? getRemainingDaysFromPresent((IsLoggedIn
                                  .instance
                                  .lastUpdate
                                  ?.data)["subscription_expiry_Date"]) <
                              0
                          ? "Subscription Expired"
                          : "Premium User"
                      : getRemainingDaysFromPresent((IsLoggedIn
                                  .instance
                                  .lastUpdate
                                  ?.data)["subscription_expiry_Date"]) <
                              0
                          ? "Free Trial Expired"
                          : "Free Trial",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.black),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              // color: Colors.black87,
              color: HexColor("2f49ce")),
          otherAccountsPictures: [
            IconButton(
              onPressed: () {
                IsLoggedIn.instance.update(Session("", ""));
              },
              icon: const Icon(Icons.logout),
              style: const ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.white)),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 2, color: Colors.black12)),
            child: Column(
              children: [
                const Text(
                  "Monthly Subscription",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "3,000 PKR / Month",
                  style: TextStyle(fontSize: 16),
                ),
                LinearProgressIndicator(
                  value: 1 - (getRemainingDaysFromPresent((IsLoggedIn.instance
                      .lastUpdate?.data)["subscription_expiry_Date"]) /
                      30 < 0 ? 1 : getRemainingDaysFromPresent((IsLoggedIn.instance
                      .lastUpdate?.data)["subscription_expiry_Date"]) /
                      30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("0"),
                    Text(
                        (getRemainingDaysFromPresent((IsLoggedIn.instance.lastUpdate?.data)["subscription_expiry_Date"]) < 0
                          ? "No Subscription"
                         : "${getRemainingDaysFromPresent((IsLoggedIn.instance.lastUpdate?.data)["subscription_expiry_Date"])
                        } Days Remaining")
                    ),
                    const Text(("30"))
                  ],
                ),
                if (getRemainingDaysFromPresent((IsLoggedIn.instance.lastUpdate?.data)["subscription_expiry_Date"]) < 0)
                  FutureBuilder<PaymentConfiguration>(
                      future: _googlePayConfigFuture,
                      builder: (context, snapshot) => snapshot.hasData
                          ? GooglePayButton(
                              width: 300,
                              paymentConfiguration: snapshot.data!,
                              paymentItems: _paymentItems,
                              type: GooglePayButtonType.subscribe,
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
                                  "Google Pay Not Supported on This Device"))),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ElevatedButton(
                  //     onPressed: () {},
                  //     style: ButtonStyle(
                  //       shape: WidgetStateProperty.all(LinearBorder.none),
                  //       elevation: WidgetStateProperty.all(0),
                  //     ),
                  //     child: const Row(
                  //       children: [
                  //         // Icon(Icons.settings),
                  //         // SizedBox(width: 5),
                  //         Text("Profile"),
                  //       ],
                  //     )),
                  ElevatedButton(
                      onPressed: () {
                        if((IsLoggedIn.instance.lastUpdate?.data)['kycStatus'] != 'verified'){
                        context.push('/kyc');
                        }
                      },
                      style: ButtonStyle(
                        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(width: 2, color: Colors.black12),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("KYC Verification Center"),
                          // SizedBox(width: 5),
                          Image.asset(
                            "assets/images/${IsLoggedIn.instance.lastUpdate?.data['kycStatus'] == 'verified' ? 'check_mark' : 'expired'}.png",
                            height: 25,
                            width: 25,
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        )
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/user.png",
                    height: 65,
                    width: 65,
                  ),
                  Text(
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 20),
                      '${(IsLoggedIn.instance.lastUpdate?.data)['firstName']} ${(IsLoggedIn.instance.lastUpdate?.data)['lastName']}'
                          .toTitleCase()),
                  Text(
                      style: const TextStyle(fontSize: 16),
                      (IsLoggedIn.instance.lastUpdate?.data)['isPremiumUser']
                          ? 'Premium User'
                          : 'Free Trial'),
                ],
              ),
              if ((IsLoggedIn.instance.lastUpdate?.data)['isPremiumUser'] ==
                  false)
                FutureBuilder<PaymentConfiguration>(
                    future: _googlePayConfigFuture,
                    builder: (context, snapshot) => snapshot.hasData
                        ? GooglePayButton(
                            width: 300,
                            paymentConfiguration: snapshot.data!,
                            paymentItems: _paymentItems,
                            type: GooglePayButtonType.subscribe,
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
                                "Google Pay Not Supported on This Device"))),
              ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(LinearBorder.none),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: const Row(
                    children: [
                      // Icon(Icons.settings),
                      // SizedBox(width: 5),
                      Text("Profile"),
                    ],
                  )),
              ElevatedButton(
                  onPressed: () {
                    context.push('/kyc');
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(LinearBorder.none),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("KYC Verification Center"),
                      // SizedBox(width: 5),
                      Image.asset(
                        "assets/images/${IsLoggedIn.instance.lastUpdate?.data['kycStatus'] == 'verified' ? 'check_mark' : 'expired'}.png",
                        height: 25,
                        width: 25,
                      ),
                    ],
                  )),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                IsLoggedIn.instance.update(Session("", ""));
              },
              child: Text("logout"))
        ],
      ),
    );
  }
}
