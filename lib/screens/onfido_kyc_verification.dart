import 'dart:convert';
import 'dart:developer';
import 'package:bankai/methods/app_state_observer.dart';
import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:requests/requests.dart';
import 'package:url_launcher/url_launcher.dart';

class OnFidoKYCVerification extends StatefulWidget {
  const OnFidoKYCVerification({super.key});

  @override
  State<OnFidoKYCVerification> createState() => _OnFidoKYCVerificationState();
}

class _OnFidoKYCVerificationState extends State<OnFidoKYCVerification> {

  String workflow_id = "31ba6e4e-4e67-4e91-a129-6be9ad0287b1";
  String api_token = "api_sandbox.ygMWLZFxaAX.jP6GbDSdenivhR1LKCQ_jIX4RzdaMAMN";

  makeReq() async {
    //   generate SDK Token
    // https://api.eu.onfido.com/v3.6/
    // var reqBody = {
    //   "email": email.text.toLowerCase(),
    //   "password": password.text,
    // };

    String applicant_id = "";

    // Create an Applicant
    // https://api.eu.onfido.com/v3.6/applicants/
    try {

      var reqBody = {
        "first_name": (IsLoggedIn.instance.lastUpdate?.data)['firstName'],
        "last_name": (IsLoggedIn.instance.lastUpdate?.data)['lastName'],
        "email": (IsLoggedIn.instance.lastUpdate?.data)['email'],
      };

      log('--> reqBody $reqBody');

      var response = await Requests.post(
          "https://api.eu.onfido.com/v3.6/applicants/",
          headers: {
            'Authorization': 'Token token=$api_token',
            'Content-Type': 'application/json'
          },
          json: reqBody,
      );
      dynamic res = jsonDecode(response.body);
      log('response: ${res}');

      // ScaffoldMessenger.of(context)
          // .showSnackBar(SnackBar(content: Text("${res.toString()}")));

      applicant_id = res['id'];

    }catch(e){
      log("exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
      return;
    }

    // Set Applicant ID
    try {

      var reqBody = {
        "applicantId": applicant_id,
      };

      var response = await Requests.post(
        "$apiURL/user/setApplicantId",
        json: reqBody,
      );
      dynamic res = jsonDecode(response.body);
      log('response: ${res}');

      // ScaffoldMessenger.of(context)
      // .showSnackBar(SnackBar(content: Text("${res.toString()}")));

    }catch(e){
      log("exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
      return;
    }

    // Workflow Run
    try {

      var reqBody = {
        "workflow_id": workflow_id,
        "applicant_id": applicant_id,
        "link": {
          "completed_redirect_url": "https://fa23se18.000webhostapp.com/kyc-applied"
        }
      };

      var response = await Requests.post(
          "https://api.eu.onfido.com/v3.5/workflow_runs",
          headers: {
            'Authorization': 'Token token=$api_token',
            'Content-Type': 'application/json'
          },
          json: reqBody,
      );
      dynamic res = jsonDecode(response.body);
      log('response: ${res}');

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text("${res.toString()}")));

      final Uri url = Uri.parse((res['link'])['url']);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }

    }catch(e){
      log("exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
    }


    // try {
    //   var response = await Requests.get(
    //       "https://api.eu.onfido.com/v3.5/workflow_runs/1ac4508b-cb8f-4593-9d4d-52ab354dbbcd",
    //     headers: {
    //         'Authorization': 'Token token=$api_token'
    //     }
    //   );
    //   dynamic res = jsonDecode(response.body);
    //   log('response: ${res}');
    //
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text("${res.toString()}")));
    // }catch(e){
    //   log("exception: $e");
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text("exception: $e")));
    // }
  }

  checkKYCStatus() async {
    final Uri url = Uri.parse('https://www.google.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  refresh() async {
    final cookieJar = await Requests.getStoredCookies("$apiURL");
    final token = cookieJar.values
        .firstWhere((element) => element.name == 'token')
        .value;
    log('------------------------------------');
    log(token);
    log('------------------------------------');
    await IsLoggedIn.instance.saveSession(token);
  }

  @override
  void initState() {
    super.initState();
    //   https://api.eu.onfido.com/v3.6/applicants/
    // checkKYCStatus();
    final appStateObserver = AppStateObserver();
    WidgetsBinding.instance?.addObserver(appStateObserver);
    refresh();
    log('---> runned');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification Center'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/kyc_bear.png"),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Text("Complete your KYC verification effortlessly to unlock full access and benefits. Your security is our priority."),
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(HexColor("#ff897e")),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))))),
                onPressed: makeReq,
                child: const Text(style: TextStyle(fontWeight: FontWeight.bold), "START VERIFICATION"),
              ),
            )
          ],
        ),
      )
    );
  }
}
