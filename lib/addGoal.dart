import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'overview.dart';
import 'goals.dart';
import 'notificationservice.dart';

class addGoal extends StatefulWidget {
  const addGoal({Key? key}) : super(key: key);

  @override
  State<addGoal> createState() => _addGoalState();
}

class _addGoalState extends State<addGoal> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  DateTime? pickedDate;
  bool datePicked = false;

  List userGoals = List.empty(growable: true);
  String? userName;
  List notifications = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchDB();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.only(right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      Text('New goal', style: TextStyle(fontSize: 25)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, size: 30)
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.only(right: 115.0),
                    child: Text('What are you saving for?', style: TextStyle(fontSize: 22)),
                  ),
                  SizedBox(height: 15),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      )
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(right: 100.0),
                    child: Text('How much will you spend?', style: TextStyle(fontSize: 22)),
                  ),
                  SizedBox(height: 15),
                  Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: amountController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.attach_money, size: 30),
                        ),
                      )
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2024),
                      ).then((date) {
                        if(date != null)
                        {
                          setState(() {
                            datePicked = true;
                            pickedDate = date;
                          });
                        }
                      });
                    },
                    child: Text(datePicked ? displayDate() : 'Pick a date', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 60),
                  MaterialButton(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    onPressed: updateDB,
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: Icon(Icons.arrow_forward_ios, size: 25, color: Colors.indigo)),
                    ),
                  ),

                ],
              )
          ),


        ],
      ),
    );
  }

  String displayDate() {
    String temp = "${DateFormat.d().format(pickedDate!)} ${DateFormat.LLL().format(pickedDate!)}, ${DateFormat.y().format(pickedDate!)}";
    return temp;
  }

  Future fetchDB() async {
    // fetch goals by passing user's auth_id
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    var doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
    var snapshot =  await doc.get();

    setState(() {
      userGoals = snapshot.data()!['goals'];
      userName = snapshot.data()!['name'];
      notifications = snapshot.data()!['notifications'];
    });

  }

  Future updateDB() async {
    // update single user data by passing user's auth_id

    // when login button is clicked, show a loading button while firebase is authenticating the user
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    final docUser = FirebaseFirestore.instance.collection('user_data').doc(uid);

    List tempArray = List.empty(growable: true);
    tempArray = [...userGoals];
    final newGoal = {
      'name': nameController.text,
      'amount': int.parse(amountController.text),
      'date': datePicked ?  pickedDate : DateTime.now(),
      'saved': 0,
    };
    tempArray.add(newGoal);

    // ----------------------- notification code- -------------------
    List tempList = notifications;
    var notificationObj = {
      'title': '$userName, your ${nameController.text} goal has ended',
      'body': 'Congrats on achieving your goal, Keep going!',
      'date': pickedDate,
    };
    tempList.add(notificationObj);

    // ----------------------notification code ----------------------------

    // update specific fields of the document
    docUser.update({
      'goals': tempArray,
      'notifications': tempList,
    });

    // finally we want to schedule a notification for goal's due date
    await createGoalNotification(userName!, pickedDate!, nameController.text);

    // after updating fireStore, hide loading dialog and navigate back to Goals screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));
  }
}
