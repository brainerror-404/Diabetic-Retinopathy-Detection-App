import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    Key? key,
    required this.child,
    this.topImage = "assets/icons/main_top.png",
    this.bottomImage = "assets/icons/main_bottom.png",
  }) : super(key: key);

  final String topImage, bottomImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: -10,
              left: -40,
              child: Image.asset(
                topImage,
                width: 500,
              ),
            ),
            Positioned(
              bottom: -35,
              right: -40,
              child: Image.asset(bottomImage, width: 500),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}
