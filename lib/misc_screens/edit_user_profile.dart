import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async';

final _auth = FirebaseAuth.instance;

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context);
    // final user = FirebaseAuth.instance;

    return Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 116,
                child: MaterialButton(
                  onPressed: () => const EditNameDialog(),
                  color: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  elevation: 0,
                  child: MaterialButton(
                    onPressed: () async {
                      final newDisplayName = await showDialog(
                        context: context,
                        builder: (context) => const EditNameDialog(),
                      );
                      if (newDisplayName != null) {
                        await currentUser.updateDisplayName(newDisplayName);
                      }
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              "${currentUser.displayName}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("Edit Profile"),
                              Icon(Icons.edit_rounded)
                            ],
                          ),
                        ]),
                  ),
                )),
            const SizedBox(
              height: 15,
            ),
            if (currentUser.providerData
                .any((provider) => provider.providerId == 'password'))
              SizedBox(
                  height: 116,
                  child: MaterialButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ChangePasswordDialog(),
                      );
                    },
                    color: Colors.grey[900],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    elevation: 0,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Change Password"),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.password)
                        ]),
                  )),
          ],
        ));
  }
}

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({super.key});

  @override
  EditNameDialogState createState() => EditNameDialogState();
}

class EditNameDialogState extends State<EditNameDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      backgroundColor: Colors.grey[900],
      title: const Text('Edit Username'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(hintText: 'New username'),
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          color: const Color.fromRGBO(13, 71, 161, 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          elevation: 0,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ChangePasswordDialogState createState() => ChangePasswordDialogState();
}

class ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        final credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: _currentPasswordController.text,
        );
        final result =
            await currentUser.reauthenticateWithCredential(credential);

        if (result.user != null) {
          await currentUser.updatePassword(_newPasswordController.text);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Changed Password Successfully!",
                textAlign: TextAlign.center),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.primary,
          ));
        } else {
          // ignore: use_build_context_synchronously
          throw ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                const Text("Incorrect Password", textAlign: TextAlign.center),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString(), textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      backgroundColor: Colors.grey[900],
      title: const Text('Edit Username'),
      content: SizedBox(
        height: 137,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current password'),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _newPasswordController,
                validator: (value) {
                  if (value == null) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        MaterialButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        MaterialButton(
          onPressed: () async {
            _changePassword();
            await Future.delayed(const Duration(milliseconds: 1500));
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
          color: const Color.fromRGBO(13, 71, 161, 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          elevation: 0,
          child: const Text('Change'),
        ),
      ],
    );
  }
}
