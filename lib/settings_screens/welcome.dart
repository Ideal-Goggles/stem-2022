import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;
  final _carouselDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey.withOpacity(0.07));

  Widget textPage(String content) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: _carouselDecoration,
        child: Center(
          child: Text(
            content,
            textAlign: TextAlign.center,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final carouselItems = [
      textPage(
          "Hammit is an app that aims to reduce food wastage and junk food consumption."),
      textPage(
          "You can post a picture of your food at mealtimes and they will be judged by the community on how healthy they are."),
      textPage(
          "Optionally, you can join a school group and compete with other students to become the healthiest student in your school!"),
    ];

    return Scaffold(
        appBar: AppBar(title: const Text("Welcome to Hammit")),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 15),
                enlargeCenterPage: true,
                height: 260,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: carouselItems,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselItems.asMap().keys.map((i) {
                return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                    child: Icon(
                      Icons.circle,
                      color: i == _current ? Colors.grey[700] : Colors.grey,
                      size: 10,
                    ));
              }).toList(),
            ),
          ],
        )));
  }
}
