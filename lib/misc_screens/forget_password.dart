import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static final auth = FirebaseAuth.instance;
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String email = "";
  final _emailRegex =
      RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");

  void resetPassword({required String email}) async {
    await auth
        .sendPasswordResetEmail(email: email)
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text("Sent!", textAlign: TextAlign.center))))
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Theme.of(context).colorScheme.error,
                content: Text(error.toString(), textAlign: TextAlign.center))));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Forgot Password")),
        body: Form(
            key: _key,
            child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Forgot Password",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          onSaved: (newValue) => email = newValue ?? "",
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () {
                            resetPassword(email: _emailController.text.trim());
                          },
                          color: Colors.grey[900],
                          textColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.all(15),
                          child: const Text("Send"),
                        ),
                      ),
                    ]))));
  }
}
