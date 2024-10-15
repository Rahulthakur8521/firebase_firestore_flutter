

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'otp_page.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController _phoneController = TextEditingController(text: "+91");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Auth'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                     hintText: 'Phone number'
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () async{
            await FirebaseAuth.instance.verifyPhoneNumber(
                verificationCompleted: (PhoneAuthCredential credential){},
                verificationFailed: (FirebaseAuthException ex){},
                codeSent: (String verificationId, int? resendToken){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => OtpPage(verificationId: verificationId),));
                },
                codeAutoRetrievalTimeout: (String verificationId){},
                phoneNumber: _phoneController.text.toString()
            );
            },
              child: Text('Send Otp')
          )
        ],
      ),
    );
  }
}
