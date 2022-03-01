// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/FollowTask.dart';
// ** MODEL ** //
import 'package:origin/model/Priority.dart';
// ** PACKAGES ** //
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FollowTaskViewInBacklog extends StatelessWidget{
  FollowTaskViewInBacklog({@required this.followTask, @required this.width});
  FollowTask followTask;
  double width;

  @override
  Widget build(BuildContext context) {
    Priority taskPriority = Priority.getById(followTask.priorityId);
    return Container(
        margin: EdgeInsets.only(top: 6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.02, 0.02],
            colors: [
              solutecRed,
              Colors.white
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          boxShadow: [
            BoxShadow(color: Colors.grey,
                offset: Offset(1, 1),
                blurRadius: 2,
                spreadRadius: 1)
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: (width * 0.02) + 5, top: 5),
            child: Text(followTask.title.trimRight(), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: solutecGrey))
          ),
          Container(
            padding: EdgeInsets.only(bottom: 5, right: 5),
            child: Stack(
              alignment: Alignment(0, 1),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.35),
                      child: Text("Effort: " + followTask.effort.toInt().toString())
                    )
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: taskPriority != null ? [taskPriority.icon] : <Widget>[]
                )
              ]
            )
          )
        ]
      )
    );
  }
}