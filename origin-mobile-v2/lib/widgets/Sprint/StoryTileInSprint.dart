// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Epic.dart';
import 'package:origin/model/Theme.dart' as t;
import 'package:origin/model/Priority.dart';
// ** MODEL ** //
import 'package:origin/model/Story.dart';
// ** PACKAGES ** //
import 'package:flutter/material.dart';
import 'package:origin/views/StoryActivity.dart';
import 'package:origin/widgets/Comment/CommentButton.dart';

import 'TaskManager.dart';

class StoryTileInSprint extends StatelessWidget {
  final Story story;
  final int vmMax;
  final bool expanded;
  StoryTileInSprint(this.story, this.vmMax, this.expanded);

  /// créer la représentation d'une story
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      return GestureDetector(
        onTap: () => Navigator.pushNamed(
            context, OriginConstants.routeStory,
            arguments: ScreenArguments(story, vmMax, OriginConstants.sprintViewId)
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: expanded ? 0 : 10.0),
                height: 7,
                width: MediaQuery.of(context).size.width * (expanded ? 1 : 0.9) - 10,
                decoration: BoxDecoration(
                  color: OriginConstants.storyStateToColor[story.idStoryState],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: expanded ? 0 : 10.0),
                padding: EdgeInsets.all(10.0),
                height: constraints.maxHeight - 7,
                width: MediaQuery.of(context).size.width * (expanded ? 1 : 0.9) - 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 3, spreadRadius: 1)], // Élévation
                ),
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: constraints.maxWidth - 35,
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              story.title,
                              overflow: TextOverflow.clip,
                              maxLines: 5,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: solutecGrey,
                              ),
                            ),
                          ),
                          CommentButton(item: story),
                        ],
                      ),
                      story.idTheme != null && story.idEpic != null ? Container(
                        width: constraints.maxWidth,
                        padding: EdgeInsets.only(bottom: 2.0),
                        child:
                        Text("${t.Theme.getById(story.idTheme)?.name} - ${Epic.getById(story.idEpic)?.name}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ): Container(),
                      //Padding
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Stack(
                          alignment: Alignment(0.0, 0.0),
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(),
                                  child: Text("VM: ", style: TextStyle(fontSize: 14, color: solutecGrey)),
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
                                            value: vmMax != 0 ? (story.vm/vmMax): 1,
                                            valueColor: AlwaysStoppedAnimation(solutecGrey),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(story.vm.toString(), style: TextStyle(color: solutecGrey)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: constraints.maxWidth * 0.3),
                                  child: Text("Effort: ${story.realEffort.toString()}/${story.effort.toString()}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: solutecGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [Priority.getById(story.idPriority).icon],
                              mainAxisAlignment: MainAxisAlignment.end,
                            ),
                          ],
                        ),
                      ),
                      TaskManager(key: UniqueKey(),story: story),
                    ],
                  );
                },),
              ),
            ],
          ),
        ),
      );
    });
  }

}