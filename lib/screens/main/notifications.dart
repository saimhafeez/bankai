import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/plugins/string_extension.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:requests/requests.dart';

import '../../statics/api.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _loading = false;
  List<dynamic> myNotifications = [];

  fetchNotifications() async {
    setState(() {
      _loading = true;
    });
    try {
      dynamic data = await IsLoggedIn.instance.getCurrentUser();
      setState(() {
        myNotifications = (data['user'])['notifications'];
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
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _loading
              ? Container(
                  padding: const EdgeInsets.all(10),
                  child:
                      SpinKitFoldingCube(size: 30, color: HexColor("#314BCE")),
                )
              : Column(
                  children: [
                    for (final notification in myNotifications.reversed)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(
                                      0.2), // Adjust for desired opacity
                                  spreadRadius: 2, // Adjust for desired spread
                                  blurRadius: 4, // Adjust for desired blur
                                  offset: const Offset(
                                      0, 2), // Adjust for desired offset (x, y)
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notification['message']),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                                        color: HexColor("ffbf08"),
                                      ),
                                      child: Text("${notification['date']} - ${notification['time']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          )
                        ],
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
