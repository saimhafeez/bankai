import "package:flutter/material.dart";

showSnackBar(context, text, actionLabel, action){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: actionLabel,
        onPressed: action,
      ),
    ),
  );
}
