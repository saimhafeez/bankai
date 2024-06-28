import 'dart:convert';
import 'dart:developer';

import 'package:bankai/components/plugins/string_extension.dart';
import 'package:bankai/methods/show_loading.dart';
import 'package:bankai/statics/api.dart';
import 'package:bankai/statics/is_logged_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:requests/requests.dart';
import 'package:sweet_cookie_jar/sweet_cookie_jar.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool changeToLoginForm = true;

  // Text Field Controllers
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();
  TextEditingController cnic = TextEditingController();
  TextEditingController phone = TextEditingController();

  // -----------------------------
  bool passwordFieldVisible = false;
  bool confirmPasswordFieldVisible = false;
  // -----------------------------
  bool hidePasswordTextField = false;


  registerUser() async {

    if (nameValidator(firstName.text) != null ||
        nameValidator(lastName.text) != null ||
        emailValidator(email.text) != null ||
        passwordValidator(password.text) != null ||
        password.text != confirm_password.text ||
        cnicValidator(cnic.text) != null ||
        phoneValidator(phone.text) != null) {
      log('-----------------------------------------');
      log('${nameValidator(firstName.text) != null} || ${nameValidator(lastName.text) != null} || ${emailValidator(email.text) != null} || ${passwordValidator(password.text) != null} || ${password.text != confirm_password.text} || ${cnicValidator(cnic.text) != null} || ${phoneValidator(phone.text) != null}');
      log('${nameValidator(firstName.text)} || ${nameValidator(lastName.text)} || ${emailValidator(email.text)} || ${passwordValidator(password.text)} || ${password.text != confirm_password.text} || ${cnicValidator(cnic.text)} || ${phoneValidator(phone.text)}');
      log('-----------------------------------------');
      return;
    }

    LoadingObj loadingObj = LoadingObj(
        context: context,
        message: "Verifying..."
    );
    showLoading(loadingObj);

    try{

      var reqBody = {
        "firstName": firstName.text.toLowerCase(),
        "lastName": lastName.text.toLowerCase(),
        "email": email.text.toLowerCase(),
        "password": password.text,
        "cnic": cnic.text,
        "phoneNumber": phone.text
      };

      var response = await http.post(Uri.parse('$apiURL/auth/register'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      dynamic res = jsonDecode(response.body);
      log('response: $res');

      if(response.success){
        setState(() {
          changeToLoginForm = true;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Registered, You can now Login")));
      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${res['msg']}")));
      }
      Navigator.pop(loadingObj.dialogContext!);

    }catch(e){
      log("exception: $e");
      Navigator.pop(loadingObj.dialogContext!);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
    }


  }

  loginUser() async {
    if (emailValidator(email.text) != null) {
      return;
    }

    LoadingObj loadingObj = LoadingObj(
        context: context,
        message: "Verifying..."
    );
    showLoading(loadingObj);

    try {
      var reqBody = {
        "email": email.text.toLowerCase(),
        "password": password.text,
      };

      var response = await Requests.post("$apiURL/auth/login", json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: $res');

      if(response.success){

        final cookieJar = await Requests.getStoredCookies(apiURL);
        final token = cookieJar.values
            .firstWhere((element) => element.name == 'token')
            .value;
        log('------------------------------------');
        log(token);
        log('------------------------------------');

        await IsLoggedIn.instance.saveSession(token);

      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['msg'].toString().toTitleCase())));

      Navigator.pop(loadingObj.dialogContext!);

    } catch (e) {

      log("exception in Register: $e");
      Navigator.pop(loadingObj.dialogContext!);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));

    }
  }

  resetPassword() async {
    if (emailValidator(email.text) != null) {
      return;
    }

    LoadingObj loadingObj = LoadingObj(
        context: context,
        message: "Sending Link..."
    );
    showLoading(loadingObj);

    try {
      var reqBody = {
        "email": email.text.toLowerCase(),
      };

      var response = await Requests.post("$apiURL/auth/forgot_password", json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: $res');

      if(response.success){
        setState(() {
          hidePasswordTextField = false;
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['msg'].toString().toTitleCase())));

      Navigator.pop(loadingObj.dialogContext!);

    } catch (e) {

      log("exception in Forgot Password: $e");
      Navigator.pop(loadingObj.dialogContext!);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));

    }
  }

  nameValidator(value) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(value) ? null : 'Enter Valid Name';
  }

  emailValidator(value) {
    return RegExp(
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(value!)
        ? null
        : 'Enter a Valid Email';
  }

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

  cnicValidator(value) {
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Enter Valid Cnic';
    } else if (value.length != 13) {
      return 'Cnic should be 13 Digits Long';
    }
    return null;
  }

  phoneValidator(value) {
    if (!RegExp(r'^\d{1,3}\s?\d{3,}$').hasMatch(value) || value.length != 11) {
      return 'Enter Valid Phone';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                  hidePasswordTextField ? "Password Reset" : changeToLoginForm ? "Login" : "Register"),
              Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !changeToLoginForm
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          Expanded(
                              child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) => nameValidator(value),
                            controller: firstName,
                            decoration: InputDecoration(
                              fillColor: HexColor("#f5f6fa"),
                              filled: true,
                              border: InputBorder.none,
                              hintText: 'First Name',
                            ),
                          )),
                          const SizedBox(width: 5),
                          Expanded(
                              child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) => nameValidator(value),
                            controller: lastName,
                            decoration: InputDecoration(
                              fillColor: HexColor("#f5f6fa"),
                              filled: true,
                              border: InputBorder.none,
                              hintText: 'Last Name',
                            ),
                          ))
                        ])
                      : SizedBox(),
                  const SizedBox(height: 5),
                  TextFormField(
                    autovalidateMode: changeToLoginForm
                        ? AutovalidateMode.disabled
                        : AutovalidateMode.onUserInteraction,
                    validator: (value) => emailValidator(value),
                    controller: email,
                    decoration: InputDecoration(
                      fillColor: HexColor("#f5f6fa"),
                      filled: true,
                      border: InputBorder.none,
                      hintText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 5),
                  !hidePasswordTextField ? TextFormField(
                    obscureText: !passwordFieldVisible,
                    autovalidateMode: changeToLoginForm
                        ? AutovalidateMode.disabled
                        : AutovalidateMode.onUserInteraction,
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
                  )
                  : SizedBox(),
                  // Column(
                  //   children: [
                  //     Row(children: [
                  //       Icon(color: !isValidEmail ? Colors.redAccent : Colors.green, size: 10,const IconData(0xe163, fontFamily: 'MaterialIcons', matchTextDirection: true)),
                  //       const SizedBox(
                  //         width: 5,
                  //       ),
                  //       Text(style: TextStyle(color: isValidEmail ? Colors.redAccent : Colors.green,fontWeight: FontWeight.bold, fontSize: 9), "Minimum 8 characters long")]),
                  //     Row(children: [
                  //       Icon(color: isValidEmail ? Colors.redAccent : Colors.green, size: 10,const IconData(0xe163, fontFamily: 'MaterialIcons', matchTextDirection: true)),
                  //       const SizedBox(
                  //         width: 5,
                  //       ),
                  //       Text(style: TextStyle(color: isValidEmail ? Colors.redAccent : Colors.green,fontWeight: FontWeight.bold, fontSize: 9), "Should include atleast one Capital letter")]),
                  //     Row(children: [
                  //       Icon(color: isValidEmail ? Colors.redAccent : Colors.green, size: 10,const IconData(0xe163, fontFamily: 'MaterialIcons', matchTextDirection: true)),
                  //       const SizedBox(
                  //         width: 5,
                  //       ),
                  //       Text(style: TextStyle(color: isValidEmail ? Colors.redAccent : Colors.green,fontWeight: FontWeight.bold, fontSize: 9), "Should include special characters")]),
                  //     Row(children: [
                  //       Icon(color: isValidEmail ? Colors.redAccent : Colors.green, size: 10,const IconData(0xe163, fontFamily: 'MaterialIcons', matchTextDirection: true)),
                  //       const SizedBox(
                  //         width: 5,
                  //       ),
                  //       Text(style: TextStyle(color: isValidEmail ? Colors.redAccent : Colors.green,fontWeight: FontWeight.bold, fontSize: 9), "Should include digits")]),
                  //   ],
                  // ),
                  !changeToLoginForm
                      ? Column(children: [
                          const SizedBox(height: 5),
                          TextFormField(
                            obscureText: !confirmPasswordFieldVisible,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                confirmPasswordValidator(value),
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
                          const SizedBox(height: 5),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) => cnicValidator(value),
                            controller: cnic,
                            decoration: InputDecoration(
                              fillColor: HexColor("#f5f6fa"),
                              filled: true,
                              border: InputBorder.none,
                              hintText: 'CNIC',
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) => phoneValidator(value),
                            controller: phone,
                            decoration: InputDecoration(
                              fillColor: HexColor("#f5f6fa"),
                              filled: true,
                              border: InputBorder.none,
                              hintText: 'Phone',
                            ),
                          ),
                        ])
                      : SizedBox(),
                  const SizedBox(height: 5),
                  SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(HexColor("#ff897e")),
                            foregroundColor: WidgetStateProperty.all(Colors.white),
                            shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))))),
                        onPressed: hidePasswordTextField ? resetPassword : changeToLoginForm
                                ? loginUser
                                : registerUser,
                        child: Text(hidePasswordTextField ? "Send Reset Link" : changeToLoginForm ? "Login" : "Register"),
                      ))
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              changeToLoginForm ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      hidePasswordTextField = !hidePasswordTextField;
                    });
                  },
                  style: ButtonStyle(
                    alignment: Alignment.centerRight,
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    backgroundColor:
                    WidgetStateProperty.all(Colors.transparent),
                    elevation: WidgetStateProperty.all(0),
                  ),
                  child: Row(
                    children: [
                      Text(hidePasswordTextField ? "Login" :"Forgot Password?"),
                      const SizedBox(width: 5),
                      Icon(
                          size: 16,
                          hidePasswordTextField ? Icons.login : Icons.password_rounded)
                    ],
                  )) : const SizedBox(),
            ],
          ),
          !hidePasswordTextField ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Already have an account?"),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      changeToLoginForm = !changeToLoginForm;
                    });
                  },
                  style: ButtonStyle(
                    alignment: Alignment.centerLeft,
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    elevation: WidgetStateProperty.all(0),
                  ),
                  child: Row(
                    children: [
                      Text(!changeToLoginForm ? "Login" : "Register"),
                      const Icon(
                          size: 16,
                          IconData(0xf57a,
                              fontFamily: 'MaterialIcons',
                              matchTextDirection: true))
                    ],
                  ))
            ],
          ) : SizedBox()
        ],
      ),
    );
  }
}
