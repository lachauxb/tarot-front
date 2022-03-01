import 'package:flutter/material.dart';
import 'package:origin/config/theme.dart';

class EffortProgressBar extends StatelessWidget {
  final double effortTermine;
  final double sumEffort;

  EffortProgressBar({
    @required this.effortTermine,
    @required this.sumEffort,
  });

  @override
  Widget build(BuildContext context) {
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
                  sumEffort != 0 ? Container( // Contenu de la barre
                    height: 5,
                    width: constraints.maxWidth * (effortTermine / sumEffort),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      color: solutecGrey,
                    ),
                  ) : Container(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}