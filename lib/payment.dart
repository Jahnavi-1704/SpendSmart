import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class payment extends StatefulWidget {
  const payment({Key? key}) : super(key: key);

  @override
  State<payment> createState() => _paymentState();
}

class _paymentState extends State<payment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text('Why you should upgrade to Pro?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35)),
            SizedBox(height: 20),
            Text('By this upgrade you will get all features from Basic, plus:', style: TextStyle(color: Colors.grey[600], fontSize: 20)),
            SizedBox(height: 40),
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 2, color: Colors.white),
                        color: Colors.grey[300],
                    ),
                    child: Icon(Icons.dark_mode_outlined, size: 40)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.white),
                      color: Colors.grey[300],
                    ),
                    child: Icon(Icons.bar_chart_outlined, size: 40)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Robust Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.white),
                      color: Colors.grey[300],
                    ),
                    child: Icon(Icons.tune, size: 40)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Custom Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.white),
                      color: Colors.grey[300],
                    ),
                    child: Icon(Icons.tips_and_updates_outlined, size: 40)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Advanced Integrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.white),
                      color: Colors.grey[300],
                    ),
                    child: Icon(Icons.palette_outlined, size: 40)
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('Theme Customization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                )
              ],
            ),
            SizedBox(height: 40),
            BouncingWidget(
              onPressed: () {
                // TODO: call payment function
              },
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.08,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), color: Color.fromRGBO(0, 51, 102, 0.9)),
                child: BouncingWidget(
                    onPressed: () async {
                      // TODO: call payment function
                      await initPaymentSheet(context, email: "2dhairyashah@gmail.com", amount: 9.99);
                    },
                    child: Text("Upgrade Now \$9.99", style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700))
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> initPaymentSheet(context, {required String email, required double amount}) async {
    try {
      // 1. create payment intent on the server
      final response = await http.post(
          Uri.parse(
              'https://us-central1-stripe-checkout-flutter.cloudfunctions.net/stripePaymentIntentRequest'),
          body: {
            'email': email,
            'amount': amount.toString(),
          });

      final jsonResponse = jsonDecode(response.body);
      log(jsonResponse.toString());

      //2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: jsonResponse['paymentIntent'],
          merchantDisplayName: 'Flutter Stripe Store Demo',
          customerId: jsonResponse['customer'],
          customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed!')),
      );
    } catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error from Stripe: ${e.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


}


