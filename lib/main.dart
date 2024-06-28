import 'dart:developer';

import 'package:bankai/components/login_manager.dart';
import 'package:bankai/screens/card/add_card.dart';
import 'package:bankai/screens/card/my_cards.dart';
import 'package:bankai/screens/deeplinks/new_password.dart';
import 'package:bankai/screens/kyc_applied.dart';
import 'package:bankai/screens/main/notifications.dart';
import 'package:bankai/screens/main/transactions.dart';
import 'package:bankai/screens/onboarding/get_started.dart';
import 'package:bankai/screens/onfido_kyc_verification.dart';
import 'package:bankai/statics/is_getting_ready_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // bool isGettingStartedDone = false;

  @override
  void initState() {
    super.initState();
    _checkIsGettingStartedDone();
    IsGettingReadyDone.instance.checkIsGettingStartedDone();
    // IsLoggedIn.instance.checkSession();
    initPlatform();
  }

  Future<void> _checkIsGettingStartedDone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bool isGettingStartedDone = prefs.getBool('isGettingStartedDone') ??
          false;
      log('--------------------');
      log('saim');
      log('isGettingStartedDone: $isGettingStartedDone');
      log('--------------------');
    });
  }

  Future<void> initPlatform() async {
    //Remove this method to stop OneSignal Debugging
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("9a06421b-5b60-4932-ae48-e548c3c2a30d");
    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);

    String? id = await OneSignal.User.getOnesignalId();
    await OneSignal.User.addAlias("bankai_id", id);
    
    
    log('-----------------ID START-------------------');
    log(id ?? "no id found ${id.toString()}");
    log('------------------ID END------------------');

  }

  // 50c0dbdd-b2d1-4a5e-8bf0-f4d6aa9510a6


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bankai',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }

  // Declare routing information
  final _router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: SafeArea(
              // child: isGettingStartedDone ? Dashboard() : GetStarted()
              child: StreamBuilder<bool>(
                initialData: IsGettingReadyDone.instance.lastUpdate ?? false,
                stream: IsGettingReadyDone.instance.onChange,
                builder: (context, snapshot) {
                  String p = snapshot.data.toString().toLowerCase();
                  log('---------------------');
                  log('=> $p');
                  log('---------------------');
                  return snapshot.data.toString().toLowerCase() == 'true'
                      ? const LoginManager()
                      : const GetStarted();
                },

              ),
            ),
          )
      ),
      GoRoute(
          path: '/my-cards',
          builder: (context, state) =>
          const MyCards()
      ),
      GoRoute(
        path: '/add-card',
        builder: (context, state) =>
        const Scaffold(body: SafeArea(child: AddCard())),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) =>
        const Scaffold(body: SafeArea(child: OnFidoKYCVerification())),
      ),
      GoRoute(
        path: '/kyc-applied',
        builder: (context, state) =>
        const Scaffold(body: SafeArea(child: KYCApplied())),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) =>
        Scaffold(body: SafeArea(child: NewPassword(
          token: state.uri.queryParameters['token'],
          email: state.uri.queryParameters['email'],
        ))),
      ),
      GoRoute(
          path: '/transactions',
          builder: (context, state) =>
          const Transactions()
      ),
      GoRoute(
          path: '/notifications',
          builder: (context, state) =>
          const Notifications()
      ),
    ],
  );
}

// }@override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bankai',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => Scaffold(
//           // appBar: AppBar(),
//           body: SafeArea(
//             // child: isGettingStartedDone ? Dashboard() : GetStarted()
//             child: StreamBuilder<bool>(
//               initialData: false,
//               stream: IsGettingReadyDone.instance.onChange,
//               builder: (context, snapshot) {
//                 String p = snapshot.data.toString().toLowerCase();
//                 log('---------------------');
//                 log('=> $p');
//                 log('---------------------');
//                 return snapshot.data.toString().toLowerCase() == 'false' ? LoginManager() : GetStarted();
//               },
//
//             ),
//           ),
//         ),
//         '/my-cards': (context) => const Scaffold(
//           body: SafeArea(
//             child: MyCards(),
//           ),
//         ),
//         '/add-card': (context) => const Scaffold(
//           body: SafeArea(
//             child: AddCard(),
//           ),
//         )
//       },
//     );
//   }
// }
