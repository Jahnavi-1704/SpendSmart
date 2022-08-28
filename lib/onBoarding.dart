// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals
import 'package:flutter/material.dart';
import 'gettingStartedScreen1.dart';
import 'gettingStartedScreen2.dart';
import 'gettingStartedScreen3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login.dart';
import 'signIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      padding: const EdgeInsets.only(bottom: 120),
      child: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() => isLastPage = index == 2);
        },
        children: [
          GettingStartedScreen1(),
          GettingStartedScreen2(),
          GettingStartedScreen3(),
        ]
      ),
    ),
    bottomSheet: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 120,
      decoration: BoxDecoration(color: Colors.indigo[400]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TextButton(
          //     onPressed: () => controller.jumpToPage(2),
          //     child: const Text('Skip', style: TextStyle(fontSize: 18, color: Colors.white54)),
          // ),
          Center(
            child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: ScrollingDotsEffect(
                  spacing: 16,
                  dotColor: Colors.grey,
                  activeDotColor: Colors.white,
                ),
              onDotClicked: (index) => controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn),
            ),
          ),
          MaterialButton(
            color: Colors.white,
            shape: const CircleBorder(),
            onPressed: () async {
              if(isLastPage) {
                // final prefs = await SharedPreferences.getInstance();
                // prefs.setBool('showSignIn', true);

                Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
              } else {
                controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Icon(Icons.arrow_forward_ios, color: Colors.indigo, size: 25),
            ),
          )
        ],
      )
    ),
  );
}
