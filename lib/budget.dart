import 'package:flutter/material.dart';
import 'screenTransition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'overview.dart';
import 'notificationservice.dart';

class Budget extends StatefulWidget {
  const Budget({Key? key, required this.name, required this.profile, required this.tracking_period}) : super(key: key);
  final String name;
  final bool profile;
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
    List tempList = List.empty(growable: true);

    if(widget.tracking_period == 1)
    {
      track_name = 'daily';

      DateTime upcomingDay = DateTime.now().add(Duration(days: 1));
      DateTime lastDate = DateTime(2024, DateTime.december, 31);

      while(upcomingDay.isBefore(lastDate))
      {
        print('day: ${upcomingDay.day} ${upcomingDay.month} ${upcomingDay.year}');

        var notificationObj = {
          'title': '${widget.name}, current day has ended',
          'body': 'Select which goals you would like to contribute your savings towards.',
          'date': upcomingDay,
        };

        tempList.add(notificationObj);

        // update upcoming day to next period
        upcomingDay = upcomingDay.add(Duration(days: 1));
      }

    }
    else if(widget.tracking_period == 2)
    {
      track_name = "monthly";

      var currentMonth = DateTime.now().month;
      var currentYear = DateTime.now().year;
      DateTime upcomingMonth;

      if(currentMonth == DateTime.december)
      {
        // year changes
        upcomingMonth = DateTime(currentYear+1, DateTime.january, 1);
      }
      else
      {
        // same year
        upcomingMonth = DateTime(currentYear, currentMonth+1, 1);
      }

      DateTime lastDate = DateTime(2024, DateTime.december, 31);
      while(upcomingMonth.isBefore(lastDate))
      {
        print('month: ${upcomingMonth.month} ${upcomingMonth.year}');

        var notificationObj = {
          'title': '${widget.name}, current month has ended',
          'body': 'Select which goals you would like to contribute your savings towards.',
          'date': upcomingMonth,
        };

        tempList.add(notificationObj);

        // update upcoming month to next period
        if(upcomingMonth.month == DateTime.december)
        {
          // year changes
          upcomingMonth = DateTime(upcomingMonth.year+1, DateTime.january, 1);
        }
        else
        {
          // same year
          upcomingMonth = DateTime(upcomingMonth.year, upcomingMonth.month+1, 1);
        }
      }

    }
    else if(widget.tracking_period == 3)
    {
      track_name = "yearly";

      var currentYear = DateTime.now().year;
      DateTime upcomingYear = DateTime(currentYear+1, DateTime.january, 1);

      DateTime lastDate = DateTime(2024, DateTime.december, 31);
      while(upcomingYear.isBefore(lastDate))
      {
          print('year: ${upcomingYear.year}');

          var notificationObj = {
            'title': '${widget.name}, current year has ended',
            'body': 'Select which goals you would like to contribute your savings towards.',
            'date': upcomingYear,
          };

          tempList.add(notificationObj);

        // update upcoming year to next period
        upcomingYear = DateTime(upcomingYear.year+1, DateTime.january, 1);
      }
    }

    print(tempList.length);

    final docUser = FirebaseFirestore.instance.collection('user_data').doc(uid);
    final json = {
      'name': widget.name,
      'profile': widget.profile,
      'tracking_period': track_name,
      'budget': int.parse(budgetController.text),
      'expense_array': [],
      'goals': [],
      'notifications': tempList,
      'current_balance': int.parse(budgetController.text),
    };
    await docUser.set(json);

    // schedule notification for upcoming tracking period
    await createExpenseNotification(widget.name, track_name);

    Navigator.push(context, screenTransition(page: Overview()));
  }
}
