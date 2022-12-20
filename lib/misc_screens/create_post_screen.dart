import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  int _secondsLeft = 60;

  String _caption = "";

  Future timer() async {
    while (_secondsLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) break;
      setState(() => _secondsLeft--);
    }
  }

  @override
  void initState() {
    super.initState();
    timer(); // Start the timer
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
                "Create a new post",
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
                      return "Please enter an email address";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: () {},
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
