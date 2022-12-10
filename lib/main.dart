import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
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
            appBarTheme: AppBarTheme(
              elevation: 0,
            ),
            primarySwatch: Colors.red,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.amber))),
        home: Scaffold(
          appBar: AppBar(title: const Text("I HAVE NO CLUE WHAT IM DOING")),
          body: const Center(child: RandomWords()),
        ));
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    final wp = WordPair.random();
    return Text(wp.asPascalCase);
  }
}
