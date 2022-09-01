import 'package:flutter/material.dart';
import 'login.dart';
import 'introduction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'Utils.dart';
import 'package:bouncing_widget/bouncing_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final reTypePasswordController = TextEditingController();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  final formKey = GlobalKey<FormState>();
  bool isError = false;
  var errorMessage = null;
  bool buttonDisabled = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Text(
                'Create Account',
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 32, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    'Already a member?',
                    style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.5), fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 5),
                  BouncingWidget(
                    onPressed: () {
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
              SizedBox(height: 10),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
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
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
                        controller: passwordController,
                        cursorColor: Color.fromRGBO(0, 51, 102, 0.9),
                        obscureText: !passwordVisible,
                        obscuringCharacter: '●',
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Color(0xFF979797), fontSize: 18),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(0, 51, 102, 0.9)),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                              icon: Icon(
                                passwordVisible ?
                                Icons.visibility
                                    :
                                Icons.visibility_off,
                              ),
                              color: passwordVisible ?
                              Color.fromRGBO(0, 51, 102, 0.9)
                                  :
                              Color(0xFF979797)
                              ,
                            )
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (password) =>
                        password != null && password.length < 8
                            ? 'Password should be min. 8 characters'
                            : null
                        ,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: TextFormField(
                        cursorColor: Color.fromRGBO(0, 51, 102, 0.9),
                        obscureText: !confirmPasswordVisible,
                        obscuringCharacter: '●',
                        decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(color: Color(0xFF979797), fontSize: 18),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(0, 51, 102, 0.9)),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  confirmPasswordVisible = !confirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                confirmPasswordVisible ?
                                Icons.visibility
                                    :
                                Icons.visibility_off,
                              ),
                              color: confirmPasswordVisible ?
                              Color.fromRGBO(0, 51, 102, 0.9)
                                  :
                              Color(0xFF979797)
                              ,
                            )
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (confirmPassword) =>
                        confirmPassword != passwordController.text
                            ? 'Passwords do not match'
                            : null
                        ,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                  child: isError ?
                  Text('$errorMessage', style: TextStyle(color: Colors.red, fontSize: 18))
                      :
                  null
              ),
              SizedBox(height: 10),
              BouncingWidget(
                onPressed: register,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16), color: Color.fromRGBO(0, 51, 102, 0.9)),
                  child: BouncingWidget(
                      onPressed: register,
                      child: Text('Sign Up', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700))
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                    'or continue with social media',
                    style: TextStyle(color: Color(0xFF5B5B5B), fontSize: 18)
                ),
              ),
              SizedBox(height: 20),
              BouncingWidget(
                onPressed: facebookSignIn,
                child: Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 70),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: BouncingWidget(
                        onPressed: facebookSignIn,
                        child: Text("Facebook", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future register() async {
    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    // when register button is clicked, show a loading button while firebase is registering the new account
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print('firebase auth error while signUp: $e');

      setState(() {
        isError = true;
      });

      setState(() {
        errorMessage = e.message;
      });

      var utils = Utils();
      utils.showSnackBar(e.message);
    }

    // after signing up, hide loading dialog and navigate to Name screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Introduction()));
  }

  Future facebookSignIn() async {
    // sign in with facebook auth but take user to Introduction page
  }
}