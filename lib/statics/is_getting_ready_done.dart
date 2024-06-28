import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_mixin/stream_mixin.dart';

class IsGettingReadyDone with StreamMixin<bool> {
  IsGettingReadyDone._();
  static IsGettingReadyDone instance = IsGettingReadyDone._();

  Future<void> markGettingReadyDone() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGettingStartedDone', true);
    update(true);
    log("----------------------------------");
    log('clicked => update(true');
    log("----------------------------------");
  }

  Future<void> checkIsGettingStartedDone() async {
    final prefs = await SharedPreferences.getInstance();
    bool isReady = prefs.getBool('isGettingStartedDone') ?? false;
    update(isReady);
    log("----------------------------------");
    log('isReady: $isReady');
    log("----------------------------------");
  }

}