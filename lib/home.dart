import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notifications.dart';
import 'package:intl/intl.dart';
import 'viewExpense.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;

  // all the user data declared as state variables
  String userName = "";
  int userBudget = 0;
  String userTrackingPeriod = "";
  int balanceLeft = 0;
  List userExpenses = List.empty(growable: true);

  String greeting = "";

  List displayList = List.empty(growable: true);

  List displayMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  List displayYears = [
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
  ];

  List displayDates = List.empty(growable: true);
  List displayNumbers = List.empty(growable: true);

  String currentMonth = "";
  String currentDay = "";
  String currentYear = "";

  List currentExpenses = List.empty(growable: true);
  List recurringExpenses = List.empty(growable: true);

  int currentBalance = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // morning or afternoon or evening
    setGreeting();

    print('fetching data');
    readUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${greeting},',
                              style: TextStyle(color: Colors.white, fontSize: 18)
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${userName}',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.all(1.0),
                        child: IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()));
                            },
                            color: Colors.white,
                            icon: Icon(Icons.notifications)
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text('Total Balance ^', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('\$ ${calculateBalance()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 3.0,
                            color: setColor(index) ? Colors.blue.shade900 : Colors.white
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        displayChange(index);
                      },
                      child: Text("${displayList[index]}",
                          style: TextStyle(
                              color: setColor(index) ? Colors.blue.shade900 : Colors.grey
                          )
                      ),
                    ),
                  );
                }
              ),
            ),
            Container(
              height: 5,
              color: Colors.white,
            ),
            Container(
              width: double.infinity,
              height: 363,
              color: Colors.white,
              child: currentExpenses.isEmpty ?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
                child: Center(
                    child: Column(
                      children: [
                        Text('You currently do not have any expenses'),
                        Text('Start by adding something.'),
                      ],
                    ),
                ),
              )
              :
              ListView.builder(
                itemCount: currentExpenses.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Card(
                      elevation: 15,
                      color: Colors.grey.shade200,
                      child: ListTile(
                        leading: Icon(Icons.radio_button_unchecked, color: iconColor(index), size: 30),
                        trailing: Text('\$ ${currentExpenses[index]['amount']}', style:TextStyle(fontSize: 20)),
                        title: Text('${currentExpenses[index]['name']}', style:TextStyle(fontSize: 20)),
                        subtitle: Text(createDateFormat(index)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => viewExpense(userExpenses: userExpenses, currentExpenses: currentExpenses, index: index, userName: userName, trackingPeriod: userTrackingPeriod, currentBalance: balanceLeft)));
                        }
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                color: Colors.white,
                width: double.infinity,
                child: recurringExpenses.isNotEmpty ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text('Recurring costs', style: TextStyle(fontSize: 20)),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: recurringExpenses.length*90,
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: recurringExpenses.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Card(
                              elevation: 15,
                              color: Colors.grey.shade200,
                              child: ListTile(
                                  leading: Icon(Icons.radio_button_unchecked, color: recurringIconColor(index), size: 30),
                                  trailing: Text('\$ ${recurringExpenses[index]['amount']}', style:TextStyle(fontSize: 20)),
                                  title: Text('${recurringExpenses[index]['name']}', style:TextStyle(fontSize: 20)),
                                  subtitle: Text(createRecurringDate(index)),
                                  onTap: () {
                                    // TODO: check this one, not sure
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => viewExpense(userExpenses: userExpenses, currentExpenses: currentExpenses, index: index, userName: userName, trackingPeriod: userTrackingPeriod, currentBalance: balanceLeft)));

                                  }
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
                :
                null
              ),
            ),
          ],
        )
      ),
    );
  }

  Future updateUserData () async {
    // update single user data by passing user's auth_id
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    final docUser = FirebaseFirestore.instance.collection('user_data').doc(uid);
    List newArray = [{
      'name': 'Uber eats',
      'amount': 20,
      'date': DateTime.now(),
      'receipt': "",
    },
      {
        'name': 'Shopping',
        'amount': 110,
        'date': DateTime.now(),
        'receipt': "",
      },];

    // update specific fields of the document
    docUser.update({
      'expense_array': newArray,
    });

    // TODO: refetch data after updation to update UI home page as well


  }

  Color iconColor(int index) {
    if(currentExpenses[index]['type'] == 'food') return Colors.yellow;
    if(currentExpenses[index]['type'] == 'shopping') return Colors.greenAccent;
    if(currentExpenses[index]['type'] == 'furniture') return Colors.lightBlueAccent;
    if(currentExpenses[index]['type'] == 'health') return Colors.deepPurpleAccent;
    if(currentExpenses[index]['type'] == 'car') return Colors.red;
    if(currentExpenses[index]['type'] == 'rent') return Colors.deepOrangeAccent;
    if(currentExpenses[index]['type'] == 'phone') return Colors.grey;
    if(currentExpenses[index]['type'] == 'internet') return Colors.brown;
    if(currentExpenses[index]['type'] == 'grocery') return Colors.pinkAccent;
    if(currentExpenses[index]['type'] == 'entertainment') return Colors.teal;
    if(currentExpenses[index]['type'] == 'tuition') return Colors.blueGrey;
    if(currentExpenses[index]['type'] == 'taxi') return Colors.indigo;

    return Colors.black;
  }

  Color recurringIconColor(int index) {
    if(recurringExpenses[index]['type'] == 'food') return Colors.yellow;
    if(recurringExpenses[index]['type'] == 'shopping') return Colors.greenAccent;
    if(recurringExpenses[index]['type'] == 'furniture') return Colors.lightBlueAccent;
    if(recurringExpenses[index]['type'] == 'health') return Colors.deepPurpleAccent;
    if(recurringExpenses[index]['type'] == 'car') return Colors.red;
    if(recurringExpenses[index]['type'] == 'rent') return Colors.deepOrangeAccent;
    if(recurringExpenses[index]['type'] == 'phone') return Colors.grey;
    if(recurringExpenses[index]['type'] == 'internet') return Colors.brown;
    if(recurringExpenses[index]['type'] == 'grocery') return Colors.pinkAccent;
    if(recurringExpenses[index]['type'] == 'entertainment') return Colors.teal;
    if(recurringExpenses[index]['type'] == 'tuition') return Colors.blueGrey;
    if(recurringExpenses[index]['type'] == 'taxi') return Colors.black;

    return Colors.black;
  }

  num calculateBalance() {
    num temp = userBudget;
    for(var expense in currentExpenses)
      {
        temp = temp - expense['amount'];
      }

    for(var expense in recurringExpenses)
      {
        temp = temp - expense['amount'];
      }
    return temp;
  }

  String createDateFormat(int index) {
    String temp = "${DateFormat.E().format(currentExpenses[index]['date'].toDate())}, ${DateFormat.d().format(currentExpenses[index]['date'].toDate())} ${DateFormat.LLL().format(currentExpenses[index]['date'].toDate())}";
    return temp;
  }

  String createRecurringDate(int index) {
    String temp = "${DateFormat.E().format(recurringExpenses[index]['date'].toDate())}, ${DateFormat.d().format(recurringExpenses[index]['date'].toDate())} ${DateFormat.LLL().format(recurringExpenses[index]['date'].toDate())}";
    return temp;
  }

  Widget buildUser(Map expense) =>  ListTile(
    leading: CircleAvatar(child: Text('${expense['amount']}')),
    title: Text('${expense['name']}'),
    subtitle: Text('${expense['date']}'),
  );

  Future readUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    var doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
    var snapshot =  await doc.get();

    setState(() {
      userName = snapshot.data()!['name'];
      userTrackingPeriod = snapshot.data()!['tracking_period'];
      userBudget = snapshot.data()!['budget'];
      balanceLeft = snapshot.data()!['current_balance'];
      userExpenses = snapshot.data()!['expense_array'];
    });

    // sort the expenses list in descending order
    List tempList = snapshot.data()!['expense_array'];
    tempList.sort((b,a) => a['date'].compareTo(b['date']));

    setState(() {
      currentMonth = DateFormat.LLL().format(tempList[0]['date'].toDate());
      currentYear = DateFormat.y().format(tempList[0]['date'].toDate());
      currentDay = DateFormat.d().format(tempList[0]['date'].toDate());
      currentBalance = snapshot.data()!['budget'];
    });

    var tempTrackingPeriod = snapshot.data()!['tracking_period'];
    List dates = List.empty(growable: true);

    String tempMonth = DateFormat.LLL().format(tempList[0]['date'].toDate());

    if(tempTrackingPeriod == 'daily')
      {
        dates = [
          '1 $tempMonth', '2 $tempMonth', '3 $tempMonth', '4 $tempMonth',
          '5 $tempMonth', '6 $tempMonth', '7 $tempMonth', '8 $tempMonth',
          '9 $tempMonth', '10 $tempMonth', '11 $tempMonth', '12 $tempMonth',
          '13 $tempMonth', '14 $tempMonth', '15 $tempMonth', '16 $tempMonth',
          '17 $tempMonth', '18 $tempMonth', '19 $tempMonth', '20 $tempMonth',
          '21 $tempMonth', '22 $tempMonth', '23 $tempMonth', '24 $tempMonth',
          '25 $tempMonth', '26 $tempMonth', '27 $tempMonth', '28 $tempMonth',
        ];

        List numbers = [
          '1', '2', '3', '4', '5', '6', '7', '8', '9', '10','11', '12', '13', '14', '15'
          '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28',
        ];

        if(tempMonth != 'Feb')
          {
            dates.add('29 $tempMonth');
            dates.add('30 $tempMonth');
            numbers.add('29');
            numbers.add('30');

            if(tempMonth == 'Jan' || tempMonth == 'Mar' || tempMonth == 'May'
             || tempMonth == 'Jul' || tempMonth == 'Aug' || tempMonth == 'Oct'
             || tempMonth == 'Dec')
              {
                dates.add('31 $tempMonth');
                numbers.add('31');
              }
          }
        else
          {
            String tempYear = DateFormat.y().format(tempList[0]['date'].toDate());
            int year = int.parse(tempYear);
            if(year % 4 == 0)
              {
                // leap year - feb has 29 days
                dates.add('29 $tempMonth');
                numbers.add('29');
              }
          }

        setState(() {
          displayDates = dates;
          displayNumbers = numbers;
        });
      }

    num totalExpense = 0;

    if(tempTrackingPeriod == 'daily')
      {
        setState(() {
          displayList = dates;
        });

        List newList = List.empty(growable: true);
        List newRecurring = List.empty(growable: true);
        for (var expense in tempList)
        {
          if(DateFormat.d().format(expense['date'].toDate()) == currentDay
          && DateFormat.LLL().format(expense['date'].toDate()) == currentMonth
          && DateFormat.y().format(expense['date'].toDate()) == currentYear
          && expense['recurring'] == false)
            {
              newList.add(expense);
              totalExpense = totalExpense + expense['amount'];
            }

          if(expense['recurring'])
            {
              newRecurring.add(expense);
              totalExpense = totalExpense + expense['amount'];
            }
        }

        // make sure to sort the newly created expenses list for final display
        newList.sort((b,a) => a['date'].compareTo(b['date']));
        newRecurring.sort((b,a) => a['date'].compareTo(b['date']));

        int remainingBalance = snapshot.data()!['budget'] - totalExpense;

        setState(() {
          currentExpenses = newList;
          currentBalance = remainingBalance;
          recurringExpenses = newRecurring;
        });
      }
    else if(tempTrackingPeriod == 'monthly')
      {
        setState(() {
          displayList = displayMonths;
        });

        List newList = List.empty(growable: true);
        List newRecurring = List.empty(growable: true);
        for (var expense in tempList)
        {
          if(DateFormat.LLL().format(expense['date'].toDate()) == currentMonth
              && DateFormat.y().format(expense['date'].toDate()) == currentYear
              && expense['recurring'] == false)
          {
            newList.add(expense);
            totalExpense = totalExpense + expense['amount'];
          }

          if(expense['recurring'])
          {
            newRecurring.add(expense);
            totalExpense = totalExpense + expense['amount'];
          }
        }

        // make sure to sort the newly created expenses list for final display
        newList.sort((b,a) => a['date'].compareTo(b['date']));
        newRecurring.sort((b,a) => a['date'].compareTo(b['date']));

        int remainingBalance = snapshot.data()!['budget'] - totalExpense;

        setState(() {
          currentExpenses = newList;
          currentBalance = remainingBalance;
          recurringExpenses = newRecurring;
        });
      }
    else if(tempTrackingPeriod == 'yearly')
      {
        setState(() {
          displayList = displayYears;
        });

        List newList = List.empty(growable: true);
        List newRecurring = List.empty(growable: true);
        for (var expense in tempList)
        {
          if(DateFormat.y().format(expense['date'].toDate()) == currentYear
              && expense['recurring'] == false)
          {
            newList.add(expense);
            totalExpense = totalExpense + expense['amount'];
          }

          if(expense['recurring'])
          {
            newRecurring.add(expense);
            totalExpense = totalExpense + expense['amount'];
          }
        }

        // make sure to sort the newly created expenses list for final display
        newList.sort((b,a) => a['date'].compareTo(b['date']));
        newRecurring.sort((b,a) => a['date'].compareTo(b['date']));

        int remainingBalance = snapshot.data()!['budget'] - totalExpense;

        setState(() {
          currentExpenses = newList;
          currentBalance = remainingBalance;
          recurringExpenses = newRecurring;
        });
      }

  }

  void setGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      setState(() {
        greeting = "Good morning";
      });
      return;
    }
    if (hour < 17) {
      setState(() {
        greeting = "Good afternoon";
      });
      return;
    }

    setState(() {
      greeting = "Good evening";
    });
    return;
  }

  bool setColor(int index) {

    if(userTrackingPeriod == 'daily')
      {
        return currentDay == displayNumbers[index] ? true : false;
      }
    else if(userTrackingPeriod == 'monthly')
      {
        return currentMonth == displayList[index] ? true : false;
      }
    else if(userTrackingPeriod == 'yearly')
      {
        return currentYear == displayList[index] ? true : false;
      }

    return true;
  }

  void displayChange(int index) {
    if(userTrackingPeriod == 'daily')
       {
         setState(() {
           currentDay = displayNumbers[index];
         });

         List tempList = userExpenses;
         tempList.sort((b,a) => a['date'].compareTo(b['date']));

         List newList = List.empty(growable: true);
         List newRecurring = List.empty(growable: true);
         for (var expense in tempList)
         {
           if(DateFormat.d().format(expense['date'].toDate()) == currentDay
               && DateFormat.LLL().format(expense['date'].toDate()) == currentMonth
               && DateFormat.y().format(expense['date'].toDate()) == currentYear
               && expense['recurring'] == false)
           {
             newList.add(expense);
           }

           if(expense['recurring'])
           {
             newRecurring.add(expense);
           }
         }

         // make sure to sort the newly created expenses list for final display
         newList.sort((b,a) => a['date'].compareTo(b['date']));
         newRecurring.sort((b,a) => a['date'].compareTo(b['date']));

         setState(() {
           currentExpenses = newList;
           recurringExpenses = newRecurring;
         });
       }
    else if(userTrackingPeriod == 'monthly')
      {
        setState(() {
          currentMonth = displayList[index];
        });

        List tempList = userExpenses;
        tempList.sort((b,a) => a['date'].compareTo(b['date']));

        List newList = List.empty(growable: true);
        List newRecurring = List.empty(growable: true);
        for (var expense in tempList)
        {
          if(DateFormat.LLL().format(expense['date'].toDate()) == currentMonth
              && DateFormat.y().format(expense['date'].toDate()) == currentYear
              && expense['recurring'] == false)
          {
            newList.add(expense);
          }

          if(expense['recurring'])
          {
            newRecurring.add(expense);
          }
        }

        // make sure to sort the newly created expenses list for final display
        newList.sort((b,a) => a['date'].compareTo(b['date']));
        newRecurring.sort((b,a) => a['date'].compareTo(b['date']));

        setState(() {
          currentExpenses = newList;
          recurringExpenses = newRecurring;
        });
      }
    else if(userTrackingPeriod == 'yearly')
      {
        setState(() {
          currentYear = displayList[index];
        });

        List tempList = userExpenses;
        tempList.sort((b,a) => a['date'].compareTo(b['date']));

        List newList = List.empty(growable: true);
        List newRecurring = List.empty(growable: true);
        for (var expense in tempList)
        {
          if(DateFormat.y().format(expense['date'].toDate()) == currentYear
              && expense['recurring'] == false)
          {
            newList.add(expense);
          }

          if(expense['recurring'])
          {
            newRecurring.add(expense);
          }
        }

        // make sure to sort the newly created expenses list for final display
        newList.sort((b,a) => a['date'].compareTo(b['date']));
        newRecurring.sort((b,a) => a['date'].compareTo(b['date']));

        setState(() {
          currentExpenses = newList;
          recurringExpenses = newRecurring;
        });
      }
  }

}
