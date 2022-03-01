// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/Story.dart';
import 'package:origin/model/Priority.dart';
import 'package:origin/model/StoryState.dart';
import 'package:origin/model/Epic.dart';
import 'package:origin/model/Theme.dart' as model;
// ** PACKAGES ** //
import 'package:flutter/material.dart';
import 'package:origin/views/StoryActivity.dart';

class StoryViewInBacklog extends StatelessWidget {
  StoryViewInBacklog({this.story, this.width, this.vmMax});
  final Story story;
  final double width;
  final int vmMax;

  @override
  Widget build(BuildContext context) {

    StoryState storyState = StoryState.getById(story.idStoryState);
    model.Theme storyTheme = model.Theme.getById(story.idTheme);
    Epic storyEpic = Epic.getById(story.idEpic);
    Priority storyPriority = Priority.getById(story.idPriority);

    return GestureDetector(
        onTap: () => Navigator.pushNamed(
            context, OriginConstants.routeStory,
            arguments: ScreenArguments(story, vmMax, OriginConstants.backlogViewId)
        ),
        child: Container(
            margin: EdgeInsets.only(top: 6.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                stops: [0.02, 0.02],
                colors: [
                  storyState != null ? OriginConstants.storyStateToColor[storyState.number] : Colors.white,
                  Colors.white
                ]
              ),
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              boxShadow: [
                BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 2, spreadRadius: 1)
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: (width * 0.02) + 7, top: 5),
                  child: Text(
                    story.title.trimRight(), style: TextStyle(fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: solutecGrey),),
                ),
                storyTheme == null && storyEpic == null ? Container() : Padding(
                  padding: EdgeInsets.only(left: (width * 0.02) + 7, top: 5),
                  child: Text(storyTheme != null ? storyTheme.name +
                      (storyEpic != null ? (" - " + storyEpic.name) : "") : "",
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 12.0),),
                ),
                Padding(
                  padding: EdgeInsets.only(left: (width * 0.005) + 10, bottom: 8, top: 5, right: 5),
                  child: Stack(
                    alignment: Alignment(0.0, 1),
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: width * 0.13),
                            child: Text("VM: ")
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Container(
                              width: 25,
                              height: 25,
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: vmMax != 0 ? (story.vm / vmMax) : 1,
                                      valueColor: AlwaysStoppedAnimation(
                                          Color(0xFF3c4858))
                                    )
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(story.vm.toString())
                                    )
                                  )
                                ]
                              )
                            )
                          )
                        ]
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: width * 0.35, bottom: 2),
                            child: Text("Effort: " + story.effort.toInt().toString())
                          )
                        ]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: storyPriority != null ? [storyPriority.icon] : <Widget>[]
                      )
                    ]
                  )
                )
              ]
            )
        )
    );
  }
}