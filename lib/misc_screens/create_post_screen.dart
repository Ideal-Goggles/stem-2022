import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _postTimeGap = const Duration(hours: 5);

  String _caption = "";

  void clickPicture() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final imagePicker = ImagePicker();

      imagePicker
          .pickImage(
            source: ImageSource.camera,
            requestFullMetadata: false,
          )
          .then((image) => image!.readAsBytes())
          .then((imageData) {
        final db = Provider.of<DatabaseService>(context, listen: false);
        final storage = Provider.of<StorageService>(context, listen: false);
        final currentUser = Provider.of<User?>(context, listen: false);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Creating post, please wait...",
            textAlign: TextAlign.center,
          ),
        ));

        final image = img.decodeImage(imageData);
        final jpgImage = img.encodeJpg(image!, quality: 75);
        final jpgImageData = Uint8List.fromList(jpgImage);

        return db.createFoodPost(currentUser!.uid, _caption).then(
            (foodPostId) => storage.setFoodPostImage(foodPostId, jpgImageData));
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Successfully created post! Refresh the home page to see it.",
            textAlign: TextAlign.center,
          ),
        ));

        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final currentUser = Provider.of<User?>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Create a Post")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Create A New Post",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text(
                "You can delete your post within 24 hours of posting it by long pressing it on the home page.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: db.getUserLatestFoodPost(currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final foodPost = snapshot.data;

                  // Check if there is the required time gap since last post
                  if (foodPost != null) {
                    final now = DateTime.now();
                    final dateAdded = foodPost.dateAdded.toDate();
                    final timeDiff = now.difference(dateAdded);

                    if (timeDiff < _postTimeGap) {
                      final nextPostTime = dateAdded.add(_postTimeGap);
                      final timeTillNextPost = nextPostTime.difference(now);

                      String timeString;

                      if (timeTillNextPost.inSeconds > 60) {
                        final timeStringSplit =
                            timeTillNextPost.toString().split(":");
                        timeString =
                            "${timeStringSplit[0]}:${timeStringSplit[1]} hour(s)";
                      } else {
                        timeString = "${timeTillNextPost.inSeconds} second(s)";
                      }

                      return Text(
                        "You cannot post right now, come back in $timeString!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    }
                  }

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          onSaved: (newValue) => _caption = newValue ?? "",
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                          decoration: const InputDecoration(
                            labelText: "Caption",
                            hintText: "An amazing meal!",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a caption";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: clickPicture,
                          color: Colors.grey[900],
                          textColor: Theme.of(context).colorScheme.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, size: 25),
                              SizedBox(width: 5),
                              Text("Click a Picture"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
