import 'package:flutter/material.dart';
import 'package:app/constant.dart';

class AccountCheck extends StatelessWidget {
  final bool login;
  final Function? press;
  const AccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "Don’t have an Account? " : "Already have an Account? ",
          style: const TextStyle(color: kPrimaryColor, fontSize: 15),
        ),
        GestureDetector(
          onTap: press as void Function()?,
          child: Text(
            login ? "Sign Up" : "Sign In",
            style: const TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        )
      ],
    );
  }
}
