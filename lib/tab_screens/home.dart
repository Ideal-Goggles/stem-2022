import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stem_2022/models/food_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _foodPostsCollection =
      FirebaseFirestore.instance.collection("foodPosts");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _foodPostsCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error.toString()}",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Loading..."));
        }

        final foodPostList = snapshot.data!.docs
            .map((document) => FoodPost.fromFirestore(document))
            .toList();

        return ListView.separated(
          itemCount: foodPostList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return FoodPostTile(foodPost: foodPostList[index]);
          },
        );
      },
    );
  }
}

class FoodPostTile extends StatelessWidget {
  final FoodPost foodPost;

  const FoodPostTile({super.key, required this.foodPost});

  @override
  Widget build(BuildContext context) {
    // TODO
    return ListTile(title: Text(foodPost.caption));
  }
}
