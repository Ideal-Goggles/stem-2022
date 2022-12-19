import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
    color: Colors.grey.withOpacity(0.1),
  );

  Widget textPage(String content) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: _carouselDecoration,
        child: Center(
          child: Text(
            content,
            textAlign: TextAlign.center,
          ),
        ));
  }

  void goToPage(Widget destination) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => destination));
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    bool loggedIn = user != null;

    final carouselItems = [
      textPage(
          "Hammit is an app that aims to reduce food wastage and junk food consumption."),
      textPage(
          "You can post a picture of your food at mealtimes and they will be judged by the community on how healthy they are."),
      textPage(
          "Optionally, you can join a school group and compete with other students to become the healthiest student in your school!"),
      // if (!loggedIn)
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  MaterialButton(
                    onPressed: () => goToPage(const SignUpScreen()),
                    color: Colors.grey.withOpacity(0.1),
                    textColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.all(10),
                    child: const Text("Sign Up"),
                  ),
                  const SizedBox(width: 15),
                  MaterialButton(
                    onPressed: () => goToPage(const LoginScreen()),
                    color: Colors.grey.withOpacity(0.1),
                    textColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.all(10),
                    child: const Text("Login"),
                  ),
                ]),
              ],
            ),
          ),
        )
    ];

    return Scaffold(
        appBar: AppBar(title: const Text("Welcome to Hammit")),
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
