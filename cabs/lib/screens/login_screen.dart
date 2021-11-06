import 'package:cabs/screens/forgot_password_screen.dart';
import 'package:cabs/screens/home_screen.dart';
import 'package:cabs/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool viewPassword = false;

  void signIn(BuildContext context) async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text))
          .user;
      if (user != null) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "";
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        errorMessage = "Provided credentials are not right";
      } else if (e.code == 'internal-error') {
        errorMessage = "There was an internal error. Try again later";
      }
      debugPrint("Firebase Error: " + e.code);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Login Page"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 150,
                      child: Image.asset("assets/images/ssn-logo.jpg"),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'LOG IN',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Email',
                      hintText: 'Enter valid email id as abc@gmail.com',
                    ),
                    validator: (String? value) {
                      if (value!.isEmpty) return "Please enter the email id";
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 0),
                  child: TextFormField(
                    controller: _passwordController,
                    validator: (String? value) {
                      if (value!.isEmpty) return "Please enter the password";
                      return null;
                    },
                    obscureText: !viewPassword,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          viewPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        splashColor: Colors.blueAccent,
                        tooltip: 'Enter secure password',
                        onPressed: () {
                          setState(() {
                            viewPassword = !viewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context)
                        .pushNamed(ForgotPasswordScreen.routeName);
                    if (result != null) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content:
                                Text("Rest password link send to your email"),
                          ),
                        );
                    }
                  },
                  child: const Text(
                    'Forgot Password',
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        signIn(context);
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 130,
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context)
                        .pushNamed(SignupPage.routeName);
                    if (result != null) {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text("Account created"),
                          ),
                        );
                    }
                  },
                  child: const Text(
                    'New User? Create Account',
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return const HomeScreen();
    }
  }
}
