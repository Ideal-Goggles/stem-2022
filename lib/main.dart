import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:stem_2022/firebase_options.dart';
import 'package:stem_2022/tab_screens/groups_screen.dart';
import 'package:stem_2022/tab_screens/home_screen.dart';
import 'package:stem_2022/tab_screens/settings_screen.dart';

void main() {
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      // ignore: avoid_print
      .then((value) => print("Firebase has been initialized"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ideal Food',
        theme: ThemeData(
            primarySwatch: Colors.red,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.white))),
        home: SafeArea(
            minimum: const EdgeInsets.all(10),
            child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  bottomNavigationBar: const TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.home)),
                        Tab(icon: Icon(Icons.group)),
                        Tab(icon: Icon(Icons.settings)),
                      ],
                      padding: EdgeInsets.only(left: 12, right: 12),
                      indicatorColor: Colors.transparent),
                  appBar: AppBar(
                      elevation: 0.00,
                      backgroundColor: Colors.black45,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(50),
                            bottom: Radius.circular(50),
                          ),
                          side: BorderSide(color: Colors.white54))),
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
