import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "";
  TextEditingController? budgetController;
  TextEditingController? trackingController;
  String email = "";
  bool profile = false;

  PlatformFile? profileImage;
  String? downloadedURL;
  String? downloadedName;

  bool initialLoad = true;

  @override
  void dispose() {
    budgetController?.dispose();
    trackingController?.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchDB();
    fetchProfileImage();

    initialLoad = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initialLoad == true ?
      SpinKitPouringHourGlassRefined(
        color: Colors.orange,
        size: 50.0,
      )
          :
      ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: Material(
                    color: Colors.grey,
                    child: Ink.image(
                        image: profile? NetworkImage(downloadedURL!) : AssetImage('assets/images/profile.png') as ImageProvider,
                        fit: BoxFit.cover,
                        width: 110,
                        height: 110,
                        child: InkWell(onTap: () {

                        })
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 4,
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(3),
                        child: ClipOval(
                          child: Container(
                            color: Colors.blue,
                            child: IconButton(
                              icon: Icon(Icons.add_a_photo),
                              iconSize: 20,
                              color: Colors.white,
                              onPressed: selectProfileImage,
                            )
                          ),
                        ),
                      ),
                    )
                ),

              ],
            )
          ),
          SizedBox(height: 15),
          Column(
            children: [
              Text(name, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              )),
              SizedBox(height: 4),
              Text(email, style: TextStyle(
                color: Colors.grey,
              )),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: BouncingWidget(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => payment()));
              },
              child: ElevatedButton(
                onPressed: () {
                  // navigate to payment screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) => payment()));
                },
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: BouncingWidget(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => payment()));
                    },
                    child: Text('Upgrade to PRO', style: TextStyle(fontSize: 17))
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text('My Budget is', style: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: budgetController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.attach_money, size: 30),
                  ),
                )
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text('Track my expenses', style: TextStyle(fontSize: 18)),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: trackingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'daily/monthly/yearly',
                ),
              )
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: updateDB,
              child: Text(
                'Update Profile',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationThickness: 1,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () {
                // navigate to login screen
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
              },
              child: Text(
                'SignOut',
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
    );
  }

  Future fetchProfileImage() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    final fetchPath = '${uid}/profile.jpg';

    final ref = FirebaseStorage.instance.ref(fetchPath);
    String url = await ref.getDownloadURL();
    String name = ref.name;

    setState(() {
      downloadedURL = url;
      downloadedName = name;
    });
  }

  // works for both first or updating profile image
  Future selectProfileImage() async {
    final result = await FilePicker.platform.pickFiles();
    if(result == null) return;

    setState(() {
      profileImage = result.files.first;
    });
  }

  // works for both first or updating profile image
  Future uploadProfileImage() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    final path = '${uid}/profile.jpg';
    final file = File(profileImage!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
  }

  Future updateDB() async {
    // update single user profile data by passing user's auth_id

    // when login button is clicked, show a loading button while firebase is authenticating the user
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    final docUser = FirebaseFirestore.instance.collection('user_data').doc(uid);

    // update specific fields of the document
    docUser.update({
      'budget': int.parse(budgetController!.text),
      'tracking_period': trackingController!.text,
    });

    uploadProfileImage();

    // after updating fireStore, hide loading dialog
    Navigator.pop(context);
  }

  Future fetchDB() async {
    // fetch user profile parameters by passing user's auth_id
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    var doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
    var snapshot =  await doc.get();

    setState(() {
      name = snapshot.data()!['name'];
      budgetController = TextEditingController(text: '${snapshot.data()!['budget']}');
      trackingController = TextEditingController(text: '${snapshot.data()!['tracking_period']}');
      profile = snapshot.data()!['profile'];
      email = auth.currentUser!.email!;
    });

    if(snapshot.data()!['profile'] == true)
    {
      fetchProfileImage();
    }

  }

}
