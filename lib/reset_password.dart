import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Utils.dart';
import 'package:email_validator/email_validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(height: 250),
            Text(
              'Reset Password',
              style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 32, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 5),
            Text(
              'Please enter your email address',
              style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.5), fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                cursorColor: Color.fromRGBO(0, 51, 102, 0.9),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF979797), fontSize: 18),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(0, 51, 102, 0.9)),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'Enter a valid email'
                    : null
                ,
              ),
            SizedBox(height: 40),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.08,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), color: Color.fromRGBO(0, 51, 102, 0.9)),
              child: TextButton(
                  onPressed: sendEmail,
                  child: Text('Reset Password', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700))
              ),
            ),
              SizedBox(height: 10),
              Container(
                  child: emailSent ?
                  Text('$message', style: TextStyle(color: Colors.red, fontSize: 20))
                      :
                  null
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password?',
                    style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.5), fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                        color: Color.fromRGBO(0, 51, 102, 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
      ),
    );;
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
  }
}