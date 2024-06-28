
import 'package:bankai/app_colors.dart';
import 'package:flutter/material.dart';
import '../credit_card/src/credit_card_widget.dart';
import '../credit_card/src/models/credit_card_brand.dart';
import '../credit_card/src/models/custom_card_type_icon.dart';
import '../credit_card/src/models/glassmorphism_config.dart';
import '../credit_card/src/utils/enumerations.dart';

class BankCardDetailed extends StatelessWidget {

  final String cardNumber, expiryDate, issueDate, cardHolderName, cvvCode, bankName, cardType;
  BankCardDetailed({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    required this.issueDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.bankName,
    required this.cardType
  });

  bool isLightTheme = true;
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = true;
  bool useFloatingAnimation = false;

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

  @override
  Widget build(BuildContext context) {
    return CreditCardWidget(
      padding: 2,
      enableFloatingCard: useFloatingAnimation,
      glassmorphismConfig: _getGlassmorphismConfig(),
      cardTypeText: cardType,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      issueDate: issueDate,
      cardHolderName: cardHolderName,
      cvvCode: cvvCode,
      bankName: bankName,
      frontCardBorder: useGlassMorphism
          ? null
          : Border.all(color: Colors.grey),
      backCardBorder: useGlassMorphism
          ? null
          : Border.all(color: Colors.grey),
      showBackView: isCvvFocused,
      obscureCardNumber: false,
      obscureCardCvv: false,
      isHolderNameVisible: true,
      cardBgColor: isLightTheme
          ? AppColors.cardBgLightColor
          : AppColors.cardBgColor,
      backgroundImage:
      useBackgroundImage ? bankName.toLowerCase() == 'bankai' ? 'assets/card/bankai_bg.png' : 'assets/card/card_bg.png' : null,
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
        CustomCardTypeIcon(
          cardType: CardType.bankai,
          cardImage: Image.asset(
            'assets/card/bankai.png',
            height: 48,
            width: 48,
          )
        )
      ],
    );
  }
}
