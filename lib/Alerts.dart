import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Alerts {
// Alerts

  static Future<String?> displayTextInputDialog(BuildContext context,
      {title = "", label: "", message = "", password = false, initialValue = ""}) async {
    String? theValue = initialValue;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Container(
            width: 300,
            height: 300,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: message,
                      labelText: label,
                    ),
                    obscureText: password,
                    enableSuggestions: !password,
                    autocorrect: !password,
                    onChanged: (value) {
                      theValue = value;
                    },

                  ),
                  Spacer(),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      CupertinoButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context, theValue);
                          }),
                      Spacer(),
                      CupertinoButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context, null);
                          }),
                      Spacer(),
                    ],
                  ),
                ]),
            ),
          );
        });
  }

  static Future<bool?> yesNoAlert(
      BuildContext context, String title, String message) async {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(
              message,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                /// This parameter indicates this action is the default,
                /// and turns the action's text to bold text.
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('No'),
              ),

              CupertinoDialogAction(
                /// This parameter indicates this action is the default,
                /// and turns the action's text to bold text.
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Si'),
              ),


            ],
          );
        });
  }

  static displayAlert(BuildContext context, String title, String message) async {
    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(
              message,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                /// This parameter indicates this action is the default,
                /// and turns the action's text to bold text.
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );

        });
  }
}
