import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_chat/sign_up.dart';

class LoginScreen extends StatefulWidget {
 @override
 _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 final _auth = FirebaseAuth.instance;
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                 final user = (await _auth.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                 )).user;
                //  if (user != null) {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => RecentChatsScreen()),
                //     );
                //  }
                } catch (e) {
                 print(e);
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
 }
}
