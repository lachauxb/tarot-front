import 'package:origin/config/auto_loader.dart';
import "package:flutter/material.dart";

class EffortCard extends StatelessWidget{
  final double effortValue;
  final Function onTap;
  final bool selected;
  EffortCard({Key key, this.effortValue, this.onTap, this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String value = effortValue != 0.5 ? effortValue.toString().split('.').first : "1/2";
    return GestureDetector(
      onTap: () => onTap(effortValue),
      child: AspectRatio(
        aspectRatio: 0.65,
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
          return Container(
            height: constraints.maxHeight,
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: selected ? [BoxShadow(color: Colors.amber[300], blurRadius: 2.5, spreadRadius: 2)]
              : [BoxShadow(color: Colors.grey[300], offset: Offset(2, 2), blurRadius: 2.5, spreadRadius: 1)],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth / 2.2,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(10.0)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: constraints.maxHeight / 6,
                    margin: EdgeInsets.only(left: 5,),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(value, style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600),),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: constraints.maxHeight / 2.3,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(value, style: TextStyle(color: solutecRed),),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: constraints.maxHeight / 6,
                    margin: EdgeInsets.only(right: 5,),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(value, style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600),),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}