import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';

class KYCApplied extends StatefulWidget {
  const KYCApplied({super.key});

  @override
  State<KYCApplied> createState() => _KYCAppliedState();
}

class _KYCAppliedState extends State<KYCApplied> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Your KYC Request is being Processed"),
          Image.asset(
            "assets/images/bear_1.png"
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(HexColor("#ff897e")),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(5))))),
            onPressed: () {
              context.push('/');
            },
            child: Text("Go Back Home"),
          )
        ],
      ),
    );
  }
}
