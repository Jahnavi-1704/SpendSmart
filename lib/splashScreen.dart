// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'onBoarding.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 30),
              Container(
                height: 400,
                width: 400,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/backgroundImage.jpg"),
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 30),
              RichText(
                  text: TextSpan(
                    text: 'Spend',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Smart',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
        // backgroundColor: Colors.red,
        nextScreen: OnBoarding(),
      splashIconSize: 900,
      duration: 2000,
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
    );
  }
}