import 'package:flutter/material.dart';
import 'package:tarot_front/activities/game_activity.dart';
import 'package:tarot_front/configurations/constants.dart';
import 'package:tarot_front/activities/home_page_activity.dart';
import 'package:tarot_front/activities/login_activity.dart';
import 'package:tarot_front/activities/new_game_activity.dart';
import 'package:tarot_front/activities/statistics_activity.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static Map<String, WidgetBuilder> routes = {
    loginPage : (BuildContext context) => const LoginActivity(),
    homePage : (BuildContext context) => const HomePageActivity(),
    newGamePage : (BuildContext context) => const NewGameActivity(),
    statisticsPage : (BuildContext context) => const StatisticsActivity(),
    gamePage : (BuildContext context) => GameActivity(users: const [])
  };

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarot',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomePageActivity(),
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

