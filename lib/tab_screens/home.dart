import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stem_2022/models/food_post.dart';
import 'package:stem_2022/services/storage_service.dart';
import 'package:stem_2022/services/database_service.dart';

import "package:stem_2022/tab_screens/settings.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<FoodPost>>? _foodPostsFuture;

  @override
  void initState() {
    super.initState();

    final db = Provider.of<DatabaseService>(context, listen: false);
    _foodPostsFuture = db.getRecentFoodPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _foodPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error.toString()}",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(child: Text("Loading..."));
        }

        final foodPostList = snapshot.data!;

        return ListView.separated(
          key: const PageStorageKey("foodPostList"),
          padding: const EdgeInsets.symmetric(vertical: 15),
          itemCount: foodPostList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) =>
              FoodPostCard(foodPost: foodPostList[index]),
        );
      },
    );
  }
}

class FoodPostCard extends StatefulWidget {
  final FoodPost foodPost;

  const FoodPostCard({super.key, required this.foodPost});

  @override
  State<FoodPostCard> createState() => _FoodPostCardState();
}

class _FoodPostCardState extends State<FoodPostCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final storage = Provider.of<StorageService>(context, listen: false);
    final db = Provider.of<DatabaseService>(context);

    final currentUser = Provider.of<User?>(context, listen: false);

    final foodPost = widget.foodPost;

    var userId;

    return Card(
      color: Colors.grey[900],
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(children: [
                FutureBuilder(
                  future: storage.getUserProfileImage(foodPost.authorId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(
                        radius: 20,
                        foregroundImage: MemoryImage(snapshot.data!),
                      );
                    }
                    return const CircleAvatar(
                      radius: 20,
                      foregroundImage:
                          AssetImage("assets/images/defaultUserImage.jpg"),
                    );
                  },
                ),
                const SizedBox(width: 10),
                StreamBuilder(
                  stream: db.streamAppUser(foodPost.authorId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.displayName,
                        maxLines: 1,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                    return Text(
                      "Unknown User",
                      style: TextStyle(color: Colors.blueGrey[300]),
                    );
                  },
                ),
              ]),
            ),
            const SizedBox(height: 15),
            FutureBuilder(
              future: storage.getFoodPostImage(foodPost.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 35,
                  );
                } else if (snapshot.connectionState ==
                        ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const CircularProgressIndicator.adaptive();
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withOpacity(0.5), width: 1),
                      top: BorderSide(
                          color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                  ),
                  child: Image.memory(snapshot.data!),
                );
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    foodPost.caption,
                    style: TextStyle(
                        fontSize: 13,
                        // fontWeight: FontWeight.w600,
                        color: Colors.grey[400]),
                    textAlign: TextAlign.start,
                  ),
                  // if (!DatabaseService.foodPostRatingExists)
                  MaterialButton(
                      minWidth: 9,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const RatingDialog(),
                        );
                      },
                      textColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.thumbs_up_down_rounded)),

                  if (currentUser != null)
                    FutureBuilder<bool>(
                      future:
                          db.foodPostRatingExists(foodPost.id, currentUser.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return MaterialButton(
                              minWidth: 9,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const RatingDialog(),
                                );
                              },
                              textColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.thumbs_up_down_rounded));
                        }
                        return MaterialButton(
                            onPressed: () => const SettingsScreen(),
                            textColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.thumbs_up_down_rounded));
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingDialog extends StatelessWidget {
  const RatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    ratingSelect(int rating) {
      //TODO rating func
      Future.delayed(const Duration(milliseconds: 800));
      Navigator.of(context).pop(true);
    }

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      backgroundColor: Colors.grey[900],
      title: const Text('Rate it'),
      content: SizedBox(
        height: 109,
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => SizedBox(
                    width: 40,
                    child: MaterialButton(
                      onPressed: () {
                        ratingSelect(index + 1);
                        Navigator.of(context).pop(true);
                      },
                      minWidth: 9,
                      color: Colors.grey[800],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      elevation: 0,
                      textColor: Theme.of(context).colorScheme.primary,
                      child: Text("${index + 1}"),
                    ),
                  ),
                )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => SizedBox(
                    width: 40,
                    child: MaterialButton(
                      onPressed: () {
                        ratingSelect(index + 6);
                      },
                      minWidth: 9,
                      color: Colors.grey[800],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      elevation: 0,
                      textColor: Theme.of(context).colorScheme.primary,
                      child: Text("${index + 6}"),
                    ),
                  ),
                )),
            const Text("1 being least healthy, and 10 being most healthy.",
                style: TextStyle(color: Colors.grey, fontSize: 10))
          ],
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cancel'),
        )
      ],
    );
  }
}
