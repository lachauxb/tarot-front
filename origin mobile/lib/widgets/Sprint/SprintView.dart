// ** AUTO LOADER ** //
import 'package:intl/intl.dart';
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/FollowTask.dart';
import 'package:origin/model/Sprint.dart';
import 'package:origin/model/Story.dart';
import 'package:origin/model/User.dart';
// ** PACKAGES ** //
import 'package:flutter/material.dart';
// ** Widgets ** //
import 'package:origin/widgets/Sprint/StoryTileInSprint.dart';
import 'package:origin/widgets/SearchBar.dart';
import 'SprintStateChip.dart';
import 'TaskManager.dart';

// ignore: must_be_immutable
class SprintView extends StatefulWidget {
  final Sprint sprint;
  final TabController tabController;
  final Map<int, ScrollController> sprintDetailsScrollController;
  bool showSearchBar;
  bool filterByCurrentUser;
  bool filterByFollowTask;
  User currentUser;

  SprintView(Key key, this.sprint, this.sprintDetailsScrollController,
      this.tabController, this.showSearchBar, this.filterByCurrentUser, this.filterByFollowTask, this.currentUser): super(key: key);

  _SprintViewState createState() => _SprintViewState();
}

class _SprintViewState extends State<SprintView> {
  List<Story> storiesToShow;
  List<Story> filteredStoriesToShow;

  @override
  void initState() {
    super.initState();
    storiesToShow = widget.sprint.listStories;
    filteredStoriesToShow = List<Story>();
  }

  /// crée la liste horizontale contenant les Story
  @override
  Widget build(BuildContext context) {
    filteredStoriesToShow.clear();
    List<Widget> storyTiles = List<Widget>();
    if(!(widget.filterByFollowTask)) {
      storiesToShow.forEach((story) {
        if(!(widget.filterByCurrentUser && !(story.users.contains(widget.currentUser)))) {
          filteredStoriesToShow.add(story);
        }
      });
    }

    if(filteredStoriesToShow.length == 1 && !(widget.filterByFollowTask)){
      storyTiles.add(StoryTileInSprint(filteredStoriesToShow.first,
          widget.sprint.listStories.length > 0 ? (widget.sprint.listStories
              .length >= 2 ? widget.sprint.listStories
              .reduce((Story s1, Story s2) => s1.vm > s2.vm ? s1 : s2)
              .vm : widget.sprint.listStories.first.vm) : 0, true));
    } else {
      filteredStoriesToShow.forEach((story){
        storyTiles.add(StoryTileInSprint(story,
            widget.sprint.listStories.length > 0 ? (widget.sprint.listStories
                .length >= 2 ? widget.sprint.listStories
                .reduce((Story s1, Story s2) => s1.vm > s2.vm ? s1 : s2)
                .vm : widget.sprint.listStories.first.vm) : 0, false));
      });
    }

    if(widget.sprint.followTasks.isNotEmpty){
      double effortFT = 0;
      double realEffortFT = 0;
      widget.sprint.followTasks.forEach((FollowTask task){
        effortFT = effortFT + task.effort;
        if(task.taskState == 5)
          realEffortFT = realEffortFT + task.effort;
      });
      storyTiles.add(LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 7,
              width: MediaQuery.of(context).size.width * (filteredStoriesToShow.isEmpty ? 1 : 0.9) - 10,
              decoration: BoxDecoration(
                color: solutecRed,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0)),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              height: constraints.maxHeight - 7,
              width: MediaQuery.of(context).size.width * (filteredStoriesToShow.isEmpty ? 1 : 0.9) - 10,
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
                    Text("Tâches de suivi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: solutecGrey,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Text("Effort: $realEffortFT/$effortFT",
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    TaskManager(key: UniqueKey(), followTasks: widget.sprint.followTasks,),
                  ],
                );
              },),
            ),
          ],
        );
      },));
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification){
          if(scrollNotification is ScrollEndNotification && //détecte la fin d'un scroll vertical (dévoilant le panneau d'information du sprint)
              widget.sprintDetailsScrollController[widget.tabController.index].offset != widget.sprintDetailsScrollController[widget.tabController.index].initialScrollOffset){
            Future.delayed(Duration(milliseconds: 1)).then((value){ // délai pour laisser le scroll en cours se terminer
              widget.sprintDetailsScrollController[widget.tabController.index].animateTo( //fermeture automatique du panneau
                  widget.sprintDetailsScrollController[widget.tabController.index].initialScrollOffset, duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuart);
            });
          }
          return false;
        },
        child: ListView(
          controller: widget.sprintDetailsScrollController[widget.tabController.index],
          children: <Widget> [
            Material(
              elevation: 5.0,
              child: Container(
                padding: EdgeInsets.all(5.0),
                width: MediaQuery.of(context).size.width,
                height: widget.sprintDetailsScrollController[widget.tabController.index].initialScrollOffset,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        widget.sprint.description != "" ?
                        Text(widget.sprint.description, maxLines: 1,
                          style: TextStyle(fontSize: 18, color: solutecGrey, ),)
                            : Text("Aucune description", style: TextStyle(fontSize: 18, color: Colors.grey[400]),),
                        Text('${DateFormat('dd MMM yyyy', 'fr_FR').format(widget.sprint.beginningDate)} - ${DateFormat('dd MMM yyyy', 'fr_FR').format(widget.sprint.endingDate)}',
                          style: TextStyle(color: solutecGrey),),
                      ],
                    ),
                    SprintStateChip(sprintState: widget.sprint.state,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(),
                        DefaultTextStyle(
                          style: TextStyle(color: Colors.grey[400]),
                          child: Row(
                            children: <Widget>[
                              Text('VM: ${widget.sprint.realBusinessValue}/${widget.sprint.sumBusinessValue}'),
                              SizedBox.fromSize(size: Size(20.0, 0.0),),
                              Text('Effort: ${widget.sprint.realEffort}/${widget.sprint.sumEffort}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            widget.showSearchBar ? SearchBar<Story>(
              label: "Rechercher une story",
              hint: "Je peux...",
              listOfValues: widget.sprint.listStories,
              onChanged: (String query, List<Story> filteredList){
                setState(() {
                  storiesToShow = filteredList;
                });
                //WidgetsBinding.instance.addPostFrameCallback((_) => StateProvider().notify(ObserverState.STORYGROUP_ASK_REFRESH)); // permet de notifier une fois le build fini pour que les infos soient transmises
              },
            ) : Container(),
            storyTiles.isNotEmpty ? Container(
                width: MediaQuery.of(context).size.width,
                height: constraints.maxHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(5.0),
                  children: storyTiles,
                )) : Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: constraints.maxHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text('Aucune story à afficher',
                    style: TextStyle(
                        color: solutecGrey
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

}