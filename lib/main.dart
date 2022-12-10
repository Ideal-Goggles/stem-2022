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
            primarySwatch: Colors.deepPurple,
            textTheme:
                const TextTheme(bodyMedium: TextStyle(color: Colors.white))),
        home: SafeArea(
            minimum: const EdgeInsets.all(10),
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Ideal Food"),
                elevation: 0.00,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
              body: const Center(child: RandomWords()),
              backgroundColor: Colors.black,
            )));
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
