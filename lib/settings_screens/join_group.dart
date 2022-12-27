import 'package:flutter/material.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();

  String groupCode = "";

  void showJoinGroupDialog() {
    // TODO
  }

  void joinGroup() {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join a Group"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Group Code",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              TextFormField(
                onSaved: (newValue) => groupCode = newValue ?? "",
                keyboardType: TextInputType.number,
                autocorrect: false,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: "Group Code",
                  hintText: "1234",
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) != null && value.length == 4) {
                      return null;
                    } else {
                      return "Code must be a 4-digit number";
                    }
                  }
                  return "Please enter a code";
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: showJoinGroupDialog,
                  color: Colors.grey[900],
                  textColor: Theme.of(context).colorScheme.primary,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.all(15),
                  child: const Text("Join"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
