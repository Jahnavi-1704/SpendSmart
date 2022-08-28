import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'overview.dart';

class viewExpense extends StatefulWidget {
  const viewExpense({Key? key, required this.userExpenses, required this.currentExpenses, required this.index}) : super(key: key);
  final List userExpenses;
  final List currentExpenses;
  final int index;

  @override
  State<viewExpense> createState() => _viewExpenseState();
}

class _viewExpenseState extends State<viewExpense> {
  String? nameForUpdate;
  TextEditingController? nameController;
  TextEditingController? amountController;
  bool recurring = false;
  String type = "";
  File? receipt;
  bool receiptUploaded = false;
  DateTime? pickedDate;
  bool datePicked = true;

  List iconTypes = [
    {
      'type': 'food',
      'icon': Icons.restaurant_menu,
      'name': 'Food',
    },
    {
      'type': 'shopping',
      'icon': Icons.shopping_bag,
      'name': 'Shopping',
    },
    {
      'type': 'furniture',
      'icon': Icons.chair,
      'name': 'Furniture',
    },
    {
      'type': 'health',
      'icon': Icons.medical_information,
      'name': 'Health',
    },
    {
      'type': 'car',
      'icon': Icons.directions_car,
      'name': 'Car',
    },
    {
      'type': 'rent',
      'icon': Icons.home,
      'name': 'Rent',
    },
    {
      'type': 'phone',
      'icon': Icons.phone_android,
      'name': 'Phone',
    },
    {
      'type': 'internet',
      'icon': Icons.wifi,
      'name': 'Internet',
    },
    {
      'type': 'grocery',
      'icon': Icons.local_grocery_store,
      'name': 'Grocery',
    },
    {
      'type': 'entertainment',
      'icon': Icons.sports_esports,
      'name': 'Entertainment',
    },
    {
      'type': 'tuition',
      'icon': Icons.savings,
      'name': 'Tuition',
    },
    {
      'type': 'taxi',
      'icon': Icons.local_taxi,
      'name': 'Taxi',
    }
  ];

  @override
  void initState() {
    super.initState();

    nameForUpdate = widget.currentExpenses[widget.index]['name'];
    nameController = TextEditingController(text: '${widget.currentExpenses[widget.index]['name']}');
    amountController = TextEditingController(text: '${widget.currentExpenses[widget.index]['amount']}');
    recurring = widget.currentExpenses[widget.index]['recurring'];
    type = widget.currentExpenses[widget.index]['type'];
    pickedDate = widget.currentExpenses[widget.index]['date'].toDate();

    if(widget.currentExpenses[widget.index]['receipt'].isNotEmpty)
      {
        receiptUploaded = true;
        receipt = widget.currentExpenses[widget.index]['receipt'];
      }

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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios),
                      ),
                      Text('View', style: TextStyle(fontSize: 25)),
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
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(right: 300.0),
                  child: Text('Name', style: TextStyle(fontSize: 18)),
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 290.0),
                  child: Text('Amount', style: TextStyle(fontSize: 18)),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: pickedDate!,
                      firstDate: DateTime(2001),
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
                  child: Text(datePicked ? styleDate() : 'Pick a date', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 300.0),
                  child: Text('Type', style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: iconTypes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: iconTypes[index]['type'] == type ? setColor(iconTypes[index]['type']) : Colors.white,
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  type = iconTypes[index]['type'];
                                });
                              },
                              icon: Icon(iconTypes[index]['icon']),
                              color: Colors.black,
                              iconSize: 30,
                            ),
                            Text('${iconTypes[index]['name']}', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Checkbox(
                        value: recurring,
                        onChanged: (bool? value) {
                          recurring = !recurring;
                        }
                    ),
                    Text('Recurring', style: TextStyle(fontSize: 20.0)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 140.0),
                  child: TextButton(
                    onPressed: pickImage,
                    child: Text(
                      "+ Click to add receipt",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 5),
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
            ),
          ),

        ],
      ),
    );
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
    tempArray = [...widget.userExpenses];

    // first from tempArray find and delete the expense which matches the name as nameController.text
    // then add the updated expense to list
    tempArray.removeWhere((expense) => expense['name'] == nameForUpdate);

    final updatedExpense = {
      'name': nameController!.text,
      'amount': int.parse(amountController!.text),
      'date': datePicked ?  pickedDate : DateTime.now(),
      'recurring': recurring,
      'receipt': receiptUploaded ? receipt : "",
      'type': type,
    };
    tempArray.add(updatedExpense);

    // update specific fields of the document
    docUser.update({
      'expense_array': tempArray,
    });

    // after updating fireStore, hide loading dialog and navigate back to Home screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));
  }

  Future deleteDB() async{
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
    tempArray = [...widget.userExpenses];

    // delete the expense from list
    tempArray.removeWhere((expense) => expense['name'] == nameForUpdate);

    // update specific fields of the document
    docUser.update({
      'expense_array': tempArray,
    });

    // after updating fireStore, hide loading dialog and navigate back to Home screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));
  }

  String styleDate() {
    String temp = "${DateFormat.E().format(pickedDate!)}, ${DateFormat.d().format(pickedDate!)} ${DateFormat.LLL().format(pickedDate!)}";
    return temp;
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        receipt = imageTemporary;
        receiptUploaded = true;
      });

    } on PlatformException catch (e) {
      print('Failed to pick image from gallery: $e');
    }

  }

}
