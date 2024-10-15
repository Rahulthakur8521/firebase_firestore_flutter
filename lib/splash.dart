import 'dart:async';
import 'package:firebase_firestore_flutter/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_firestore_flutter/profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    Future.delayed(Duration(seconds: 3), () {
      if (user != null) {
        Navigator.of(context).pushReplacement(
          // MaterialPageRoute(builder: (_) => Profile()),
          //MaterialPageRoute(builder: (_) => PhoneAuth()),
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          // MaterialPageRoute(builder: (_) => PhoneAuth()),
          MaterialPageRoute(builder: (_) => Profile()),
        );
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
            ),
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLaqPLSqCnf6QQjIqrftpp3iE1cN42PpYZkdDLB9o4HQ&s',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

