// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'onBoarding.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splash: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/saving-money-design-vector.jpg"),
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 30),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Spend Smart',
                    textStyle: const TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Agne',
                    ),
                    speed: const Duration(milliseconds: 200),
                  ),
                  TypewriterAnimatedText(
                    'Save Smart',
                    textStyle: const TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Agne',
                    ),
                    speed: const Duration(milliseconds: 200),
                  ),
                ],

                totalRepeatCount: 4,
                pause: const Duration(milliseconds: 100),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
            ],
          ),
        ),
        // backgroundColor: Colors.red,
        nextScreen: OnBoarding(),
      splashIconSize: 900,
      duration: 6500,
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.bottomToTop,
    );
  }
}