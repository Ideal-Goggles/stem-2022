import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
// import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final wp = WordPair.random();

    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.red,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.amber))),
        home: Scaffold(
          appBar: AppBar(title: const Text("Flutter Test Poggers")),
          body: Center(child: Text(wp.asPascalCase)),
        ));
  }
}
