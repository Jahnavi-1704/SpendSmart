import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewGoal.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Goals extends StatefulWidget {
  const Goals({Key? key}) : super(key: key);

  @override
  State<Goals> createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  List userGoals = List.empty(growable: true);
  List currentGoals = List.empty(growable: true);
  num? userSaved;
  num? userExpense;
  String userName = "";
  List notifications = List.empty(growable: true);

  bool initialLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    readGoalData();
    setState(() {
      initialLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: initialLoad == true ?
        SpinKitPouringHourGlassRefined(
          color: Colors.orange,
          size: 50.0,
        )
            :
        Column(
          children: [
            SizedBox(height: 50),
            Center(
              child: userExpense == null ?
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 9.0,
                percent: 0,
                center: Text("\$$userSaved / \$$userExpense"),
                progressColor: Colors.indigo,
              )
              :
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 9.0,
                percent: userSaved!/userExpense!,
                center: Text("\$$userSaved / \$$userExpense"),
                progressColor: Colors.indigo,
              ),
            ),
            SizedBox(height: 20),
            Center(child: Text('Upcoming Goals', style: TextStyle(fontSize: 30))),
            Container(
              width: double.infinity,
              height: 340,
              color: Colors.white,
              child: ListView.builder(
                itemCount: currentGoals.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                      elevation: 15,
                      color: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.indigo, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(createDate(index), style: TextStyle(fontSize: 16)),
                                Text(createYear(index), style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                          trailing: Text('\$ ${currentGoals[index]['amount']}', style:TextStyle(fontSize: 20)),
                          title: Text('${currentGoals[index]['name']}', style:TextStyle(fontSize: 20)),
                          subtitle: Text('Saved \$${currentGoals[index]['saved']} till now'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => viewGoal(userGoals: userGoals, currentGoals: currentGoals, index: index, userName: userName, notifications: notifications)));
                          }
                      ),
                    ),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }

  Future readGoalData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    var doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
    var snapshot =  await doc.get();

    setState(() {
      userGoals = snapshot.data()!['goals'];
      userName = snapshot.data()!['name'];
      notifications: snapshot.data()!['notifications'];
    });

    // sort the goals list in ascending order
    List tempList = snapshot.data()!['goals'];
    tempList.sort((a,b) => a['date'].compareTo(b['date']));

    num tempSaved = 0;
    num tempExpense = 0;

    for(var goal in tempList) {
      tempExpense =  tempExpense + goal['amount'];
      tempSaved = tempSaved + goal['saved'];
    }

    setState(() {
      currentGoals = tempList;
      userSaved = tempSaved;
      userExpense = tempExpense;
    });
  }

  String createDate(int index) {
    String temp = "${DateFormat.d().format(currentGoals[index]['date'].toDate())} ${DateFormat.LLL().format(currentGoals[index]['date'].toDate())}";
    return temp;
  }

  String createYear(int index) {
    String temp = DateFormat.y().format(currentGoals[index]['date'].toDate());
    return temp;
  }



}
