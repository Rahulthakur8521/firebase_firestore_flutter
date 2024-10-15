import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_firestore_flutter/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var name = "";
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerAddress = TextEditingController();
  String? selectedGender;
  File? _image;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseFirestore.instance.collection("users").doc().id;
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    try {

      await FirebaseFirestore.instance.collection("users").doc(userId).set(user);
    } catch (error) {
      print("Error adding user: $error");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('user_images/${DateTime.now().toString()}');
      final firebase_storage.UploadTask uploadTask = ref.putFile(_image!);
      final url = await (await uploadTask).ref.getDownloadURL();

      var user = {
        "id": userId,
        "name": controllerName.text,
        "email": controllerEmail.text,
        "address": controllerAddress.text,
        "gender": selectedGender,
        "imageUrl": url,
      };
      await setUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration form'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Select Image Source"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Text("Gallery"),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _pickImage(ImageSource.gallery);
                                },
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                child: Text("Camera"),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.add_a_photo, size: 50) : null,
                ),
              ),
            ),
            Text("$name", style: TextStyle(color: Colors.white, fontSize: 10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextFormField(
                controller: controllerName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelText: "Enter your name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextFormField(
                controller: controllerEmail,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelText: "Enter your email",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextFormField(
                controller: controllerAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelText: "Enter your address",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Gender: ", style: TextStyle(fontSize: 16)),
                  Radio<String>(
                    value: 'Male',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  Text("Male"),
                  Radio<String>(
                    value: 'Female',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  Text("Female"),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var user = {
                  "id": userId,
                  "name": controllerName.text,
                  "email": controllerEmail.text,
                  "address": controllerAddress.text,
                  "gender": selectedGender,
                };
                await setUser(user);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              child: Text("Add user"),
            ),
          ],
        ),
      ),
    );
  }
}
