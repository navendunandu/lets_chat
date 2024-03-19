import 'package:flutter/material.dart';
import 'package:lets_chat/login.dart';

class SplashScreen extends StatefulWidget {
 @override
 _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
 late AnimationController _controller;
 late Animation<double> _animation;

 @override
 void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Call the method to navigate to the main screen after a delay
    navigateToMainScreen();
 }

 @override
 void dispose() {
    _controller.dispose();
    super.dispose();
 }

 void navigateToMainScreen() async {
    // Wait for 3 seconds before navigating to the main screen
    await Future.delayed(Duration(seconds: 3));
    // Navigate to the main screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
 }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Text(
              'Lets Chat',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
 }
}
