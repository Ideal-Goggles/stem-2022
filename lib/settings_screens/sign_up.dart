import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/services/storage_service.dart';

import "package:stem_2022/settings_screens/login.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailRegex =
      RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");

  String username = "";
  String email = "";
  String password = "";

  void signUp() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((creds) {
        final newUser = creds.user!;
        final db = Provider.of<DatabaseService>(context, listen: false);

        // Store user data in Firestore then update display name in Firebase Auth
        db.createAppUser(newUser.uid, newUser.email!, username);
        return newUser.updateDisplayName(username);
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Account created successfully!",
                textAlign: TextAlign.center)));

        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(error.toString(), textAlign: TextAlign.center)));
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Creating account...", textAlign: TextAlign.center)));
    }
  }

  void signInWithGoogle() {
    final googleSignIn = GoogleSignIn();

    // Sign in with Google
    googleSignIn.signIn().then((googleUser) {
      if (googleUser == null) {
        throw Exception("Google Sign In Aborted!");
      }
      return googleUser.authentication;
    }).then((googleAuth) {
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return FirebaseAuth.instance.signInWithCredential(credential);
    }).then((creds) {
      final user = creds.user!;
      final db = Provider.of<DatabaseService>(context, listen: false);

      // Download user's profile picture and upload to Storage
      if (user.photoURL != null) {
        http.get(Uri.parse(user.photoURL!)).then((response) {
          final image = img.decodeImage(response.bodyBytes);
          final jpgImage = img.encodeJpg(image!, quality: 60);
          final jpgImageData = Uint8List.fromList(jpgImage);

          final storage = Provider.of<StorageService>(context, listen: false);
          storage.setUserProfileImage(user.uid, jpgImageData);
        });
      }

      // Update user's Firestore document
      return db
          .updateAppUserDetails(user.uid, user.email!, user.displayName!)
          .then((_) => user.displayName);
    }).then((userDisplayName) {
      // Display a SnackBar with a welcome message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Successfully signed in with Google, welcome back $userDisplayName!",
          textAlign: TextAlign.center,
        ),
      ));

      // Navigate to the previous screen
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString(), textAlign: TextAlign.center),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create an Account")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to HeLP@MPS!",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  onSaved: (newValue) => username = newValue ?? "",
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    hintText: "John Doe",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a username.";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  onSaved: (newValue) => email = newValue ?? "",
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: "Email address",
                    hintText: "johndoe@example.com",
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (_emailRegex.hasMatch(value)) {
                        return null;
                      } else {
                        return "Please enter a valid email address";
                      }
                    }
                    return "Please enter an email address";
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  onSaved: (newValue) => password = newValue ?? "",
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: "Password",
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 8) {
                        return "Password must be at least 8 characters long";
                      }
                      return null;
                    }
                    return "Please enter a password";
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: signUp,
                  color: Colors.grey[900],
                  textColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.all(15),
                  child: const Text("Sign Up"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: signInWithGoogle,
                  color: Colors.grey[900],
                  textColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/google.png",
                        fit: BoxFit.cover,
                        height: 25,
                        width: 25,
                      ),
                      const SizedBox(width: 5),
                      const Text("Login with Google"),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                textColor: Theme.of(context).colorScheme.primary,
                child: const Text("Already a User?"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
