import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stem_2022/firebase_options.dart';

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
        home: SafeArea(
            minimum: const EdgeInsets.all(10),
            child: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                      title: const Text("Ideal Food"),
                      bottom: const TabBar(tabs: [
                        Tab(icon: Icon(Icons.home)),
                        Tab(icon: Icon(Icons.group)),
                        Tab(icon: Icon(Icons.settings)),
                      ], padding: EdgeInsets.only(left: 12, right: 12)),
                      elevation: 0.00,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                          bottom: Radius.circular(15),
                        ),
                      )),
                  body: const TabBarView(
                    children: [
                      Center(
                          child: Text(
                        "Home",
                        style: TextStyle(fontSize: 20),
                      )),
                      Center(
                          child: Text(
                        "Groups",
                        style: TextStyle(fontSize: 20),
                      )),
                      Center(
                          child: Text(
                        "Settings",
                        style: TextStyle(fontSize: 20),
                      )),
                    ],
                  ),
                  backgroundColor: Colors.black,
                ))));
  }
}
