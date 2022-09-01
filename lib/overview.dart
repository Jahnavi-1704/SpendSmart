import 'package:flutter/material.dart';
import 'home.dart';
import 'Profile.dart';
import 'goals.dart';
import 'summary.dart';
import 'addExpense.dart';
import 'addGoal.dart';
import 'package:bouncing_widget/bouncing_widget.dart';

class Overview extends StatefulWidget {
  const Overview({Key? key}) : super(key: key);

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  int currentTab = 0;
  final List<Widget> screens = [
    Home(),
    summary(),
    Goals(),
    Profile()
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // display option to add either expense or goal
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => Container(
                padding: EdgeInsets.symmetric(vertical: 250),
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          // first dismiss dialog and then navigate to addExpense screen
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => addExpense()));
                        },
                        child: Text('Add expense', style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          // first dismiss dialog and then navigate to addGoal screen
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => addGoal()));
                        },
                        child: Text('Add saving goal', style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                    ),
                  ],
                ),
              )
          );
        },
        backgroundColor: Colors.blue[900],
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = Home();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: currentTab == 0 ? Colors.blue[900] : Colors.grey,
                        ),
                        Text('Home', style: TextStyle(color: currentTab == 0 ? Colors.blue[900] : Colors.grey)),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = summary();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights,
                          color: currentTab == 1 ? Colors.blue[900] : Colors.grey,
                        ),
                        Text('Insights', style: TextStyle(color: currentTab == 1 ? Colors.blue[900] : Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = Goals();
                        currentTab = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          color: currentTab == 2 ? Colors.blue[900] : Colors.grey,
                        ),
                        Text('Goals', style: TextStyle(color: currentTab == 2 ? Colors.blue[900] : Colors.grey)),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = Profile();
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          color: currentTab == 3 ? Colors.blue[900] : Colors.grey,
                        ),
                        Text('Account', style: TextStyle(color: currentTab == 3 ? Colors.blue[900] : Colors.grey)),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
