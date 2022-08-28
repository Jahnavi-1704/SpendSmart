import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'indicator.dart';

class summary extends StatefulWidget {
  const summary({Key? key}) : super(key: key);

  @override
  State<summary> createState() => _summaryState();
}

class _summaryState extends State<summary> {
  List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String currentMonth = "";

  List<String> years = [
    '2019', '2020', '2021', '2022', '2023', '2024'
  ];

  String currentYear = "2022";

  num userBudget = 0;
  List userExpenses = List.empty(growable: true);
  List currentExpenses = List.empty(growable: true);
  num currentBalance = 0;

  List<FlSpot> lineDisplayList = List.empty(growable: true);
  List pieDisplayList = List.empty(growable: true);

  List displayList = List.empty(growable: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(
                  color: Colors.grey.withOpacity(0.01),
                  spreadRadius: 10,
                  blurRadius: 3,
                )],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 35, left: 20, right: 20, bottom: 5),
                child: Column(
                  children: [
                    Text('Insights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
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
                                      color: currentMonth == displayList[index] ? Colors.blue.shade900 : Colors.white
                                  ),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  displayChange(index);
                                },
                                child: Text("${displayList[index]}",
                                    style: TextStyle(
                                        color: currentMonth == displayList[index] ? Colors.blue.shade900 : Colors.grey,
                                        fontSize: 16,
                                    )
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child:
              pieDisplayList.isEmpty ?
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text("You didn't spend during this period", style: TextStyle(fontSize: 22, color: Colors.white)),
                    ),
                  )
                  :
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.01),
                    spreadRadius: 10,
                    blurRadius: 3,
                  )],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Net balance', style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5),
                            )),
                            SizedBox(height: 5),
                            Text('\$${calculateBalance()}', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            )),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 20,
                          height: 150,
                          child: LineChart(mainData()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: pieDisplayList.isEmpty ?
                  null :
              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.01),
                    spreadRadius: 10,
                    blurRadius: 3,
                  )],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 180,
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: double.infinity,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for(var entry in pieDisplayList)
                            Indicator(
                              color: setColor(entry['type']),
                              text: '${entry['name']}',
                              isSquare: true,
                            ),
                        ],
                      ),
                    ],
                  )
                ),
              ),
            ),
            Text('${lineDisplayList.length}'),

          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(pieDisplayList.length, (i) {

      double rounded = double.parse((pieDisplayList[i]['percent']).toStringAsFixed(2));

      return PieChartSectionData(
        color: setColor(pieDisplayList[i]['type']),
        value: pieDisplayList[i]['percent'],
        title: '$rounded%',
        radius: 50.0,
        titleStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );

    });
  }

  List<Color> gradientColors = [Color(0xFFFF3378)];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontSize: 12
    );
    Widget text;

    if(value == 10) {
      text = Text('\$10', style: style);
    } else if(value == 50.0) {
      text = Text('\$50', style: style);
    } else if(value == 100.0) {
      text = Text('\$100', style: style);
    } else if(value == 150.0) {
      text = Text('\$150', style: style);
    } else if(value == 200.0) {
      text = Text('\$200', style: style);
    } else if(value == 205.0) {
      text = Text('');
    } else {
      return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0.1,
      child: text,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color:  Color(0xff68737d),
      fontSize: 12,
    );
    Widget text;

    if(value == 5.0){
      text = Text('5 ${currentMonth}', style: style);
    } else if(value == 10.0) {
      text = Text('10 ${currentMonth}', style: style);
    } else if(value == 15.0) {
      text = Text('15 ${currentMonth}', style: style);
    } else if(value == 20.0) {
      text = Text('20 ${currentMonth}', style: style);
    } else if(value == 25.0) {
      text = Text('25 ${currentMonth}', style: style);
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 0.7,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 28,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          )
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border(
              left: BorderSide(width: 1.0, color: Color(0xff37434d)),
              bottom: BorderSide(width: 1.0, color: Color(0xff37434d)),
          )
      ),
      minX: 0,
      maxX: 31,
      minY: 10,
      maxY: 205,
      lineBarsData: [
        LineChartBarData(
          spots: lineDisplayList,
          isCurved: true,
          color: Colors.indigo,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
        ),
      ],
    );
  }

  num calculateBalance() {
    num temp = userBudget;
    for(var expense in currentExpenses)
    {
      temp = temp - expense['amount'];
    }

    return temp;
  }

  Color setColor(String type) {
    if(type == 'food') return Colors.yellow;
    if(type == 'shopping') return Colors.greenAccent;
    if(type == 'furniture') return Colors.lightBlueAccent;
    if(type == 'health') return Colors.deepPurpleAccent;
    if(type == 'car') return Colors.red;
    if(type == 'rent') return Colors.deepOrangeAccent;
    if(type == 'phone') return Colors.grey;
    if(type == 'internet') return Colors.brown;
    if(type == 'grocery') return Colors.pinkAccent;
    if(type == 'entertainment') return Colors.teal;
    if(type == 'tuition') return Colors.blueGrey;
    if(type == 'taxi') return Colors.indigo;

    return Colors.black;
  }

  Future fetchUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();

    var doc = FirebaseFirestore.instance.collection('user_data').doc(uid);
    var snapshot =  await doc.get();

    setState(() {
      userBudget = snapshot.data()!['budget'];
      userExpenses = snapshot.data()!['expense_array'];
    });

    // sort the expenses list in descending order
    List tempList = snapshot.data()!['expense_array'];
    var ascendingList = snapshot.data()!['expense_array'];

    tempList.sort((b,a) => a['date'].compareTo(b['date']));

    List months = ['Jan',
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
      'Dec'];

    setState(() {
      currentMonth = DateFormat.LLL().format(tempList[0]['date'].toDate());
      currentYear = DateFormat.y().format(tempList[0]['date'].toDate());
      currentBalance = snapshot.data()!['budget'];
      displayList = months;
    });

    num totalExpense = 0;

    num foodExpense = 0;
    num shoppingExpense = 0;
    num furnitureExpense = 0;
    num healthExpense = 0;
    num carExpense  = 0;
    num rentExpense = 0;
    num phoneExpense = 0;
    num internetExpense = 0;
    num groceryExpense = 0;
    num entertainmentExpense = 0;
    num tuitionExpense = 0;
    num taxiExpense = 0;

    // sort expenses by currentMonth and currentYear
    List newList = List.empty(growable: true);
    List pieTempList = List.empty(growable: true);

    String recentMonth = DateFormat.LLL().format(tempList[0]['date'].toDate());
    String recentYear = DateFormat.y().format(tempList[0]['date'].toDate());
    for (var expense in tempList)
    {
      if(DateFormat.LLL().format(expense['date'].toDate()) == recentMonth
          && DateFormat.y().format(expense['date'].toDate()) == recentYear)
      {
        newList.add(expense);
        totalExpense = totalExpense + expense['amount'];
      }
    }

    // // sort ascending list in order of date oldest to most recent
    // ascendingList.sort((a,b) => a['date'].compareTo(b['date']));

    // sort these expenses by amount in ascending order
    newList.sort((a,b) => a['amount'].compareTo(b['amount']));

    num remainingBalance = snapshot.data()!['budget'] - totalExpense;

    List<FlSpot> tempCharts = List.empty(growable: true);
    for(var expense in ascendingList) {
      tempCharts.add(FlSpot(double.parse(DateFormat.d().format(expense['date'].toDate())),double.parse(expense['amount'])));
    }

    for(var expense in newList) {
      if(expense['type'] == 'food') {
        foodExpense = foodExpense + expense['amount'];
      } else if(expense['type'] == 'shopping') {
        shoppingExpense = shoppingExpense + expense['amount'];
      } else if(expense['type'] == 'furniture') {
        furnitureExpense = furnitureExpense + expense['amount'];
      } else if(expense['type'] == 'health') {
        healthExpense = healthExpense + expense['amount'];
      } else if(expense['type'] == 'car') {
        carExpense = carExpense + expense['amount'];
      } else if(expense['type'] == 'rent') {
        rentExpense = rentExpense + expense['amount'];
      } else if(expense['type'] == 'phone') {
        phoneExpense = phoneExpense + expense['amount'];
      } else if(expense['type'] == 'internet') {
        internetExpense = internetExpense + expense['amount'];
      } else if(expense['type'] == 'grocery') {
        groceryExpense = groceryExpense + expense['amount'];
      } else if(expense['type'] == 'entertainment') {
        entertainmentExpense = entertainmentExpense + expense['amount'];
      } else if(expense['type'] == 'tuition') {
        tuitionExpense = tuitionExpense + expense['amount'];
      } else if(expense['type'] == 'taxi') {
        taxiExpense = taxiExpense + expense['amount'];
      }

    }

    if(foodExpense > 0) {
      var newObj = {
        'percent': (foodExpense/totalExpense)*100,
        'type': 'food',
        'icon': Icons.restaurant_menu,
        'name': 'Food',
      };

      pieTempList.add(newObj);
    }

    if(shoppingExpense > 0) {
      var newObj = {
        'percent': (shoppingExpense/totalExpense)*100,
        'type': 'shopping',
        'icon': Icons.shopping_bag,
        'name': 'Shopping',
      };

      pieTempList.add(newObj);
    }

    if(furnitureExpense > 0) {
      var newObj = {
        'percent': (furnitureExpense/totalExpense)*100,
        'type': 'furniture',
        'icon': Icons.chair,
        'name': 'Furniture',
      };

      pieTempList.add(newObj);
    }

    if(healthExpense > 0) {
      var newObj = {
        'percent': (healthExpense/totalExpense)*100,
        'type': 'health',
        'icon': Icons.medical_information,
        'name': 'Health',
      };

      pieTempList.add(newObj);
    }

    if(carExpense > 0) {
      var newObj = {
        'percent': (carExpense/totalExpense)*100,
        'type': 'car',
        'icon': Icons.directions_car,
        'name': 'Car',
      };

      pieTempList.add(newObj);
    }

    if(rentExpense > 0) {
      var newObj = {
        'percent': (rentExpense/totalExpense)*100,
        'type': 'rent',
        'icon': Icons.home,
        'name': 'Rent',
      };

      pieTempList.add(newObj);
    }

    if(phoneExpense > 0) {
      var newObj = {
        'percent': (phoneExpense/totalExpense)*100,
        'type': 'phone',
        'icon': Icons.phone_android,
        'name': 'Phone',
      };

      pieTempList.add(newObj);
    }

    if(internetExpense > 0) {
      var newObj = {
        'percent': (internetExpense/totalExpense)*100,
        'type': 'internet',
        'icon': Icons.wifi,
        'name': 'Internet',
      };

      pieTempList.add(newObj);
    }

    if(groceryExpense > 0) {
      var newObj = {
        'percent': (groceryExpense/totalExpense)*100,
        'type': 'grocery',
        'icon': Icons.local_grocery_store,
        'name': 'Grocery',
      };

      pieTempList.add(newObj);
    }

    if(entertainmentExpense > 0) {
      var newObj = {
        'percent': (entertainmentExpense/totalExpense)*100,
        'type': 'entertainment',
        'icon': Icons.sports_esports,
        'name': 'Entertainment',
      };

      pieTempList.add(newObj);
    }

    if(tuitionExpense > 0) {
      var newObj = {
        'percent': (tuitionExpense/totalExpense)*100,
        'type': 'tuition',
        'icon': Icons.savings,
        'name': 'Tuition',
      };

      pieTempList.add(newObj);
    }

    if(taxiExpense > 0) {
      var newObj = {
        'percent': (taxiExpense/totalExpense)*100,
        'type': 'taxi',
        'icon': Icons.local_taxi,
        'name': 'Taxi',
      };

      pieTempList.add(newObj);
    }

    setState(() {
      currentExpenses = newList;
      currentBalance = remainingBalance;
      lineDisplayList = tempCharts;
      pieDisplayList = pieTempList;
    });

  }

  Future displayChange(int index) async {
    setState(() {
      currentMonth = displayList[index];
    });

    List tempList = userExpenses;
    var ascendingList = userExpenses;
    tempList.sort((b,a) => a['date'].compareTo(b['date']));

    List newList = List.empty(growable: true);
    List pieTempList = List.empty(growable: true);

    num totalExpense = 0;

    num foodExpense = 0;
    num shoppingExpense = 0;
    num furnitureExpense = 0;
    num healthExpense = 0;
    num carExpense  = 0;
    num rentExpense = 0;
    num phoneExpense = 0;
    num internetExpense = 0;
    num groceryExpense = 0;
    num entertainmentExpense = 0;
    num tuitionExpense = 0;
    num taxiExpense = 0;

    for (var expense in tempList)
    {
      if(DateFormat.LLL().format(expense['date'].toDate()) == displayList[index]
          && DateFormat.y().format(expense['date'].toDate()) == currentYear)
      {
        newList.add(expense);
        totalExpense = totalExpense + expense['amount'];
      }
    }

    // sort these expenses by amount in ascending order
    newList.sort((a,b) => a['amount'].compareTo(b['amount']));

    num remainingBalance = userBudget - totalExpense;

    List<FlSpot> tempCharts = List.empty(growable: true);
    for(var expense in ascendingList) {
      tempCharts.add(FlSpot(double.parse(DateFormat.d().format(expense['date'].toDate())),expense['amount'].toDouble()));
    }

    for(var expense in newList) {
      if(expense['type'] == 'food') {
        foodExpense = foodExpense + expense['amount'];
      } else if(expense['type'] == 'shopping') {
        shoppingExpense = shoppingExpense + expense['amount'];
      } else if(expense['type'] == 'furniture') {
        furnitureExpense = furnitureExpense + expense['amount'];
      } else if(expense['type'] == 'health') {
        healthExpense = healthExpense + expense['amount'];
      } else if(expense['type'] == 'car') {
        carExpense = carExpense + expense['amount'];
      } else if(expense['type'] == 'rent') {
        rentExpense = rentExpense + expense['amount'];
      } else if(expense['type'] == 'phone') {
        phoneExpense = phoneExpense + expense['amount'];
      } else if(expense['type'] == 'internet') {
        internetExpense = internetExpense + expense['amount'];
      } else if(expense['type'] == 'grocery') {
        groceryExpense = groceryExpense + expense['amount'];
      } else if(expense['type'] == 'entertainment') {
        entertainmentExpense = entertainmentExpense + expense['amount'];
      } else if(expense['type'] == 'tuition') {
        tuitionExpense = tuitionExpense + expense['amount'];
      } else if(expense['type'] == 'taxi') {
        taxiExpense = taxiExpense + expense['amount'];
      }

    }

    if(foodExpense > 0) {
      var newObj = {
        'percent': (foodExpense/totalExpense)*100,
        'type': 'food',
        'icon': Icons.restaurant_menu,
        'name': 'Food',
      };

      pieTempList.add(newObj);
    }

    if(shoppingExpense > 0) {
      var newObj = {
        'percent': (shoppingExpense/totalExpense)*100,
        'type': 'shopping',
        'icon': Icons.shopping_bag,
        'name': 'Shopping',
      };

      pieTempList.add(newObj);
    }

    if(furnitureExpense > 0) {
      var newObj = {
        'percent': (furnitureExpense/totalExpense)*100,
        'type': 'furniture',
        'icon': Icons.chair,
        'name': 'Furniture',
      };

      pieTempList.add(newObj);
    }

    if(healthExpense > 0) {
      var newObj = {
        'percent': (healthExpense/totalExpense)*100,
        'type': 'health',
        'icon': Icons.medical_information,
        'name': 'Health',
      };

      pieTempList.add(newObj);
    }

    if(carExpense > 0) {
      var newObj = {
        'percent': (carExpense/totalExpense)*100,
        'type': 'car',
        'icon': Icons.directions_car,
        'name': 'Car',
      };

      pieTempList.add(newObj);
    }

    if(rentExpense > 0) {
      var newObj = {
        'percent': (rentExpense/totalExpense)*100,
        'type': 'rent',
        'icon': Icons.home,
        'name': 'Rent',
      };

      pieTempList.add(newObj);
    }

    if(phoneExpense > 0) {
      var newObj = {
        'percent': (phoneExpense/totalExpense)*100,
        'type': 'phone',
        'icon': Icons.phone_android,
        'name': 'Phone',
      };

      pieTempList.add(newObj);
    }

    if(internetExpense > 0) {
      var newObj = {
        'percent': (internetExpense/totalExpense)*100,
        'type': 'internet',
        'icon': Icons.wifi,
        'name': 'Internet',
      };

      pieTempList.add(newObj);
    }

    if(groceryExpense > 0) {
      var newObj = {
        'percent': (groceryExpense/totalExpense)*100,
        'type': 'grocery',
        'icon': Icons.local_grocery_store,
        'name': 'Grocery',
      };

      pieTempList.add(newObj);
    }

    if(entertainmentExpense > 0) {
      var newObj = {
        'percent': (entertainmentExpense/totalExpense)*100,
        'type': 'entertainment',
        'icon': Icons.sports_esports,
        'name': 'Entertainment',
      };

      pieTempList.add(newObj);
    }

    if(tuitionExpense > 0) {
      var newObj = {
        'percent': (tuitionExpense/totalExpense)*100,
        'type': 'tuition',
        'icon': Icons.savings,
        'name': 'Tuition',
      };

      pieTempList.add(newObj);
    }

    if(taxiExpense > 0) {
      var newObj = {
        'percent': (taxiExpense/totalExpense)*100,
        'type': 'taxi',
        'icon': Icons.local_taxi,
        'name': 'Taxi',
      };

      pieTempList.add(newObj);
    }

    setState(() {
      currentExpenses = newList;
      currentBalance = remainingBalance;
      lineDisplayList = tempCharts;
      pieDisplayList = pieTempList;
    });

  }

}
