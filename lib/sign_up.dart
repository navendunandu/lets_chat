// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late ProgressDialog _progressDialog;

  XFile? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context);
  }

  Future<void> registerUser() async {
    _progressDialog.show();
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // User is registered
      String userId = userCredential.user!.uid;
      await insertUserData(userId);
      print("User registered: ${userCredential.user!.uid}");
      _progressDialog.hide();
      Fluttertoast.showToast(
        msg: "Registration Success",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _progressDialog.hide();
        Fluttertoast.showToast(
        msg: "The password provided is too weak",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _progressDialog.hide();
        Fluttertoast.showToast(
        msg: "The account already exists for that email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> insertUserData(String uid) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
    };
    return usersRef
        .child(uid)
        .set(userData)
        .then(
          (_) => uploadImage(uid),
        )
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> uploadImage(String uid) async {
    if (_selectedImage != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$fileName');
      UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
      await uploadTask.whenComplete(() => null);
      String downloadURL = await ref.getDownloadURL();
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(uid);

      userRef
          .update({'profilePicture': downloadURL})
          .then((_) => print("User profile picture updated"))
          .catchError((error) =>
              print("Failed to update user profile picture: $error"));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xff4c505b),
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : _imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : const AssetImage(
                                        'assets/dummy-profile-pic.png')
                                    as ImageProvider,
                        child: _selectedImage == null && _imageUrl == null
                            ? const Icon(
                                Icons.add,
                                size: 40,
                                color: Color.fromARGB(255, 134, 134, 134),
                              )
                            : null,
                      ),
                      if (_selectedImage != null || _imageUrl != null)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Access the text using the controllers
                    String name = _nameController.text;
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    // Implement your registration logic here
                    print('Name: $name, Email: $email, Password: $password');
                    registerUser();
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
