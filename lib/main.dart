import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cbot/pages/HomePage.dart';
import 'package:cbot/pages/LoginPage.dart';
import 'package:cbot/pages/sign_up.dart';
import 'package:cbot/utils/routes.dart';
import 'package:provider/provider.dart';
import 'auth/GoogleAuth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
   const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.black,
          iconTheme: const  IconThemeData(
            color: Colors.white,
          ),
        ),
        initialRoute: MyRoutes.signupRoute,
        routes: {
          "/": (context) => const SignUpPage(),
          MyRoutes.homeRoute: (context) =>  CandleChart(),
          MyRoutes.signupRoute: (context) =>  SignUpPage(),
          MyRoutes.loginRoute: (context) => LoginPage(),
        },
      ),
    );
  }
}
