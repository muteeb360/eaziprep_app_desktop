import 'package:eaziprep_app_desktop/homescreen/homescreenservices.dart';
import 'package:eaziprep_app_desktop/helpers/test.dart';
import 'package:eaziprep_app_desktop/inventory/inventory.dart';
import 'package:eaziprep_app_desktop/inventory/inventoryProduct.dart';
import 'addorders/addorder.dart';
import 'addorders/addorder2.dart';
import 'welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'helpers/firebase_options.dart';
import 'homescreen/homescreen.dart';
import 'auth/logIn.dart';
import 'services.dart';
import 'auth/signup.dart';
import 'splashScreen.dart';
import 'inventory/inventoryProduct2.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web
  );
  runApp(const Eaziprep());
}

class Eaziprep extends StatelessWidget {
  const Eaziprep({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eazi Prep',
      home: splashScreen(), // Initial screen where you check login status
      routes: {
        test.test1: (context) => const test(),
        welcomescreen.welcome: (context) => const welcomescreen(),
        services.service: (context) => const services(),
        login.signin: (context) => const login(),
        addorder.add: (context) => const addorder(),
        addorder2.addordertwo: (context) => const addorder2(),
        signup.register: (context) => const signup(),
        homescreen.home: (context) => const homescreen(),
        homescreenservices.service: (context) => const homescreenservices(),
        inventory.userinventory: (context) => const inventory(),
        inventoryProduct.addinventory: (context) => const inventoryProduct(),
        inventoryProduct2.userinventoryproduct2: (context) => const inventoryProduct2(),
      },
    );
  }
}