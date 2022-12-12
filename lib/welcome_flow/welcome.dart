import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to Hammit"),
          elevation: 0,
          backgroundColor: Colors.grey.withOpacity(0.05),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.withOpacity(0.1)),
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 15),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  items: const [
                    Text("hi"),
                    Text("hello"),
                    Text("bello"),
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [0, 1, 2].map((i) {
                final color = i == _current ? Colors.grey[700] : Colors.grey;
                return Container(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      Icons.circle,
                      color: color,
                      size: 10,
                    ));
              }).toList(),
            ),
          ],
        )));
  }
}
