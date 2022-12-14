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
  static const primaryThemeColor = Colors.indigo;
  static const formErrorColor = Colors.deepOrangeAccent;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ideal Food',
        theme: ThemeData(
            primarySwatch: primaryThemeColor,
            // listTileTheme: ListTileThemeData(
            //   iconColor: primaryThemeColor[200],
            //   shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10)),
            //   tileColor: Colors.blueGrey.withOpacity(0.2),
            // ),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme:
                AppBarTheme(color: Colors.grey.withOpacity(0.07), elevation: 0),
            colorScheme: const ColorScheme.dark(primary: primaryThemeColor),
            inputDecorationTheme: const InputDecorationTheme(
              errorStyle: TextStyle(color: formErrorColor),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: formErrorColor, width: 1)),
              focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: formErrorColor, width: 2)),
            )),
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
              bottomNavigationBar: Container(
                  color: Colors.grey.withOpacity(0.07),
                  // decoration: BoxDecoration(
                  //   color: Colors.yellow,
                  //   border: Border.all(color: Colors.black),
                  // ),
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: const SafeArea(
                    child: TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.white38,
                      tabs: [
                        Tab(icon: Icon(Icons.home)),
                        Tab(icon: Icon(Icons.group)),
                        Tab(icon: Icon(Icons.settings))
                      ],
                      indicatorColor: Colors.transparent,
                    ),
                  )),
              body: const SafeArea(
                  minimum: EdgeInsets.all(8),
                  child: TabBarView(
                    children: [
                      HomeScreen(),
                      GroupsScreen(),
                      SettingsScreen(),
                    ],
                  )),
              // backgroundColor: Colors.black,
            )));
  }
}
