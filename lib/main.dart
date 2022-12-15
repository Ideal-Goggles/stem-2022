import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stem_2022/firebase_options.dart';
import 'package:stem_2022/tab_screens/groups.dart';
import 'package:stem_2022/tab_screens/home.dart';
import 'package:stem_2022/tab_screens/settings.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Change these to change the general theme of the app
  static const primaryThemeColor = Colors.blue;
  static const primaryErrorColor = Colors.deepOrangeAccent;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        )
      ],
      child: MaterialApp(
        title: 'Ideal Food',
        theme: ThemeData(
            primarySwatch: primaryThemeColor,
            fontFamily: "Inter",
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme:
                AppBarTheme(color: Colors.grey.withOpacity(0.1), elevation: 0),
            colorScheme: const ColorScheme.dark(
                primary: primaryThemeColor, error: primaryErrorColor),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryThemeColor),
                borderRadius: BorderRadius.circular(14),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              errorStyle: const TextStyle(color: primaryErrorColor),
              errorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: primaryErrorColor, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: primaryErrorColor, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Colors.blue,
              shape: StadiumBorder(),
              behavior: SnackBarBehavior.floating,
              elevation: 5,
              contentTextStyle: TextStyle(color: Colors.white),
            )),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            bottomNavigationBar: Container(
                color: Colors.grey.withOpacity(0.1),
                // decoration: BoxDecoration(
                //   color: Colors.yellow,
                //   border: Border.all(color: Colors.black),
                // ),
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: const SafeArea(
                  child: TabBar(
                    labelColor: primaryThemeColor,
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
          ),
        ),
      ),
    );
  }
}
