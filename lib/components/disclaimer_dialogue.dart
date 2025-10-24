import 'package:flutter/material.dart';

Future<bool> showDisclaimerDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? confirmText,
  String? checkboxText,
  Color? activeColor,
  Color? textColor,
}) async {
  bool isAccepted = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title ?? "Disclaimer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message ??
                    "You are now leaving GeniusWallet for Banxa (https://banxa.com). "
                        "Services related to card payments are provided by Banxa, "
                        "a separate third-party platform. By proceeding, you acknowledge "
                        "that you have read and agreed to Banxa's Terms of Use and Privacy Policy.",
                style: TextStyle(color: textColor ?? Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isAccepted,
                    onChanged: (value) {
                      setState(() {
                        isAccepted = value ?? false;
                      });
                    },
                    activeColor: activeColor ?? Colors.green,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                  ),
                  Expanded(
                    child: Text(
                      checkboxText ?? "I have read and agree to the disclaimer",
                      style: TextStyle(color: textColor ?? Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(isAccepted),
              child: Text(confirmText ?? "Confirm"),
            ),
          ],
        ),
      );
    },
  );

  return isAccepted;
}
