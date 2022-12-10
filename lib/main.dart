import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const primaryColor = Color.fromARGB(255, 0, 81, 5);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Ideal Food',
        theme: ThemeData(
            primarySwatch: Colors.green,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.amber))),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("I HAVE NO CLUE WHAT IM DOING"),
            elevation: 0.00,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
                bottom: Radius.circular(30),
              ),
            ),
          ),
          body: const Center(child: RandomWords()),
          backgroundColor: Colors.black,
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
