import 'package:flutter/material.dart';
import 'package:tarot_front/configurations/constants.dart';
import 'activities/game_activity.dart';
import 'activities/login_activity.dart';
import 'activities/new_game_activity.dart';
import 'activities/statistics_activity.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static Map<String, WidgetBuilder> routes = {
    loginPage : (BuildContext context) => const LoginActivity(),
    gamePage : (BuildContext context) => const GameActivity(),
    newGamePage : (BuildContext context) => const NewGameActivity(),
    statisticsPage : (BuildContext context) => const StatisticsActivity()
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarot',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const GameActivity(),
      routes: routes,
    );
  }
}

