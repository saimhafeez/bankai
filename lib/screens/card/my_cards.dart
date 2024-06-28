import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bankai/components/bank_card_detailed.dart';
import 'package:bankai/methods/helping.dart';
import 'package:bankai/methods/show_loading.dart';
import 'package:bankai/statics/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:requests/requests.dart';

import '../../statics/is_logged_in.dart';

class MyCards extends StatefulWidget {
  const MyCards({super.key});

  @override
  State<MyCards> createState() => _MyCardsState();
}

class _MyCardsState extends State<MyCards> {
  bool _allowReorder = false;
  bool _loading = false;
  List<dynamic> myCards = [];


  fetchCards() async {

    setState(() {
      _loading = true;
    });

    try{
      var response = await Requests.get("$apiURL/card", timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: $res');
      if (res['msg'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg'])));
      } else {
        List cards = res['cards'];
        cards.sort((a, b) => a['priorityNumber'].compareTo(b['priorityNumber']));
        setState(() {
          myCards = cards;
        });
      }

      setState(() {
        _loading = false;
      });

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() {
        _loading = false;
      });
    }

  }


  updateCardPriority() async {

    LoadingObj loadingObj = LoadingObj(
        context: context,
        message: "Verifying..."
    );
    showLoading(loadingObj);

    try{
      var index = 1;
      dynamic myCardsUpdated = myCards.map((e) {
        final newCard = {"cardID": e['cardID'], "priorityNumber": index};
        index++;
        return newCard;
      }).toList();

      var reqBody = {"cards": myCardsUpdated};

      var response =
      await Requests.post("$apiURL/card/changePriority", json: reqBody, timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: ${res}');

      if (res['msg'] != null && res['msg'] != "Priority Updated") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("res['msg']")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Priority Updated")));
        // fetchCards();
      }

      setState(() {
        _allowReorder = false;
      });

      Navigator.pop(loadingObj.dialogContext!);

    }catch(e){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));

      Navigator.pop(loadingObj.dialogContext!);
    }

  }

  confirmCardRemoval(cardID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you Sure?"),
        content: const Text("This action is irreversible"),
        actions: [
          SimpleDialogOption(
            child: const Text("No"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SimpleDialogOption(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              removeCard(cardID);
            },
          ),
        ],
      ),
    );
  }

  removeCard(cardID) async {

    LoadingObj loadingObj = LoadingObj(
        context: context,
        message: "Deleting Card..."
    );

    try{

      showLoading(loadingObj);

      log("--> $cardID");

      var response = await Requests.delete("$apiURL/card/${cardID}", timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: ${res}');

      if(response.success){
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Card Deleted")));
        fetchCards();
      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("res['msg']")));
      }
      setState(() {
        _allowReorder = false;
      });
      Navigator.pop(loadingObj.dialogContext!);

    }catch(e){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("exception: $e")));
        Navigator.pop(loadingObj.dialogContext!);
    }

  }

  freezeCard(cardID, unfreeze) async {

    log('--> $cardID');

    LoadingObj loadingObj = LoadingObj(
        context: context,
        message: unfreeze ? "Unfreezing Card..." : "Freezing Card..."
    );

    try{
      showLoading(loadingObj);
      var response = await Requests.get("$apiURL/card/${unfreeze ? "unfreeze_card" : "freeze_card"}/${cardID}", timeoutSeconds: CONNECTION_TIMEOUT_SECONDS);
      dynamic res = jsonDecode(response.body);
      log('response: ${res}');

      if (response.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['msg'])));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(unfreeze ? "Card Unfreezed" : "Card Freezed")));
        fetchCards();
      }

      setState(() {
        _allowReorder = false;
      });
      Navigator.pop(loadingObj.dialogContext!);

    }catch(e){
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("exception: $e")));
      Navigator.pop(loadingObj.dialogContext!);
    }

  }

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cards"),
        iconTheme: const IconThemeData(size: 20),
        leading: IconButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.resolveWith((states) => Colors.white),
          ),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)))),
                backgroundColor: MaterialStateProperty.resolveWith((states) =>
                    _allowReorder ? Colors.amberAccent : Colors.white),
              ),
              icon: const ImageIcon(
                AssetImage("assets/images/card_gear.png"),
                color: Colors.black87,
                size: 27,
              ),
              onPressed: () => setState(() {
                _allowReorder = !_allowReorder;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)))),
              ),
              icon: const Icon(
                Icons.add_card,
                color: Colors.black87,
                size: 27,
              ),
              onPressed: () {
                if(IsLoggedIn.instance.lastUpdate?.data['kycStatus'] == 'verified'){
                  context.push('/add-card');
                }else{
                  context.push('/kyc');
                }
              }
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading ?
        const Center(
          child: SpinKitFoldingCube(size: 30, color: Colors.amber),
        )
        : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          primary: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 5, left: 5),
                width: double.maxFinite,
                height: _allowReorder ? 50 : 0,
                color: Colors.amberAccent,
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        "Drag Card to Change Card Priority"),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.black87),
                            foregroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.white)),
                        onPressed: updateCardPriority,
                        child: const Text("Save")),
                  ],
                ),
              ),

              if(!_loading && myCards.isEmpty)
                Text(style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), "Add Some Cards! 💳"),

              ReorderableListView(
                physics: ClampingScrollPhysics(),
                buildDefaultDragHandles: _allowReorder,
                shrinkWrap: true,
                padding: const EdgeInsets.all(5),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    dynamic items = myCards.removeAt(oldIndex);
                    items['priorityNumber'] = newIndex;
                    myCards.insert(newIndex, items);
                  });
                },
                children: [
                  for (final card in myCards)
                    Stack(
                      key: Key(card['cardID']),
                      children: [
                        BankCardDetailed(
                            cardNumber:
                            formatCardNumber(card['cardNumber'].toString()),
                            bankName: card['bankName'],
                            cardHolderName: card['cardHolderName'],
                            cardType: card['cardType'],
                            cvvCode: card['cvv'].toString(),
                            expiryDate: formatDate(card['expiryDate']),
                            issueDate: formatDate(card['issueDate'])),
                        if (_allowReorder)
                          Container(
                            margin: const EdgeInsets.all(2),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                  onTap: () =>
                                      confirmCardRemoval(card['cardID']),
                                  child: const Icon(Icons.cancel,
                                      size: 25, color: Colors.amber)),
                            ),
                          ),
                        if(card['isCardFreeze'] || _allowReorder)
                          Container(
                            margin: const EdgeInsets.only(top: 50, right: 15),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: EdgeInsets.only(right: 5, left: 5),
                                decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(_allowReorder ? "Freeze" : "Freezed"),
                              ),
                            ),
                          ),
                        if(_allowReorder)
                          Container(
                            margin: const EdgeInsets.only(top: 80, right: 15),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Switch(
                                value: card['isCardFreeze'],
                                activeColor: Colors.amber,
                                onChanged: (bool value) {
                                  freezeCard(card['cardID'], !value);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
