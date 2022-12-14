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
          .then(
              (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Account created successfully!",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.white12,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(),
                    behavior: SnackBarBehavior.floating,
                    elevation: 5,
                  )))
          .catchError(
              (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      error.toString(),
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.blue,
                    margin: EdgeInsets.all(15),
                    shape: StadiumBorder(),
                    behavior: SnackBarBehavior.floating,
                    elevation: 5,
                  )));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Creating account...",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.blue,
          margin: EdgeInsets.all(15),
          shape: StadiumBorder(),
          behavior: SnackBarBehavior.floating,
          elevation: 5,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Welcome to Hammit!",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    onSaved: (newValue) => username = newValue ?? "",
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade600),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      labelText: "Username",
                      hintText: "John Doe",
                      labelStyle: TextStyle(color: Colors.blue[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade600),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      labelText: "Email address",
                      hintText: "johndoe@example.com",
                      labelStyle: TextStyle(color: Colors.blue[600]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
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
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade600),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.blue[600]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
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
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    // width:,
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        foregroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.all(15)),
                    child: const Text("Sign Up"),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
