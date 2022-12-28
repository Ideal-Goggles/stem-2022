import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:stem_2022/services/database_service.dart';
import 'package:stem_2022/services/storage_service.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  void selectNewProfilePicture(BuildContext context, ImageSource source) {
    final currentUser = Provider.of<User?>(context, listen: false);
    final imagePicker = ImagePicker();

    imagePicker
        .pickImage(source: source)
        .then((image) => image!.readAsBytes())
        .then((imageData) {
      final storage = Provider.of<StorageService>(context, listen: false);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Uploading image, please wait...",
          textAlign: TextAlign.center,
        ),
      ));

      return storage.setUserProfileImage(currentUser!.uid, imageData);
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Successfully changed profile picture! Note that it may take some time to update everywhere.",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 6),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          error.toString(),
          textAlign: TextAlign.center,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final storage = Provider.of<StorageService>(context);
    final db = Provider.of<DatabaseService>(context, listen: false);

    final usesPasswordLogin = currentUser!.providerData
        .any((provider) => provider.providerId == "password");

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: MaterialButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ChangePicDialog(),
                ).then((source) {
                  if (source == null) {
                    return;
                  }
                  selectNewProfilePicture(context, source);
                });
              },
              color: Colors.grey[900],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: storage.getUserProfileImage(currentUser.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          radius: 50,
                          foregroundImage: MemoryImage(snapshot.data!),
                        );
                      }
                      return const CircleAvatar(
                        radius: 50,
                        foregroundImage:
                            AssetImage("assets/images/defaultUserImage.jpg"),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Change Profile Picture"),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.edit_rounded)
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 116,
            child: MaterialButton(
              onPressed: () => const EditNameDialog(),
              color: Colors.grey[900],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              elevation: 0,
              child: MaterialButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const EditNameDialog(),
                  ).then((newDisplayName) {
                    if (newDisplayName != null) {
                      return currentUser
                          .updateDisplayName(newDisplayName)
                          .then((_) => db.updateAppUserDetails(currentUser.uid,
                              currentUser.email!, newDisplayName))
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Changed username to $newDisplayName",
                            textAlign: TextAlign.center,
                          ),
                        ));
                      });
                    }
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        currentUser.displayName!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Edit Username"),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.edit_rounded)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (usesPasswordLogin)
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
                  borderRadius: BorderRadius.all(Radius.circular(30)),
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
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ChangePicDialog extends StatelessWidget {
  const ChangePicDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      backgroundColor: Colors.grey[900],
      title: const Text('Change Profile Picture'),
      content: const Text('Select a new profile picture from your device'),
      actions: <Widget>[
        MaterialButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
        MaterialButton(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          color: const Color.fromRGBO(13, 71, 161, 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          child: const Text('Camera'),
        ),
        MaterialButton(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
          color: const Color.fromRGBO(13, 71, 161, 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          child: const Text('Gallery'),
        ),
      ],
    );
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
        borderRadius: BorderRadius.all(Radius.circular(30)),
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
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              Navigator.of(context).pop(_nameController.text);
            }
          },
          color: const Color.fromRGBO(13, 71, 161, 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
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
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      backgroundColor: Colors.grey[900],
      title: const Text('Change Password'),
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
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          elevation: 0,
          child: const Text('Change'),
        ),
      ],
    );
  }
}
