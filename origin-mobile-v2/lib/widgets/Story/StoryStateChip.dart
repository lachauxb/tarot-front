import 'package:flutter/material.dart';
import 'package:origin/config/auto_loader.dart';

/// widget affichant l'état d'une Story
class StoryStateChip extends StatelessWidget {
  final int storyState;

  const StoryStateChip({
    @required this.storyState,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      width: OriginConstants.storyStateChipWidth,
      height: OriginConstants.storyStateChipHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: OriginConstants.storyStateToColor[storyState],
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        boxShadow: [BoxShadow(color: Colors.grey[300], offset: Offset(1, 1), blurRadius: 2, spreadRadius: 1)],
      ),
      child: Text(OriginConstants.storyStateToShortText[storyState], style: TextStyle(color: Colors.white),),
    );
  }

}