import 'package:flutter/material.dart';
import 'package:tarot_front/models/game.dart';
import 'package:tarot_front/models/user.dart';


/// Widget for game page (score of all players)
class GameActivity extends StatefulWidget {
  List<User> users;
  GameActivity({Key? key, required this.users}) : super(key: key);

  @override
  _GameActivityState createState() => _GameActivityState();
}


class _GameActivityState extends State<GameActivity> {

  late Game game;
  late List<TableRow> tableRows;

  @override
  void initState(){
    //loadData();
    super.initState();
  }

  void loadData() async {
    //game = null;

    TableRow tableRow = TableRow(
      children: [
        Text(widget.users[0].username),
        Text(widget.users[1].username),
        Text(widget.users[2].username),
        Text(widget.users[3].username),
        Text(widget.users[4].username)
      ]
    );
    tableRows.add(tableRow);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarot"),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Table(
            children: [
              TableRow(
                children: [
                  Text(widget.users[0].username),
                  Text(widget.users[1].username),
                  Text(widget.users[2].username),
                  Text(widget.users[3].username),
                  Text(widget.users[4].username)
                ]
              )
            ]
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Table(
              children: [],
            ),
          )
        ],
      )
    );
  }

}