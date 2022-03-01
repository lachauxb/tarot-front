import 'package:flutter/material.dart';
import 'package:origin/config/theme.dart';

class TimeProgressBar extends StatelessWidget {
  final DateTime now;
  final DateTime beginningDate;
  final DateTime endingDate;

  TimeProgressBar({
    @required this.now,
    @required this.beginningDate,
    @required this.endingDate,
  });

  @override
  Widget build(BuildContext context){
    return Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Material(
                child: Stack(
                  children: <Widget>[
                    Container( // Fond de la barre
                      height: 5,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: Colors.grey[200],
                      ),
                    ),
                    _getProgressBar(constraints)
                  ],
                ),
              );
            },
          ),
        )
    );
  }

  Widget _getProgressBar(BoxConstraints constraints){
    if(beginningDate.isBefore(now)){
      return Container( // contenu de la barre
        height: 5,
        // Rapport du temps écoulé sur le temps total en heures
        width: constraints.maxWidth * ((now.difference(this.beginningDate).inHours) / (this.endingDate.difference(this.beginningDate)).inHours),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          color: solutecGrey
        )
      );
    }else{
      return Container();
    }
  }

}