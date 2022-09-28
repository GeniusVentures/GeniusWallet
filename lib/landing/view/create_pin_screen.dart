import 'package:flutter/material.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:go_router/go_router.dart';

class CreatePinScreen extends StatelessWidget {
  const CreatePinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinScreen(
      text: 'Create PIN',
      onCompleted: (value) {
        context.go('/confirm_pin');
      },
    );
  }
}
