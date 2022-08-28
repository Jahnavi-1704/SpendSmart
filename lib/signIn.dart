import 'package:flutter/material.dart';
import 'home.dart';
import 'signUp.dart';
import 'forgotPassword.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'Utils.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.indigo.shade700,
              Colors.blue,
              Colors.indigo.shade300,
            ]
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 65),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 40),
              child: Text('Welcome back! Glad to see you. Again!', style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                            color: Color.fromRGBO(25, 37, 134, .3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )]
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                  ),
                                  child: TextFormField(
                                    controller: emailController,
                                    cursorColor: Colors.indigo,
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (email) =>
                                    email != null && !EmailValidator.validate(email)
                                        ? 'Enter a valid email'
                                        : null
                                    ,
                                  )
                              ),
                              Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  ),
                                  child: TextFormField(
                                    controller: passwordController,
                                    cursorColor: Colors.indigo,
                                    obscureText: !passwordVisible,
                                    obscuringCharacter: '●',
                                    style: TextStyle(fontSize: 18, color: Colors.black87),
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordVisible ?
                                          Icons.visibility
                                              :
                                          Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (password) =>
                                    password == null
                                        ? 'Enter a valid password'
                                        : null
                                    ,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                          child: isError ?
                          Text('$errorMessage', style: TextStyle(color: Colors.red))
                              :
                          null
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 80),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.indigo[500],
                        ),
                        child: Center(
                          child: TextButton(
                              onPressed: signIn,
                              child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                          },
                          child: Text("Forgot Password?", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline))
                      ),
                      Text("or", style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 15),
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
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                          TextButton(
                              onPressed: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                              },
                              child: Text("Sign Up", style: TextStyle(color: Colors.indigo, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  Future facebookSignIn() async {
    // sign in with facebook auth but take user to Home page
  }

}
