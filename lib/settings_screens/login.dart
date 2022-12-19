import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailRegex =
      RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");

  String email = "";
  String password = "";

  void login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((creds) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Successfully signed in, welcome back ${creds.user!.displayName}!",
                textAlign: TextAlign.center)));

        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString(), textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Logging in...", textAlign: TextAlign.center),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _signInWithGoogle() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      // Display a SnackBar with a welcome message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Successfully signed in with Google, welcome back ${user!.displayName}!",
            textAlign: TextAlign.center),
      ));

      // Navigate to the previous screen
      Navigator.pop(context);
    } catch (error) {
      // Display a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString(), textAlign: TextAlign.center),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Log Into Your Account")),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome Back to Hammit!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
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
                    onPressed: login,
                    color: Colors.grey.withOpacity(0.1),
                    textColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.all(15),
                    child: const Text("Login"),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                      onPressed: () => _signInWithGoogle(),
                      color: Colors.grey.withOpacity(0.1),
                      textColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child: Image.asset(
                                  // '/assets/images/google.png',
                                  "assets/images/google_blue.png",
                                  fit: BoxFit.cover,
                                  height: 24,
                                  width: 24)),
                          Text(' Login In with Google'),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
