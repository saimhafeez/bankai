import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingObj {
  BuildContext context;
  BuildContext? dialogContext;
  String message;

  LoadingObj({required this.context, this.dialogContext, required this.message});

}

showLoading(LoadingObj obj) {
  showDialog(
      barrierDismissible: false,
      context: obj.context,
      builder: (context) {
        obj.dialogContext = context;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SpinKitFoldingCube(size: 30, color: Colors.amber),
                const SizedBox(height: 10),
                Text(obj.message, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        );
      });
}
