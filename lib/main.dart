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
            primarySwatch: Colors.deepPurple,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.white))),
        home: const SafeArea(
            child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  bottomNavigationBar: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.home)),
                      Tab(icon: Icon(Icons.group)),
                      Tab(icon: Icon(Icons.settings))
                    ],
                    indicatorColor: Colors.transparent,
                  ),
                  body: TabBarView(
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
