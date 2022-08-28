// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals
import 'package:flutter/material.dart';
import 'gettingStartedScreen2.dart';
import 'package:lottie/lottie.dart';
import 'signIn.dart';

class GettingStartedScreen2 extends StatelessWidget {
  const GettingStartedScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Container(
          padding:EdgeInsets.only(top: 100),
          child:Stack(
            children: <Widget>[
              Positioned(
                left: 80,
                height:250,
                width: 250,
                child: Container(
                  width: 150,
                  height: 150,
                  child: Lottie.network('https://assets3.lottiefiles.com/private_files/lf30_khwfxgwr.json', width: 200, height: 200),
                ),
              ),
              Positioned(
                top: 250,
                width: 500,
                height: 500,
                child: Container(
                  padding:EdgeInsets.only(top: 30, left: 50),
                  width:150,
                  height:300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(90)),
                      border: Border.all(
                        width: 1,
                        color: Colors.indigo,
                      ),
                      color: Colors.indigo[400]
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 120),
                        child: const Text(
                          'Expense Report',
                          style: TextStyle(color: Colors.white,
                              fontSize: 30),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, right: 120, left: 10),
                        child: const Text(
                          'Review and analyze your spending trends at the end of each tracking period based on category and amount',
                          style: TextStyle(color: Colors.white54,
                              fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}