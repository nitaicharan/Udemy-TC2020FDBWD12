import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = '/';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller1;
  Animation animation1;

  @override
  void initState() {
    super.initState();
    controller1 =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    controller1.forward();
    animation1 = CurvedAnimation(parent: controller1, curve: Curves.decelerate);
    controller1.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: animation1.value * 100.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              text: 'Log In',
              onPressed: () => Navigator.pushNamed(
                context,
                LoginScreen.id,
              ),
              color: Colors.lightBlueAccent,
            ),
            RoundedButton(
              text: 'Register',
              onPressed: () => Navigator.pushNamed(
                context,
                RegistrationScreen.id,
              ),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}