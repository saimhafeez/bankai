import 'package:bankai/statics/is_getting_ready_done.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {

  // Future<void> _incrementCounter() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     prefs.setBool('isGettingStartedDone', true);
  //   });
  // }

  int current_screen = 0;

  markDone() {
    IsGettingReadyDone.instance.markGettingReadyDone();
  }

  screenOne(){
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Container(
            // color: HexColor("#ff897e"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo_transparent.png",
                  height: 100,
                  width: 100,
                ),
                const Text( style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 'Bankai'),
                const Text('Managing multiple cards made easy.'),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(HexColor("#314bce")),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
                    ),
                    onPressed: () {
                      setState(() {
                        current_screen++;
                      });
                    },
                    child: const Text('Get Started Now')
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  screenTwo() {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: markDone,
                  child: const Text("SKIP"),
                ),
              ),
              Image.asset(
                "assets/images/bear_1.png",
                height: 450,
                width: 450,
              ),
              const Text( style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 'Hey There! Welcome'),
              Container(padding: const EdgeInsets.all(20), child: const Text("Tired of juggling a bunch of cards? We get it. Let's make your financial life a breeze. Add all your cards in a snap and let the magic begin!")),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(75, 75)),
                        alignment: Alignment.center,
                        backgroundColor: MaterialStateProperty.all(HexColor("#314bce")),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(75)))
                    ),
                    onPressed: () {
                      setState(() {
                        current_screen++;
                      });
                    },
                    child: const Icon(IconData(0xe09c, fontFamily: 'MaterialIcons', matchTextDirection: true))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  screenThree() {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: markDone,
                  child: const Text("SKIP"),
                ),
              ),
              Image.asset(
                "assets/images/bear_2.png",
                height: 450,
                width: 450,
              ),
              Container(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: const Column(
                    children: [
                      Text( style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold), "Card Overload? We've Got Your Back", textAlign: TextAlign.center),
                      Text("Managing a bunch of cards is so last season. We've heard your struggles. Say no more to the card chaos. It's time for a change, and we're here to simplify your life.", textAlign: TextAlign.justify),
                    ]),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(75, 75)),
                        alignment: Alignment.center,
                        backgroundColor: MaterialStateProperty.all(HexColor("#314bce")),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(75)))
                    ),
                    onPressed: () {
                      setState(() {
                        current_screen++;
                      });
                    },
                    child: const Icon(IconData(0xe09c, fontFamily: 'MaterialIcons', matchTextDirection: true))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  screenFour() {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: markDone,
                  child: const Text("SKIP"),
                ),
              ),
              Image.asset(
                "assets/images/bear_3.png",
                height: 450,
                width: 450,
              ),
              Container(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: const Column(
                    children: [
                      Text( style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold), "Introducing Bankai", textAlign: TextAlign.center),
                      Text("Drumroll, please! Meet your new financial sidekick - the Bankai card. Say goodbye to multiple cards and hello to hassle-free transactions. Customize it your way, and let the simplicity of one card rule your financial world!", textAlign: TextAlign.justify),
                    ]),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(HexColor("#314bce")),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
                  ),
                  onPressed: markDone,
                  child: const Text('Get Started Now')
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return current_screen == 0 ? screenOne() : current_screen == 1 ? screenTwo()  : current_screen == 2 ? screenThree() : screenFour();
  }
}
