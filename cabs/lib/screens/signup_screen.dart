import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _database = FirebaseFirestore.instance;

class SignupPage extends StatefulWidget {
  static const routeName = "/signup";
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isLoading = false;

  final Location _location = Location();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String designation = 'Faculty';
  bool viewPassword = false;
  bool viewConfirmPassword = false;
  bool success = true;

  Future<void> addUser() async {
    LocationData currentLocation = await _location.getLocation();
    return _database.collection('users').doc(_emailController.text).set({
      'phoneNumber': _phoneNumberController.text,
      'Full Name': _fullNameController.text,
      'lat': currentLocation.latitude,
      'long': currentLocation.longitude,
      'targets': [],
      'designation': designation,
    }).catchError((error) {
      success = false;
    });
  }

  void register(BuildContext context) async {
    setState(() {
      _isLoading = !_isLoading;
    });
    String errorMessage = "";
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        final User? user = (await _auth.createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text))
            .user;
        if (user != null) {
          await addUser();
          if (success) {
            Navigator.of(context).pop("success");
          } else {
            errorMessage = "Account could not be added";
          }
        } else {
          errorMessage = "Account could not be created";
        }
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
      } on FirebaseAuthException catch (error) {
        debugPrint("Firebase Error: " + error.code);
        switch (error.code) {
          case 'email-already-in-use':
            errorMessage = "Account with this email already exists";
            break;
          case 'internal-error':
            errorMessage = "An error occured internally. Try again later";
            break;
        }
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
      }
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text("Password and confirm password do not match"),
          ),
        );
    }
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("Sign-Up"),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
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
                            'Sign Up',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Please enter the email";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              hintText: 'Enter valid email id as abc@gmail.com',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            controller: _fullNameController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Please enter the full name";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Full Name',
                              hintText: 'Enter Full Name',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Mobile number',
                              hintText: 'Enter valid Mobile Number',
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Please enter the mobile number";
                              } else if (value.length != 10) {
                                return "Mobile number should be 10 digits";
                              } else if (value.contains(RegExp(r'\D'))) {
                                return 'Please enter a valid mobile number';
                              }
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
                              if (value!.isEmpty) {
                                return "Please enter the password";
                              }
                              return null;
                            },
                            obscureText: !viewPassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(viewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
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
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "Please re-enter the password";
                              }
                              return null;
                            },
                            obscureText: !viewConfirmPassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Repeat Password',
                              suffixIcon: IconButton(
                                icon: Icon(viewConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                splashColor: Colors.blueAccent,
                                tooltip: 'Enter secure password',
                                onPressed: () {
                                  setState(() {
                                    viewConfirmPassword = !viewConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15, bottom: 0),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                isExpanded: true,
                                value: designation,
                                icon: const Icon(Icons.arrow_drop_down),
                                onChanged: (String? newDesignation) {
                                  setState(() {
                                    designation = newDesignation!;
                                  });
                                },
                                items: <String>[
                                  'Faculty',
                                  'Driver'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
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
                                  register(context);
                                }
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 130,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
