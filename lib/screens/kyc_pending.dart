import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';

class KYCPending extends StatefulWidget {
  const KYCPending({super.key});

  @override
  State<KYCPending> createState() => _KYCPendingState();
}

class _KYCPendingState extends State<KYCPending> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
              "assets/images/bear_1.png"
          ),
          const Text(style: TextStyle(fontWeight: FontWeight.bold), "Your KYC Request is Pending right now"),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(HexColor("#ff897e")),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                    const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(5))))),
            onPressed: () {
              context.push('/kyc');
            },
            child: const Text("Submit KYC Request Again"),
          )
        ],
      ),
    );
  }
}
