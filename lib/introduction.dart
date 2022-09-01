import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'trackBy.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'screenTransition.dart';

class Introduction extends StatefulWidget {
  const Introduction({Key? key}) : super(key: key);

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final nameController = TextEditingController();

  bool profile = false;
  PlatformFile? profileImage;

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70),
            Center(
              child: Text(
                'Hi there!',
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                "Let's get you started",
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.6), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 70),
            Center(
              child: Text(
                "What's your full name?",
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            Container(
                child: TextFormField(
                  controller: nameController,
                  cursorColor: Colors.indigo,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                  ),
                )
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "Choose your profile icon",
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 10),
            MaterialButton(
              color: Color.fromRGBO(0, 51, 102, 0.9),
              shape: const CircleBorder(),
              onPressed: selectProfileImage,
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: Icon(Icons.add, color: Colors.white, size: 25)),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                // function which passes name and picture(if any) to TrackBy screen
                // need to upload profile picture to Firebase Storage before moving on
                uploadProfileImage();

                Navigator.push(context, screenTransition(page: TrackBy(name: nameController.text, profile: profile)));
              },
              child: Center(
                child: Text(
                  profile ?
                  'Proceed'
                      :
                  'Skip for now',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationThickness: 1,
                    color: Colors.blue,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future selectProfileImage() async {
    final result = await FilePicker.platform.pickFiles();
    if(result == null) return;

    setState(() {
      profile = true;
      profileImage = result.files.first;
    });
  }

  Future uploadProfileImage() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    final path = '${uid}/profile.jpg';
    final file = File(profileImage!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
  }

}
