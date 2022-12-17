import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:stem_2022/services/database_service.dart';

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
                  "Welcome to Hammit!",
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
                    color: Colors.grey.withOpacity(0.1),
                    textColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.all(15),
                    child: const Text("Sign Up"),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
