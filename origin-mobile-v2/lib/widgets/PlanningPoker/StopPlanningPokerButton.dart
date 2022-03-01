import 'package:origin/config/auto_loader.dart';
import "package:flutter/material.dart";

class StopPlanningPokerButton extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: (){
          // Popup de confirmation
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text("Êtes-vous sûr de vouloir mettre fin au planning poker en cours ?", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
                titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 12.0),
                contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                children: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Annuler", style: TextStyle(color: solutecRed, fontSize: 16),),
                      ),
                      SizedBox(
                        width: 170,
                        height: 50,
                        child: RaisedButton(
                            color: solutecRed,
                            onPressed: () {
                              Navigator.of(context).pop();
                              SocketIOHandler.send("updatePlanningPokerState", body: PlanningPokerState.TERMINE.toString().substring(19));
                            },
                            child: Text("Terminer", style: TextStyle(fontSize: 18))
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        color: solutecRed,
        icon: Icon(Icons.cancel),
        tooltip: "Mettre fin au PK"
    );
  }

}