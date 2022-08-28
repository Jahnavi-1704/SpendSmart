import 'package:flutter/material.dart';
import 'home.dart';
import 'screenTransition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'overview.dart';

class Budget extends StatefulWidget {
  const Budget({Key? key, required this.name, required this.picture, required this.tracking_period}) : super(key: key);
  final String name;
  final File? picture;
  final int tracking_period;

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  int budget = 0;
  String? tracking_name;
  final budgetController = TextEditingController();

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
                'Phew, one last step to go!',
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.6), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 70),
            Center(
              child: Text(
                setName(),
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 30, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  style: TextStyle(fontSize: 30),
                  controller: budgetController,
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
                    prefixIcon: Icon(Icons.attach_money, size: 40),
                  ),
                )
            ),
            SizedBox(height: 240),
            MaterialButton(
              color: Color.fromRGBO(0, 51, 102, 0.9),
              shape: const CircleBorder(),
              onPressed: addUser,
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String setName () {
    if(widget.tracking_period == 1)
    {
      tracking_name = 'weekly';
    }
    else if(widget.tracking_period == 2)
    {
      tracking_name = "monthly";
    }
    else if(widget.tracking_period == 3)
    {
      tracking_name = "yearly";
    }
    else if(widget.tracking_period == 0)
      {
        return "Set your budget";
      }

    return "Set your $tracking_name budget";
  }

  Future addUser() async {
    // first create a new user in Firestore and then navigate to home screen

    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    String track_name = "monthly";
    if(widget.tracking_period == 1)
    {
      track_name = 'weekly';
    }
    else if(widget.tracking_period == 2)
    {
      track_name = "monthly";
    }
    else if(widget.tracking_period == 3)
    {
      track_name = "yearly";
    }

    final docUser = FirebaseFirestore.instance.collection('user_data').doc(uid);
    final json = {
      'name': widget.name,
      'picture': widget.picture == null ? "" : widget.picture,
      'tracking_period': track_name,
      'budget': int.parse(budgetController.text),
      'expense_array': [],
      'goals': [],
    };
    await docUser.set(json);

    Navigator.push(context, screenTransition(page: Overview()));
  }
}
