import 'package:flutter/material.dart';
import 'budget.dart';
import 'screenTransition.dart';
import 'dart:io';

class TrackBy extends StatefulWidget {
  const TrackBy({Key? key, required this.name, required this.picture}) : super(key: key);
  final String name;
  final File? picture;

  @override
  State<TrackBy> createState() => _TrackByState();
}

class _TrackByState extends State<TrackBy> {
  int tracking_period = 0;
  bool isDaily = false;
  bool isMonthly = false;
  bool isYearly = false;

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
                'Hang tight, we are almost done!',
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.6), fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 60),
            Center(
              child: Text(
                "Track my expenses on",
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(),
                  color: isDaily? Color.fromRGBO(0, 51, 102, 0.9) : Colors.white
              ),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      tracking_period = 1;
                      isDaily = true;
                      isMonthly = false;
                      isYearly = false;
                    });
                  },
                  child: Text('Daily basis',
                      style: TextStyle(
                          color: isDaily? Colors.white : Color.fromRGBO(0, 51, 102, 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w700
                      ))
              ),
            ),
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(),
                  color: isMonthly? Color.fromRGBO(0, 51, 102, 0.9) : Colors.white
              ),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      tracking_period = 2;
                      isMonthly = true;
                      isDaily = false;
                      isYearly = false;
                    });
                  },
                  child: Text('Monthly basis',
                      style: TextStyle(
                          color: isMonthly? Colors.white : Color.fromRGBO(0, 51, 102, 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w700
                      ))
              ),
            ),
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(),
                  color: isYearly? Color.fromRGBO(0, 51, 102, 0.9) : Colors.white
              ),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      tracking_period = 3;
                      isYearly = true;
                      isMonthly = false;
                      isDaily = false;
                    });
                  },
                  child: Text('Yearly basis',
                      style: TextStyle(
                          color: isYearly? Colors.white : Color.fromRGBO(0, 51, 102, 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w700
                      ))
              ),
            ),
            SizedBox(height: 30),
            MaterialButton(
              color: Color.fromRGBO(0, 51, 102, 0.9),
              shape: const CircleBorder(),
              onPressed: () {
                // function which passes all prev arguments and tracking period to Budget screen

                Navigator.push(context, screenTransition(page: Budget(name: widget.name, picture: widget.picture, tracking_period: tracking_period)));
              },
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
}
