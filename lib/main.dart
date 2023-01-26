import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stem_2022/firebase_options.dart';
import 'package:stem_2022/models/app_user.dart';
import 'package:stem_2022/services/storage_service.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/tab_screens/home.dart';
import 'package:stem_2022/tab_screens/groups.dart';
import 'package:stem_2022/tab_screens/my_group.dart';
import 'package:stem_2022/tab_screens/settings.dart';

import 'package:stem_2022/misc_screens/create_post_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Change these to change the general theme of the app
  static const primaryThemeColor = Colors.blue;
  static const primaryErrorColor = Colors.red;

  static final db = DatabaseService();
  static final storage = StorageService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.userChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),
        Provider<DatabaseService>.value(value: db),
        Provider<StorageService>.value(value: storage),
      ],
      child: MaterialApp(
        title: "Hammit",
        theme: ThemeData(
          primarySwatch: primaryThemeColor,
          fontFamily: "Inter",
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.grey.shade900.withOpacity(0.2),
          appBarTheme:
              AppBarTheme(color: Colors.grey.shade900.withOpacity(0.5)),
          colorScheme: const ColorScheme.dark(
              primary: primaryThemeColor, error: primaryErrorColor),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[900],
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(25),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(25),
            ),
            errorStyle: const TextStyle(color: primaryErrorColor),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryErrorColor, width: 1),
              borderRadius: BorderRadius.circular(25),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryErrorColor, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: primaryThemeColor,
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            elevation: 5,
            contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        home: const AppHome(),
      ),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => MyAppHome();
}

class MyAppHome extends State<AppHome> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const MyAppBar(),
        extendBodyBehindAppBar: false,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ElevatedButton(
          onPressed: () {
            final currentUser = Provider.of<User?>(context, listen: false);

            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                  "You must be logged in to create a post",
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreatePostScreen()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 1,
            fixedSize: const Size.fromRadius(25),
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Icon(
              CupertinoIcons.plus_rectangle_fill_on_rectangle_fill,
              size: 18),
        ),
        bottomNavigationBar: BottomNavyBar(
          backgroundColor: Colors.grey[900],
          selectedIndex: _currentIndex,
          onItemSelected: (index) => setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          }),
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              title: const Text(
                'Home',
                textAlign: TextAlign.center,
              ),
              icon: const Icon(CupertinoIcons.house_fill),
              activeColor: Colors.orange,
              inactiveColor: Colors.white60,
            ),
            BottomNavyBarItem(
              title: const Text(
                'Groups',
                textAlign: TextAlign.center,
              ),
              icon: const Icon(CupertinoIcons.group_solid),
              activeColor: Colors.yellow,
              inactiveColor: Colors.white60,
            ),
            BottomNavyBarItem(
              title: const Text(
                'Stats',
                textAlign: TextAlign.center,
              ),
              icon: const Icon(CupertinoIcons.chart_bar_alt_fill),
              activeColor: Colors.green,
              inactiveColor: Colors.white60,
            ),
            BottomNavyBarItem(
              title: const Text(
                'Settings',
                textAlign: TextAlign.center,
              ),
              icon: const Icon(CupertinoIcons.gear_alt_fill),
              activeColor: Colors.blue,
              inactiveColor: Colors.white60,
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: const <Widget>[
            HomeScreen(),
            GroupsScreen(),
            MyGroupScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  // Not sure if this is the best way to get the default preferred size but it works.
  Size get preferredSize => Size.copy(AppBar().preferredSize);

  Widget getAvatar(ImageProvider? imageProvider) {
    return CircleAvatar(
      radius: 15,
      foregroundImage: imageProvider ??
          const AssetImage("assets/images/defaultUserImage.jpg"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final appUser = Provider.of<AppUser?>(context);

    if (currentUser == null || appUser == null) {
      return AppBar(
        title: Row(
          children: [
            getAvatar(null),
            const SizedBox(width: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  "Guest",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(width: 5),
                Text(
                  "(Not Signed In)",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final storage = Provider.of<StorageService>(context);

    return AppBar(
      titleTextStyle: const TextStyle(
        fontSize: 15,
      ),
      title: Row(
        children: [
          FutureBuilder(
            future: storage.getUserProfileImage(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return getAvatar(MemoryImage(snapshot.data!));
              }
              return getAvatar(null);
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(appUser.displayName)),
                Text(
                  "${appUser.overallRating} H",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
