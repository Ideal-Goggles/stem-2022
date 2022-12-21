import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/services/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  int _secondsLeft = 60;

  String _caption = "";

  @override
  void initState() {
    super.initState();
    timer(); // Start the timer
  }

  Future timer() async {
    while (_secondsLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) break;
      setState(() => _secondsLeft--);
    }
  }

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

        return db.createFoodPost(currentUser!.uid, _caption).then(
            (foodPostId) => storage.setFoodPostImage(foodPostId, imageData));
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Successfully created a post!",
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
          ),
        ),
      ),
    );
  }
}
