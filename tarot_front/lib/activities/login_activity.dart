import 'package:flutter/material.dart';

/// Login page for the connection of a user
class LoginActivity extends StatefulWidget {
  const LoginActivity({Key? key}) : super(key: key);

  @override
  _LoginActivityState createState() => _LoginActivityState();
}


class _LoginActivityState extends State<LoginActivity> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tarot"),
          centerTitle: true,
        ),
        body: Container()
    );
  }

 }