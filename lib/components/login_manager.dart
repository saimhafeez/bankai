import 'dart:developer';

import 'package:bankai/screens/kyc_pending.dart';
import 'package:bankai/screens/main/dashboard.dart';
import 'package:bankai/screens/onfido_kyc_verification.dart';
import 'package:bankai/screens/register.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:flutter/material.dart';

class LoginManager extends StatefulWidget {
  const LoginManager({super.key});

  @override
  State<LoginManager> createState() => _LoginManagerState();
}

class _LoginManagerState extends State<LoginManager> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Session>(
      initialData: IsLoggedIn.instance.lastUpdate ?? Session("", ""),
      stream: IsLoggedIn.instance.onChange,
      builder: (context, snapshot) {
        String? kycStatus = "";
        if(snapshot.data?.data != ""){
          kycStatus = snapshot.data?.data['kycStatus'];
        }
        // log('--saim--> ${snapshot.data?.data['kycStatus']}');
        String? p = snapshot.data?.token;
        log('---------------------');
        log('=> login : $p');
        log('---------------------');
        return p == "" ? const Register() : kycStatus == 'pending' ? const KYCPending() : const Dashboard();
      }
    );
  }
}