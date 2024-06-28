import 'dart:convert';
import 'dart:developer';

import 'package:bankai/statics/api.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_mixin/stream_mixin.dart';
import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';


class Session {
  String token;
  dynamic data;
  Session(this.token, this.data);
}

class IsLoggedIn with StreamMixin<Session> {

  IsLoggedIn._();
  static IsLoggedIn instance = IsLoggedIn._();

  Future<void> saveSession(String token) async {
    dynamic data = await getCurrentUser();
    Session session = Session(token, data['user']);
    update(session);
    log("----------------------------------");
    log('clicked => update(s)');
    log("----------------------------------");


    // String? id = await OneSignal.User.getOnesignalId();
    //
    // log('-----------------ID START-------------------');
    // log(id ?? "no id found ${id.toString()}");
    // log('------------------ID END------------------');
    //
    // var response = await Requests.post("$apiURL/user/update-devices", json: {
    //   "devices": [id.toString()]
    // }, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
    // dynamic res = jsonDecode(response.body);
    // log('response: $res');

  }

  // Future<void> checkSession() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('sessionToken');
  //   if(token != null && token != ""){
  //     Session session = Session(token);
  //     update(session);
  //   }
  // }

  Future<dynamic> getCurrentUser() async {
    var r2 = await Requests.get("$apiURL/user/bankai/current-user", timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
    // r2.raiseForStatus();
    // print(r2.json()['id'])
    // var jsonResponse = jsonDecode(response.body);
    final cookieJar = await Requests.getStoredCookies(apiURL);
    // final token = cookieJar.values.firstWhere((element) => element.name == 'token').value;
    final token = cookieJar.values;
    log('------------------------------------');
    // log('token -->> : ${token}');
    // log('getCurrentUser: ${r2.body}');
    log('------------------------------------');
    return jsonDecode(r2.body);
  }

  Future<dynamic> validateCurrentUser() async {

    getCurrentUser();

  }

}