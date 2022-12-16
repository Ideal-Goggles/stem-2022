import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:stem_2022/models/food_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final _foodPostsQuery = FirebaseFirestore.instance
      .collection("foodPosts")
      .orderBy("dateAdded", descending: true);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future:
          _foodPostsQuery.get(const GetOptions(source: Source.serverAndCache)),
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
          padding: const EdgeInsets.only(top: 20),
          itemCount: foodPostList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return FoodPostCard(foodPost: foodPostList[index]);
          },
        );
      },
    );
  }
}

class FoodPostCard extends StatelessWidget {
  final FoodPost foodPost;

  const FoodPostCard({super.key, required this.foodPost});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final storageRef = FirebaseStorage.instance
        .ref("foodPostImages")
        .child("${foodPost.id}.jpg");

    return Card(
      color: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: primaryColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            FutureBuilder(
              future: storageRef.getData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 35,
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }

                return Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(5)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(snapshot.data!),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              foodPost.caption,
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
