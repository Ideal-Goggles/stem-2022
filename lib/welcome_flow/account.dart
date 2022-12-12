import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Management"),
        elevation: 0,
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Hammit!"),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email address",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                child: Text('Get Magic Link'),
                onPressed: () {
                  print('Sent!');
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue.withOpacity(0.75),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: EdgeInsets.all(15))),
          ],
        ),
      ),
    );
  }
}
