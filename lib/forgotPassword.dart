import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Utils.dart';
import 'signIn.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  bool emailSent = false;
  final message = 'Password reset email sent!';

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 900,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 20,
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 40),
              child: Text("Forgot Password?", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 40),
              child: Text("Don't worry, We've got you covered", style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 40),
              child: Text("Enter the email address associated with your account", style: TextStyle(color: Colors.black, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 18, right: 20),
              child: TextFormField(
                controller: emailController,
                cursorColor: Colors.indigo,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 60,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.indigo[500],
              ),
              child: Center(
                child: TextButton(
                  onPressed: sendEmail,
                  child: Text("Send mail", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
                child: emailSent ?
                Text('$message', style: TextStyle(color: Colors.red, fontSize: 20))
                    :
                null
            ),
          ],
        ),
      ),
    );
  }

  Future sendEmail() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim()
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print('firebase auth error while reset password: $e');

      var utils = Utils();
      utils.showSnackBar(e.message);
    }

    setState(() {
      emailSent = true;
    });

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
  }

}


