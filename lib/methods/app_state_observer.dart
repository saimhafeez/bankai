import 'dart:developer';

import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:flutter/widgets.dart';
import 'package:requests/requests.dart';

class AppStateObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // App returned from background, execute your function here
      // For example:
      final cookieJar = await Requests.getStoredCookies("$apiURL");
      final token = cookieJar.values
          .firstWhere((element) => element.name == 'token')
          .value;
      log('------------------------------------');
      log(token);
      log('------------------------------------');
      await IsLoggedIn.instance.saveSession(token);
    }
  }
}
