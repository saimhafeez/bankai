import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/plugins/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:requests/requests.dart';

import '../../methods/show_loading.dart';
import '../../statics/api.dart';

class NewPassword extends StatefulWidget {
  final String? token;
  final String? email;

  const NewPassword({super.key, required this.token, required this.email});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  TextEditingController password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();

  // -----------------------------
  bool passwordFieldVisible = false;
  bool confirmPasswordFieldVisible = false;
  // -----------------------------
  bool isLoading = false;

  passwordValidator(value) {
    if (value!.length < 8) {
      return 'Password Should be 8 Characters Long';
    } else if (!RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(value)) {
      return 'Need One Capital\nOne Special characters\nOne number';
    }
    return null;
  }

  confirmPasswordValidator(value) {
    return value == password.text ? null : 'Password Should Match';
  }

  passwordReset() async {

    try {
      var reqBody = {
        "email": widget.email,
        "token": widget.token,
        "password": password.text
      };

      var response = await Requests.post("$apiURL/auth/reset_password", json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: $res');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['msg'].toString().toTitleCase())));
      setState(() {
        isLoading = false;
      });
      if(response.success){
        context.go("/");
      }

    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log("exception in Reset Password: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
      context.go("/");
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password", style: TextStyle(fontWeight: FontWeight.bold)),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset("assets/images/bear_1.png"),
            TextFormField(
              decoration: InputDecoration(
                  fillColor: HexColor("#f5f6fa"),
                  filled: true,
                  enabled: false,
                  hintText: widget.email,
                  border: InputBorder.none,
                  suffixIcon: const Icon(
                    Icons.email
                  )),
            ),
            TextFormField(
              obscureText: !passwordFieldVisible,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => passwordValidator(value),
              controller: password,
              decoration: InputDecoration(
                  fillColor: HexColor("#f5f6fa"),
                  filled: true,
                  border: InputBorder.none,
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordFieldVisible = !passwordFieldVisible;
                      });
                    },
                    icon: Icon(
                        color: Colors.grey,
                        passwordFieldVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded),
                  )),
            ),
            const SizedBox(height: 5),
            TextFormField(
              obscureText: !confirmPasswordFieldVisible,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => confirmPasswordValidator(value),
              controller: confirm_password,
              decoration: InputDecoration(
                  fillColor: HexColor("#f5f6fa"),
                  filled: true,
                  border: InputBorder.none,
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        confirmPasswordFieldVisible =
                            !confirmPasswordFieldVisible;
                      });
                    },
                    icon: Icon(
                        color: Colors.grey,
                        confirmPasswordFieldVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded),
                  )),
            ),
            isLoading
                ? Container(
              padding: const EdgeInsets.all(10),
              child: SpinKitFoldingCube(
                  size: 30, color: HexColor("#314BCE")),
            )
                : SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(HexColor("#ff897e")),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))))),
                  onPressed: passwordReset,
                  child: const Text("Confirm Reset"),
                ))
          ],
        ),
      ),
    );
  }
}
