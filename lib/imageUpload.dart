import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadImage extends StatefulWidget {
  const UploadImage({Key? key}) : super(key: key);

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  String? imageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageUrl = pickedImage.path;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (imageUrl == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final file = File(imageUrl!);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final destination = 'images/$fileName';

      await firebase_storage.FirebaseStorage.instance.ref(destination).putFile(file);

      final downloadURL = await firebase_storage.FirebaseStorage.instance.ref(destination).getDownloadURL();
      print('Image uploaded to Firebase Storage: $downloadURL');

      // Navigate to the ImageUploadedPage after successful upload
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImageUploadedPage(downloadURL)),
      );

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      // Handle error
      print('Error uploading image: $error');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            imageUrl == null
                ? Icon(Icons.person, size: 200, color: Colors.grey)
                : Center(
              child: Image.file(
                File(imageUrl!),
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickImage();
                  },
                  icon: Icon(Icons.image),
                  label: Text(
                    'Choose Image',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: imageUrl != null ? () async { await _uploadImage(); } : null,
                  icon: Icon(Icons.cloud_upload),
                  label: Text(
                    'Upload Image',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}



class ImageUploadedPage extends StatefulWidget {
  final String downloadURL;

  const ImageUploadedPage(this.downloadURL, {Key? key}) : super(key: key);

  @override
  _ImageUploadedPageState createState() => _ImageUploadedPageState();
}

class _ImageUploadedPageState extends State<ImageUploadedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Uploaded'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Image Uploaded Successfully!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Image.network(
              widget.downloadURL,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateImage,
              child: Text('Update Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteImage,
              child: Text('Delete Image'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateImage() {
    showDialog(context: context,
        builder: (BuildContext context){
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text("Are you sure you want to update this image"),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          },
              child: Text("Cancel")
          ),
          TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: Text("Update")
          )
        ],
      );
    }
    );
  }

  void _deleteImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete this image?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
