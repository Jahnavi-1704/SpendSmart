import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'overview.dart';
import 'goals.dart';

class viewGoal extends StatefulWidget {
  const viewGoal({Key? key, required this.userGoals, required this.currentGoals, required this.index}) : super(key: key);
  final List userGoals;
  final List currentGoals;
  final int index;

  @override
  State<viewGoal> createState() => _viewGoalState();
}

class _viewGoalState extends State<viewGoal> {
  String? nameForUpdate;
  TextEditingController? nameController;
  TextEditingController? amountController;
  TextEditingController? savedController;
  DateTime? pickedDate;
  bool datePicked = true;

  @override
  void initState() {
    super.initState();

    nameForUpdate = widget.currentGoals[widget.index]['name'];
    nameController = TextEditingController(text: '${widget.currentGoals[widget.index]['name']}');
    amountController = TextEditingController(text: '${widget.currentGoals[widget.index]['amount']}');
    savedController = TextEditingController(text: '${widget.currentGoals[widget.index]['saved']}');
    pickedDate = widget.currentGoals[widget.index]['date'].toDate();
  }

  @override
  void dispose() {
    nameController?.dispose();
    amountController?.dispose();

    super.dispose();
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
                      Text('View goal', style: TextStyle(fontSize: 25)),
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
                  SizedBox(height: 5),
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
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(right: 100.0),
                    child: Text('How much will you spend?', style: TextStyle(fontSize: 22)),
                  ),
                  SizedBox(height: 5),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 80.0),
                    child: Text('How much have you saved?', style: TextStyle(fontSize: 22)),
                  ),
                  SizedBox(height: 5),
                  Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: savedController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.attach_money, size: 30),
                        ),
                      )
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: pickedDate!,
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
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 110),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: updateDB,
                                icon: Icon(Icons.edit),
                                iconSize: 30,
                              ),
                              Text('Update', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: deleteDB,
                                icon: Icon(Icons.delete),
                                iconSize: 30,
                              ),
                              Text('Delete', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )

                ],
              )
          ),


        ],
      ),
    );
  }

  Future updateDB() async {
    // update single user goals by passing user's auth_id

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
    tempArray = [...widget.userGoals];

    // first from tempArray find and delete the goal which matches the name as nameController.text
    // then add the updated goal to list
    tempArray.removeWhere((goal) => goal['name'] == nameForUpdate);

    final updatedGoal = {
      'name': nameController!.text,
      'amount': int.parse(amountController!.text),
      'date': datePicked ?  pickedDate : DateTime.now(),
      'saved': int.parse(savedController!.text),
    };
    tempArray.add(updatedGoal);

    // update specific fields of the document
    docUser.update({
      'goals': tempArray,
    });

    // after updating fireStore, hide loading dialog and navigate back to Goals screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));
  }

  Future deleteDB() async{
    // update single user goals by passing user's auth_id

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
    tempArray = [...widget.userGoals];

    // delete the goal from list
    tempArray.removeWhere((expense) => expense['name'] == nameForUpdate);

    // update specific fields of the document
    docUser.update({
      'goals': tempArray,
    });

    // after updating fireStore, hide loading dialog and navigate back to Goals screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));
  }

  String styleDate() {
    String temp = "${DateFormat.E().format(pickedDate!)}, ${DateFormat.d().format(pickedDate!)} ${DateFormat.LLL().format(pickedDate!)}";
    return temp;
  }

  String displayDate() {
    String temp = "${DateFormat.d().format(pickedDate!)} ${DateFormat.LLL().format(pickedDate!)}, ${DateFormat.y().format(pickedDate!)}";
    return temp;
  }

}
