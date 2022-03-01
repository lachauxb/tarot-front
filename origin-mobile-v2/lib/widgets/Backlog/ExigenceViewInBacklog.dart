// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Exigence.dart';
// ** MODEL ** //
// ** PACKAGES ** //
import 'package:flutter/material.dart';

class ExigenceViewInBacklog extends StatelessWidget {
  ExigenceViewInBacklog({@required this.exigence});
  final Exigence exigence;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: solutecGrey,
      elevation: 2.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
              child: Text(exigence.description.trimRight(), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: solutecGrey))
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Priorité: " + exigence.priority.toString()),
                Text(exigence.type),
              ],
            ),
          ),
        ],
      ),
    );
  }
}