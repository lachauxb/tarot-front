import 'package:flutter/material.dart';

///widget affichant un niveau de priorité
class PriorityChip extends StatelessWidget {
  final String content;
  final Color backgroundColor;
  final double horizontalPadding;

  const PriorityChip({
    @required this.content,
    @required this.backgroundColor,
    @required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        boxShadow: [BoxShadow(color: Colors.grey[300], offset: Offset(1, 1), blurRadius: 2, spreadRadius: 1)],
        border: Border.all(
          color: backgroundColor,
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: horizontalPadding),
      child: Text(content, style: TextStyle(color: Colors.white),),
    );
  }

}