import 'dart:convert';
import 'dart:developer';

import 'package:bankai/statics/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:requests/requests.dart';
import '../../app_colors.dart';
import '../../credit_card/src/credit_card_form.dart';
import '../../credit_card/src/credit_card_widget.dart';
import '../../credit_card/src/models/credit_card_brand.dart';
import '../../credit_card/src/models/credit_card_model.dart';
import '../../credit_card/src/models/custom_card_type_icon.dart';
import '../../credit_card/src/models/glassmorphism_config.dart';
import '../../credit_card/src/models/input_configuration.dart';
import '../../credit_card/src/utils/enumerations.dart';

class AddCard extends StatefulWidget {
  const AddCard({super.key});

  @override
  State<StatefulWidget> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {

  bool _isLoading = false;

  bool isLightTheme = true;
  String cardNumber = '';
  String expiryDate = '';
  String issueDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String bankName = '';
  String cardHolderCnic = '';
  String cardType = 'debit';
  bool isCvvFocused = false;
  bool useGlassMorphism = true;
  bool useBackgroundImage = true;
  bool useFloatingAnimation = false;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      title: 'Bankai',
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        textTheme: const TextTheme(
          // Text style for text fields' input.
          titleMedium: TextStyle(color: Colors.black, fontSize: 18),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.white,
          background: Colors.black,
          // Defines colors like cursor color of the text fields.
          primary: Colors.black,
        ),
        // Decoration theme for the text fields.
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      darkTheme: ThemeData(
        textTheme: const TextTheme(
          // Text style for text fields' input.
          titleMedium: TextStyle(color: Colors.white, fontSize: 18),
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.black,
          background: Colors.white,
          // Defines colors like cursor color of the text fields.
          primary: Colors.white,
        ),
        // Decoration theme for the text fields.
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.white),
          labelStyle: const TextStyle(color: Colors.white),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(
                    isLightTheme ? 'assets/card/bg-light.png' : 'assets/card/bg-dark.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // IconButton(
                    //   onPressed: () => setState(() {
                    //     isLightTheme = !isLightTheme;
                    //   }),
                    //   icon: Icon(
                    //     isLightTheme ? Icons.light_mode : Icons.dark_mode,
                    //   ),
                    // ),
                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      glassmorphismConfig: _getGlassmorphismConfig(),
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      issueDate: issueDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: bankName,
                      cardTypeText: cardType,
                      frontCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      backCardBorder: useGlassMorphism
                          ? null
                          : Border.all(color: Colors.grey),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      cardBgColor: isLightTheme
                          ? AppColors.cardBgLightColor
                          : AppColors.cardBgColor,
                      backgroundImage:
                      useBackgroundImage ? 'assets/card/card_bg.png' : null,
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[
                        CustomCardTypeIcon(
                          cardType: CardType.mastercard,
                          cardImage: Image.asset(
                            'assets/card/mastercard.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              cardHolderCnic: cardHolderCnic,
                              cardType: cardType,
                              bankName: bankName,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              issueDate: issueDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                ),
                                expiryDateDecoration: InputDecoration(
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  labelText: 'Card Holder',
                                ),
                                bankNameDecoration: InputDecoration(
                                  labelText: 'Bank Name',
                                ),
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            // const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _isLoading ? (){} : _onValidate,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _isLoading ? Colors.grey : HexColor("#ff897e"),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'ADD CARD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'halter',
                                        fontSize: 14,
                                        package: 'flutter_credit_card',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _isLoading ? const SpinKitFoldingCube(size: 20, color: Colors.white) : Container()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onValidate() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try{
        log('-----------------------------------------');

        // 2024-03-18

        dynamic reqBody = {
          "cardHolderName": cardHolderName.toLowerCase(),
          "cardNumber": cardNumber.split(' ').join(),
          "cvv": cvvCode,
          "issueDate": "20${issueDate.split("/")[1]}-${issueDate.split("/")[0]}-01",
          "expiryDate": "20${expiryDate.split("/")[1]}-${expiryDate.split("/")[0]}-01",
          "bankName": bankName,
          "cardHolderCnic": cardHolderCnic,
          "cardType": cardType.toLowerCase()
        };

        log('Card Data: $reqBody');
        log('-----------------------------------------');
        // return;
        var response = await Requests.post("$apiURL/card", json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);

        dynamic res = jsonDecode(response.body);

        log('response: ${res}');

        if(response.success){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Card Authorized and Added")));
          Navigator.pop(context);
          Navigator.pop(context);
        }else{
          setState(() {
            _isLoading = false;
          });
          SnackBar snackBar = SnackBar(
            content: Text(res['msg']),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

      }catch(e){
        log('exception $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("exception ${e.toString()}")));
        setState(() {
          _isLoading = false;
        });
      }

    } else {
      print('invalid!');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Inputs")));
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    log(creditCardModel.bankName);
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      issueDate = creditCardModel.issueDate;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      bankName = creditCardModel.bankName;
      cardHolderCnic = creditCardModel.cardHolderCnic;
      cardType = creditCardModel.cardType;
    });
  }
}