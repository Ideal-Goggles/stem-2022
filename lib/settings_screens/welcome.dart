import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:stem_2022/settings_screens/login.dart';
import 'package:stem_2022/settings_screens/sign_up.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;
  final _carouselDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    // border: Border.all(color: Colors.grey),
    color: Colors.grey[900],
  );

  Widget textPage(Text content) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _carouselDecoration,
      child: Center(child: content),
    );
  }

  void goToPage(Widget destination) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => destination));
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final loggedIn = user != null;

    final carouselItems = [
      textPage(const Text(
        "HeLP@MPS is an app that aims to reduce food wastage and junk food consumption.",
        textAlign: TextAlign.center,
      )),
      textPage(const Text(
        "You can post a picture of your food at mealtimes and they will be judged by the community on how healthy they are.\n\nBased on how the community rates your posts, you get H's (or points). Your total points are shown at the top of the screen along with your username and avatar.",
        textAlign: TextAlign.center,
      )),
      textPage(const Text(
        "Optionally, you can join a school group and compete with other students to become the healthiest student in your school!\n\nYour school may have given you a \"School Code\", which you can enter into the Join Group page and help raise your school's overall ranking as well.",
        textAlign: TextAlign.center,
      )),
      if (!loggedIn)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: _carouselDecoration,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "To get started create a new account by signing up, or log into an existing account.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () => goToPage(const SignUpScreen()),
                      color: Colors.grey[900],
                      textColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.all(10),
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(width: 15),
                    MaterialButton(
                      onPressed: () => goToPage(const LoginScreen()),
                      color: Colors.grey[900],
                      textColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.all(10),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      textPage(const Text(
        "Once you've joined a school group, your class teacher will add you to your class subgroup.\n\nThis will help in collecting data about your food wastage and eating habits to provide greater insights on food waste management in your school.",
        textAlign: TextAlign.center,
      )),
      textPage(Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: "All of this is just the start,\nvisit ",
            ),
            TextSpan(
              text: "our website",
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrlString("https://hammit.fun");
                },
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(
              text: " for more details.",
            ),
          ],
        ),
        textAlign: TextAlign.center,
      )),
    ];

    return Scaffold(
        appBar: AppBar(title: const Text("Welcome to HeLP@MPS")),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 15),
                enlargeCenterPage: true,
                height: 500,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: carouselItems,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselItems.asMap().keys.map((i) {
                final primaryColor = Theme.of(context).colorScheme.primary;

                return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 20),
                    child: Icon(
                      Icons.circle,
                      color: i == _current
                          ? primaryColor.withOpacity(0.6)
                          : primaryColor.withOpacity(0.95),
                      size: 10,
                    ));
              }).toList(),
            ),
          ],
        )));
  }
}
