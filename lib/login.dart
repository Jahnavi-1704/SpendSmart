import 'package:flutter/material.dart';
import 'reset_password.dart';
import 'signUp.dart';
import 'package:email_validator/email_validator.dart';
import 'Utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'overview.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _isObscure = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordVisible = false;
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
              SizedBox(height: 80),
              Text(
                'Welcome Back',
                style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.9), fontSize: 32, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    'New to this app?',
                    style: TextStyle(color: Color.fromRGBO(0, 51, 102, 0.5), fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                        color: Color.fromRGBO(0, 51, 102, 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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
                          password == null
                              ? 'Enter a valid password'
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
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen()));
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Color(0xFF5B5B5B), fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1,),
                ),
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.08,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), color: Color.fromRGBO(0, 51, 102, 0.9)),
                child: TextButton(
                    onPressed: signIn,
                    child: Text('Log In', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700))
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
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 70),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                child: Center(
                  child: TextButton(
                    onPressed: facebookSignIn,
                    child: Text("Facebook", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              // LoginOption(),
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    // when login button is clicked, show a loading button while firebase is authenticating the user
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator())
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print('firebase auth error while login: $e');

      setState(() {
        isError = true;
      });

      setState(() {
        errorMessage = e.message;
      });

      var utils = Utils();
      utils.showSnackBar(e.message);
    }

    // after login to firebase, hide loading dialog and navigate to Home screen of user
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Overview()));
  }

  Future facebookSignIn() async {
    // sign in with facebook auth but take user to Home page
  }
}