import 'package:flutter/material.dart';

import 'constants.dart';
class Button1 extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const Button1({
    Key? key,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        image: const DecorationImage(
          image: AssetImage("images/guitargradient.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
        child: TextButton(
          onPressed: onPressed,
          child: Text(buttonText, style: kButtonTextStyle1),
        ),
      ),
    );
  }
}

class Button2 extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const Button2({
    Key? key,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
        child: TextButton(
          onPressed: onPressed,
          child: Text(buttonText, style: kButtonTextStyle2),
        ),
      ),
    );
  }
}
