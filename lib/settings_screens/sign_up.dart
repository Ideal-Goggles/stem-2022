import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          .then((creds) => creds.user!.updateDisplayName(username))
          .then((_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account created successfully!"))))
          .catchError((error) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString()))));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Creating account..."),
          duration: Duration(seconds: 2)));
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
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextFormField(
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
                TextFormField(
                  onSaved: (newValue) => email = newValue ?? "",
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: "Email address",
                    hintText: "myemail@mail.com",
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
                TextFormField(
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.75),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.all(15)),
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ));
  }
}
