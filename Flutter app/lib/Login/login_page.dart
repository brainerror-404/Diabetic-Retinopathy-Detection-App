import 'package:app/constant.dart';
import 'package:flutter/material.dart';
import '../responsive.dart';

import '../../components/background.dart';
import 'components/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileLoginScreen(),
          tablet: TabletLoginScreen(),
        ),
      ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenIcon(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginForm(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}

class TabletLoginScreen extends StatelessWidget {
  const TabletLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoginScreenIcon(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 600, // Adjust width for tablet layout
              child: LoginForm(),
            ),
          ],
        ),
      ],
    );
  }
}

class LoginScreenIcon extends StatelessWidget {
  const LoginScreenIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        const SizedBox(height: defaultPadding - 16.0),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 5,
              child: Image.asset("assets/icons/lock.png"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding - 16.0),
      ],
    );
  }
}
