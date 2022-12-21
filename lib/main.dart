import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stem_2022/firebase_options.dart';
import 'package:stem_2022/services/storage_service.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/tab_screens/groups.dart';
import 'package:stem_2022/tab_screens/home.dart';
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
  static const primaryErrorColor = Color.fromRGBO(50, 0, 0, 1);
  static const primaryErrorTextColor = Color.fromRGBO(135, 0, 0, 1);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.userChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),
        Provider<StorageService>.value(value: StorageService()),
        Provider<DatabaseService>.value(value: DatabaseService()),
      ],
      child: MaterialApp(
        title: 'Ideal Food',
        theme: ThemeData(
          primarySwatch: primaryThemeColor,
          fontFamily: "Inter",
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(color: Colors.grey[900], elevation: 5),
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
              borderSide: const BorderSide(color: primaryErrorColor, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: primaryErrorColor, width: 2),
              borderRadius: BorderRadius.circular(14),
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
        home: const MyAppHome(),
      ),
    );
  }
}

class MyAppHome extends StatelessWidget {
  const MyAppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const MyAppBar(),
        extendBodyBehindAppBar: true,
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
            elevation: 5,
            fixedSize: const Size.fromRadius(25),
            shape: const CircleBorder(),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Icon(Icons.add, size: 25),
        ),
        bottomNavigationBar: Container(
          color: Colors.grey[900],
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: SafeArea(
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.group)),
                Tab(icon: Icon(Icons.settings))
              ],
              indicatorColor: Colors.transparent,
            ),
          ),
        ),
        body: const SafeArea(
          minimum: EdgeInsets.all(8),
          child: TabBarView(
            children: [
              HomeScreen(),
              GroupsScreen(),
              SettingsScreen(),
            ],
          ),
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
    final storage = Provider.of<StorageService>(context);

    final usernameTitle = currentUser?.displayName ?? "Guest";

    return AppBar(
      title: Row(
        children: [
          if (currentUser == null) getAvatar(null),
          if (currentUser != null)
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                usernameTitle,
                style: const TextStyle(
                  fontSize: 15,
                ),
                maxLines: 1,
              ),
              if (currentUser == null) ...[
                const SizedBox(width: 5),
                const Text("(Not Signed In)",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
