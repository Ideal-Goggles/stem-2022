import 'dart:async';
import 'dart:math' show pi;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stem_2022/models/food_post.dart';
import 'package:stem_2022/models/app_user.dart';

import 'package:stem_2022/services/storage_service.dart';
import 'package:stem_2022/services/database_service.dart';

import 'package:stem_2022/settings_screens/welcome.dart';

class RefreshEvent extends Event {}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _refreshEvent = RefreshEvent();
  Future<List<FoodPost>>? _postsFuture;

  @override
  void initState() {
    super.initState();

    final db = Provider.of<DatabaseService>(context, listen: false);
    _postsFuture = db.getRecentFoodPosts();

    _refreshEvent.subscribe(
      (_) {
        final future = db.getRecentFoodPosts();
        setState(() {
          _postsFuture = future;
        });
      },
    );
  }

  Future<void> showWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final previousLaunch = prefs.getInt("appPreviousLaunch");

    await prefs.setInt(
      "appPreviousLaunch",
      DateTime.now().millisecondsSinceEpoch,
    );

    // Check if user is opening app for the first time
    if (previousLaunch != null) {
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.grey[900],
              title: const Text("Welcome to HELPe!"),
              content: const Text(
                "Welcome to HELPe: The Food App! Would you like to take a quick tour?",
                style: TextStyle(color: Colors.grey),
              ),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No, Thank You"),
                ),
                MaterialButton(
                  onPressed: () => Navigator.pop(context, true),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text("Yes Please!"),
                ),
              ],
            ));
      },
    ).then((redirect) {
      if (redirect!) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    showWelcomeDialog();

    return FutureBuilder(
      future: _postsFuture,
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

        return RefreshIndicator(
          onRefresh: () {
            final db = Provider.of<DatabaseService>(context, listen: false);
            final completer = Completer();

            setState(() {
              _postsFuture = db.getRecentFoodPosts();
              _postsFuture!.then((_) => completer.complete(null));
            });

            return completer.future;
          },
          child: Provider.value(
            value: _refreshEvent,
            child: ListView.separated(
              key: const PageStorageKey("foodPostList"),
              padding: const EdgeInsets.only(top: 15, bottom: 75),
              itemCount: foodPostList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) =>
                  FoodPostCard(foodPost: foodPostList[index]),
            ),
          ),
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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _streakAnimation;

  @override
  void initState() {
    _streakAnimation = AnimationController(
      vsync: this,
      upperBound: 2 * pi,
      duration: Duration(
        // ignore: division_optimization
        milliseconds: (2000 * pi / 0.75).toInt(),
      ),
    );

    _streakAnimation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _streakAnimation.forward(from: 0);
          break;
        case AnimationStatus.dismissed:
          _streakAnimation.forward(from: 0);
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });

    _streakAnimation.forward();
    super.initState();
  }

  @override
  void dispose() {
    _streakAnimation.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void showRatingDialog() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final foodPost = widget.foodPost;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "You must be logged in to rate a post!",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));

      return;
    }

    if (currentUser.uid == foodPost.authorId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "You cannot rate your own post!",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));

      return;
    }

    final db = Provider.of<DatabaseService>(context, listen: false);

    db.foodPostRatingExists(foodPost.id, currentUser.uid).then((exists) {
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            "You have already rated this post!",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      } else {
        showDialog(
          context: context,
          builder: (context) => RatingDialog(foodPostId: widget.foodPost.id),
        );
      }
    });
  }

  void showDeletionDialog() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final foodPost = widget.foodPost;

    if (currentUser == null) return;

    if (currentUser.uid != foodPost.authorId) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "You can only delete your own posts!",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));

      return;
    }

    final now = DateTime.now();

    if (now.difference(foodPost.dateAdded.toDate()).inHours >= 24) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "You created this post more than 24 hours ago, you cannot delete it now!",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));

      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: Colors.grey[900],
            title: const Text("Delete Post?"),
            content: const Text(
              "This post will be permanently deleted.",
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              MaterialButton(
                onPressed: () => Navigator.pop(context, true),
                color: Theme.of(context).colorScheme.error,
                shape: const StadiumBorder(),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },
    ).then((deleteConfirmed) {
      if (deleteConfirmed) {
        final db = Provider.of<DatabaseService>(context, listen: false);
        final storage = Provider.of<StorageService>(context, listen: false);

        return storage
            .deleteFoodPostImage(foodPost.id)
            .then((_) => db.deleteFoodPost(foodPost.id))
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Successfully deleted your post!",
              textAlign: TextAlign.center,
            ),
          ));

          // Refresh post list
          final refreshEvent =
              Provider.of<RefreshEvent>(context, listen: false);
          refreshEvent.broadcast();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final storage = Provider.of<StorageService>(context);
    final db = Provider.of<DatabaseService>(context);

    final foodPost = widget.foodPost;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Card(
        color: Colors.grey[900],
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
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

                  return MaterialButton(
                      onPressed: null,
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        showDeletionDialog();
                      },
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30)),
                        ),
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                            child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Image.memory(snapshot.data!,
                                    fit: BoxFit.cover))),
                      ));
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: MultiProvider(
                      providers: [
                        FutureProvider<Uint8List?>.value(
                          value: storage.getUserProfileImage(foodPost.authorId),
                          initialData: null,
                          catchError: (context, error) => null,
                        ),
                        StreamProvider<AppUser>.value(
                          value: db.streamAppUser(foodPost.authorId),
                          initialData: AppUser.previewUser,
                        ),
                      ],
                      builder: (context, child) {
                        final userImage = Provider.of<Uint8List?>(context);
                        final appUser = Provider.of<AppUser>(context);
                        final showStreak = appUser.streak >= 3;

                        ImageProvider userImageProvider;

                        if (userImage != null) {
                          userImageProvider = MemoryImage(userImage);
                        } else {
                          userImageProvider = const AssetImage(
                            "assets/images/defaultUserImage.jpg",
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(children: [
                            MaterialButton(
                              padding: EdgeInsets.zero,
                              minWidth: 0,
                              onPressed: () {
                                if (showStreak) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "${appUser.displayName} is on a ${appUser.streak}-day posting streak!",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedBuilder(
                                    animation: _streakAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: showStreak
                                            ? BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: GradientBoxBorder(
                                                  width: 1.5,
                                                  gradient: LinearGradient(
                                                    transform: GradientRotation(
                                                        _streakAnimation.value),
                                                    colors: [
                                                      Colors.yellow,
                                                      Colors.orange.shade600,
                                                      Colors.orange.shade600,
                                                      Colors.red,
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : null,
                                        child: CircleAvatar(
                                          radius: 20,
                                          foregroundImage: userImageProvider,
                                        ),
                                      );
                                    },
                                  ),
                                  if (showStreak)
                                    Positioned.directional(
                                      textDirection: TextDirection.ltr,
                                      bottom: -3,
                                      end: -5,
                                      child: Icon(
                                        CupertinoIcons.flame_fill,
                                        color: Colors.orange[600],
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                appUser.displayName,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${foodPost.totalRating} H",
                              style: const TextStyle(color: Colors.white38),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.people,
                                color: Colors.white38, size: 22),
                            const SizedBox(width: 2),
                            Text(
                              foodPost.numberOfRatings.toString(),
                              style: const TextStyle(color: Colors.white38),
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 37, 37, 37),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          foodPost.caption,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[400]),
                          textAlign: TextAlign.start,
                        ),
                        IconButton(
                          onPressed: showRatingDialog,
                          color: Theme.of(context).colorScheme.primary,
                          icon: const Icon(Icons.thumbs_up_down_rounded),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingDialog extends StatelessWidget {
  final String foodPostId;

  const RatingDialog({super.key, required this.foodPostId});

  ratingSelect(BuildContext context, int rating) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser!;

    db.addFoodPostRating(foodPostId, currentUser.uid, rating).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "You have rated this post a $rating!",
          textAlign: TextAlign.center,
        ),
      ));

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
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
                        onPressed: () => ratingSelect(context, index + 1),
                        minWidth: 9,
                        color: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                        onPressed: () => ratingSelect(context, index + 6),
                        minWidth: 9,
                        color: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        textColor: Theme.of(context).colorScheme.primary,
                        child: Text("${index + 6}"),
                      ),
                    ),
                  )),
              const Text(
                "1 being least healthy, and 10 being most healthy.",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              )
            ],
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }
}
