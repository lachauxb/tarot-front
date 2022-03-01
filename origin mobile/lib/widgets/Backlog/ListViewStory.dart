// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/Story.dart';
// ** PACKAGES ** //
import 'StoryViewInBacklog.dart';
import 'package:flutter/material.dart';

class ListViewStory extends StatelessWidget {

  final List<Story> stories;
  final Function _refresh;
  final int vmMax;

  ListViewStory(this.stories, this._refresh, this.vmMax);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: Scrollbar(
        child: ListView.builder(
          padding: EdgeInsets.all(5),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            return StoryViewInBacklog(story: stories[index], width: MediaQuery.of(context).size.width, vmMax: vmMax,);
          },
        ),
      ),
      onRefresh: _refresh,
    );
  }

}