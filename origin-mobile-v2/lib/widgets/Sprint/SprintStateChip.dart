import 'package:flutter/material.dart';
import 'package:origin/config/auto_loader.dart';

/// widget affichant l'état d'une Story
class SprintStateChip extends StatelessWidget {
  final int sprintState;

  const SprintStateChip({
    @required this.sprintState,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      width: OriginConstants.sprintStateChipWidth,
      height: OriginConstants.sprintStateChipHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: OriginConstants.sprintStateToColor[sprintState],
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        boxShadow: [BoxShadow(color: Colors.grey[300], offset: Offset(1, 1), blurRadius: 2, spreadRadius: 1)],
      ),
      child: Text(OriginConstants.sprintStateToText[sprintState], style: TextStyle(color: Colors.white),),
    );
  }

}