import '../homescreen/homescreenservices.dart';
import '../welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:eaziprep_app_desktop/auth/AuthService.dart';

class drawer extends StatelessWidget {
  const drawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListTile(
              leading: Icon(Icons.info),
              title: const Text('Add more Services'),
              onTap: () {
                Navigator.pushNamed(context, homescreenservices.service);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthService.clearLoginStatus();
              Navigator.pushNamed(context, welcomescreen.welcome);
            },
          ),
        ],
      ),
    );
  }
}
