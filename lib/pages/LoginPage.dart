import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cbot/utils/routes.dart';
import 'package:cbot/auth/GoogleAuth.dart';
import 'package:provider/provider.dart';

import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  String name = "User";
  String password = 'password';
  bool changeButton = false;
  bool isBtnPressed = false;
  bool isPassHidden = true;

  final _formKey = GlobalKey<FormState>();

  moveToHome(BuildContext context) async {
    if ((_formKey.currentState!.validate()) && (isBtnPressed == true)) {
      setState(() {
        changeButton = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      await Navigator.pushNamed(context, MyRoutes.homeRoute);
      setState(() {
        changeButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Image.asset(
                  "assets/images/log_in.png",
                  fit: BoxFit.cover,
                ),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F3D56),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter username",
                          labelText: "Username",
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF673AB7),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF673AB7),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username cannot be empty";
                          }

                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            name = value.trim();
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          obscureText: isPassHidden,
                          decoration: InputDecoration(
                            hintText: "Enter password",
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF673AB7),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF673AB7),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPassHidden = !isPassHidden;
                                });
                              },
                              icon: isPassHidden == true
                                  ? const Icon(
                                      Icons.visibility,
                                      color: Color(0xFF673AB7),
                                    )
                                  : const Icon(
                                      Icons.visibility_off,
                                      color: Color(0xFF3F3D56),
                                    ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password cannot be empty";
                            } else if (value.length < 6) {
                              return "Password length should be atleast 6";
                            }

                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              password = value.trim();
                            });
                          }),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isBtnPressed = !isBtnPressed;
                              });
                            },
                            icon: isBtnPressed == true
                                ? const Icon(
                                    Icons.check_box,
                                    color: Color(0xFF673AB7),
                                  )
                                : const Icon(
                                    Icons.check_box_outline_blank,
                                    color: Color(0xFF3F3D56),
                                  ),
                          ),
                          const Text(
                            "Remember Me",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F3D56),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Material(
                              color: const Color(0xFF673AB7),
                              borderRadius: BorderRadius.circular(
                                  changeButton ? 50 : 100),
                              child: InkWell(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: changeButton ? 50 : 300,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: changeButton
                                      ? const Icon(
                                          Icons.done,
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                ),
                                onTap: () {
                                  auth.signInWithEmailAndPassword(
                                      email: name, password: password);

                                  final provider =
                                      Provider.of<GoogleSignInProvider>(context,
                                          listen: false);
                                  provider.googleLogin();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CandleChart(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Image.asset('assets/images/google.png'),
                            iconSize: 50,
                            onPressed: () {
                              final provider =
                                  Provider.of<GoogleSignInProvider>(context,
                                      listen: false);
                              provider.googleLogin();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CandleChart(),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Not registered yet?",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F3D56),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, MyRoutes.signupRoute);
                            },
                            child: Text(
                              "Create an Account",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF673AB7).withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
