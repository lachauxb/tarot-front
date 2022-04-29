import 'package:flutter/material.dart';
import 'package:tarot_front/configurations/constants.dart';

///
class GameActivity extends StatefulWidget {
  const GameActivity({Key? key}) : super(key: key);

  @override
  _GameActivityState createState() => _GameActivityState();
}


class _GameActivityState extends State<GameActivity> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tarot"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, newGamePage),
                child: const Text('Créer une partie')
              ),
              ElevatedButton(
                onPressed: () => {},
                child: const Text('Rejoindre une partie')
              ),
              ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, statisticsPage),
                  child: const Text('Statistiques')
              ),
              ElevatedButton(
                  onPressed: () => {},
                  child: const Text('Paramètres')
              ),
            ],
          ),
        )
    );
  }
}