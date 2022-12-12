import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:stem_2022/firebase_options.dart';
import 'package:stem_2022/tab_screens/groups.dart';
import 'package:stem_2022/tab_screens/home.dart';
import 'package:stem_2022/tab_screens/settings.dart';

void main() {
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      // ignore: avoid_print
      .then((value) => print("Firebase has been initialized"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Change this to change the general theme of the app.
  // This exists because sometime Colors.primaries.first gives
  // a different color than the primary swatch color for reasons
  // I cannot bother to find out.
  static const primaryThemeColor = Colors.deepPurple;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ideal Food',
        theme: ThemeData(
            primarySwatch: primaryThemeColor,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.white))),
        home: SafeArea(
            bottom: false,
            child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  bottomNavigationBar: Container(
                      color: primaryThemeColor,
                      padding: const EdgeInsets.only(bottom: 20, top: 2),
                      child: const TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.home)),
                          Tab(icon: Icon(Icons.group)),
                          Tab(icon: Icon(Icons.settings))
                        ],
                        indicatorColor: Colors.transparent,
                      )),
                  body: const TabBarView(
                    children: [
                      HomeScreen(),
                      GroupsScreen(),
                      SettingsScreen(),
                    ],
                  ),
                  backgroundColor: Colors.black,
                ))));
  }
}
