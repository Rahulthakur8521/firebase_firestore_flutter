import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.cyanAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var userData = documents[index].data() as Map<String, dynamic>;
                var name = userData['name'] ?? '';
                var email = userData['email'] ?? '';
                var address = userData['address'] ?? '';
                var imageUrl = userData['image']; // Retrieve image URL
                var documentId = documents[index].id; // Retrieve document ID here

                return ListTile(
                  title: Container(
                    color: Colors.blue[200],
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null)
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(email),
                        Text(address),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showUpdateDialog(context, userData, documentId),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => showDeleteDialog(context, documentId),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void showUpdateDialog(BuildContext context, Map<String, dynamic> userData, String documentId) {
  var nameController = TextEditingController(text: userData['name']);
  var emailController = TextEditingController(text: userData['email']);
  var addressController = TextEditingController(text: userData['address']);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Update User"),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              var updatedData = {
                "name": nameController.text,
                "email": emailController.text,
                "address": addressController.text,
              };
              updateUserData(documentId, updatedData);
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}

Future<void> updateUserData(String documentId, Map<String, dynamic> updatedData) async {
  try {
    await FirebaseFirestore.instance.collection("users").doc(documentId).update(updatedData);
  } catch (error) {
    print("Error updating document: $error");
  }
}

Future<void> showDeleteDialog(BuildContext context, String documentId) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete User"),
        content: Text("Are you sure you want to delete this user?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              deleteUserData(documentId);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

Future<void> deleteUserData(String documentId) async {
  try {
    await FirebaseFirestore.instance.collection("users").doc(documentId).delete();
  } catch (error) {
    print("Error deleting document: $error");
  }
}
