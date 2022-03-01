// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Epic.dart';
import 'package:origin/model/Priority.dart';
import 'package:origin/model/Sprint.dart';
// ** MODEL ** //
import 'package:origin/model/Story.dart';
import 'package:origin/model/StoryState.dart';
import 'package:origin/model/Theme.dart' as t;
// ** PACKAGES ** //
import 'package:flutter/material.dart';
import 'package:origin/widgets/Backlog/StoryViewInBacklog.dart';

/// Gère le traitement et l'affichage des stories sous forme de groupes (dans le backlog)

class ListViewGroupStory extends StatefulWidget {
  final List<Story> stories;
  final Function refresh;
  final int vmMax;

  final GroupByID groupBy;

  ListViewGroupStory(this.stories, this.refresh, this.vmMax, this.groupBy) : assert(stories != null);

  @override
  _ListViewGroupStoryState createState() => _ListViewGroupStoryState();
}

class _ListViewGroupStoryState extends State<ListViewGroupStory> implements StateListener {

  GroupByID oldGroupBy = GroupByID.NONE;
  Map<int, StoryGroup> groups = Map<int, StoryGroup>();
  bool _isLoading = true;

  @override
  void initState() {
    StateProvider().subscribe(this);
    _buildGroups();
    super.initState();
  }

  _buildGroups() async{
    Map<int, List<Story>> mappedStories = Map<int, List<Story>>(); /// permet, en une fois, de séparer les stories en fonction du groupement demandé
    if(widget.groupBy != oldGroupBy)
      groups.clear(); // si on change de type de groupe, on reset

    // en fonction du type de groupement demandé, on traite les données en amont pour un affichage simplifié
    switch(widget.groupBy){

      case GroupByID.THEME:

        // tri des stories par thème
        widget.stories.forEach((Story story){
          if(mappedStories[story.idTheme] == null)
            mappedStories[story.idTheme] = List<Story>();
          mappedStories[story.idTheme].add(story);
        });

        // création des groupes
        t.Theme.getAll().forEach((t.Theme theme){
          if(mappedStories[theme.idTheme] != null) { // on n'affiche pas les thèmes sans story (filtre par exemple)

            groups[theme.idTheme] = StoryGroup(
              theme.name,
              mappedStories[theme.idTheme] ?? List<Story>(),
              groups.containsKey(theme.idTheme) && groups[theme.idTheme].isOpened,
              description: theme.description,
            );

          }else if(groups[theme.idTheme] != null)
            groups.remove(theme.idTheme);
        });
        // on ajoute le groupe "Sans thème"
        if(mappedStories[null] != null) {
          groups[null] = StoryGroup(
            "Sans thème",
            mappedStories[null] ?? List<Story>(),
            groups.containsKey(null) && groups[null].isOpened,
          );
        }else if(groups[null] != null)
          groups.remove(null);

        break;
      case GroupByID.EPIC:

        // tri des stories par épics
        widget.stories.forEach((Story story){
          if(mappedStories[story.idEpic] == null)
            mappedStories[story.idEpic] = List<Story>();
          mappedStories[story.idEpic].add(story);
        });

        // création des groupes
        Epic.getAll().forEach((Epic epic){
          if(mappedStories[epic.idEpic] != null) { // on n'affiche pas les épics sans story (filtre par exemple)

            groups[epic.idEpic] = StoryGroup(
              "[${t.Theme.getById(epic.idTheme).name}] ${epic.name}",
              mappedStories[epic.idEpic] ?? List<Story>(),
              groups.containsKey(epic.idEpic) && groups[epic.idEpic].isOpened,
              description: epic.description,
            );

          }else if(groups[epic.idEpic] != null)
            groups.remove(epic.idEpic);
        });
        // on ajoute le groupe "Sans épic"
        if(mappedStories[null] != null) {
          groups[null] = StoryGroup(
            "Sans épic",
            mappedStories[null] ?? List<Story>(),
            groups.containsKey(null) && groups[null].isOpened,
          );
        }else if(groups[null] != null)
          groups.remove(null);

        break;
      case GroupByID.STATE:

      // tri des stories par états
        widget.stories.forEach((Story story){
          if(mappedStories[story.idStoryState] == null)
            mappedStories[story.idStoryState] = List<Story>();
          mappedStories[story.idStoryState].add(story);
        });

        // création des groupes
        StoryState.getAll().forEach((StoryState state){
          if(mappedStories[state.number] != null) { // on n'affiche pas les états sans story (filtre par exemple)

            groups[state.number] = StoryGroup(
              state.title,
              mappedStories[state.number] ?? List<Story>(),
              groups.containsKey(state.number) && groups[state.number].isOpened,
              icon: Icon(Icons.fiber_manual_record, color: OriginConstants.storyStateToColor[state.number]),
              iconFirst: true
            );

          }else if(groups[state.number] != null)
            groups.remove(state.number);
        });

        break;
      case GroupByID.PRIORITY:

      // tri des stories par priorité
        widget.stories.forEach((Story story){
          if(mappedStories[story.idPriority] == null)
            mappedStories[story.idPriority] = List<Story>();
          mappedStories[story.idPriority].add(story);
        });

        // création des groupes
        Priority.getAll().forEach((Priority priority){
          if(mappedStories[priority.idPriority] != null) { // on n'affiche pas les priorités sans story (filtre par exemple)

            groups[priority.idPriority] = StoryGroup(
              priority.title,
              mappedStories[priority.idPriority] ?? List<Story>(),
              groups.containsKey(priority.idPriority) && groups[priority.idPriority].isOpened,
            );

          }else if(groups[priority.idPriority] != null)
            groups.remove(priority.idPriority);
        });

        break;
      case GroupByID.SPRINT:

      // tri des stories par sprints
        widget.stories.forEach((Story story){
          if(mappedStories[story.idSprint] == null)
            mappedStories[story.idSprint] = List<Story>();
          mappedStories[story.idSprint].add(story);
        });

        Project project = await ProjectService.getCurrentProject();
        List<dynamic> response = await ProjectService.getProjectSprints(project.id);
        List<Sprint> sprints = List<Sprint>();
        response.forEach((sprintFromApi) => sprints.add(Sprint.fromApi(sprintFromApi)));

        // création des groupes
        sprints.forEach((Sprint sprint){
          if(mappedStories[sprint.id] != null) { // on n'affiche pas les sprints sans story (filtre par exemple)

            groups[sprint.id] = StoryGroup(
              "Sprint ${sprint.name.split("\$").last}",
              mappedStories[sprint.id] ?? List<Story>(),
              groups.containsKey(sprint.id) && groups[sprint.id].isOpened,
              description: sprint.description,
              icon: sprint.active ? Icon(Icons.flash_on, color: Colors.amber) : null
            );

          }else if(groups[sprint.id] != null)
            groups.remove(sprint.id);
        });
        // on ajoute le groupe "Sans sprint"
        if(mappedStories[null] != null) {
          groups[null] = StoryGroup(
            "Sans sprint",
            mappedStories[null] ?? List<Story>(),
            groups.containsKey(null) && groups[null].isOpened,
          );
        }else if(groups[null] != null)
          groups.remove(null);

        break;

      default:
        break;
    }
    oldGroupBy = widget.groupBy;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading){
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(solutecRed),
        ),
      );
    }else {
      return RefreshIndicator(
        child: Scrollbar(
            child: groups.length > 0 ? ListView.builder(
              padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
              itemCount: groups.values.length,
              itemBuilder: (groupContext, groupIndex) {
                StoryGroup group = groups.values.elementAt(groupIndex);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          setState(() {group.isOpened = !group.isOpened;});
                        },
                        child: Card(
                            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                              return Row(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: constraints.maxWidth - 75,
                                          padding: EdgeInsets.only(left: 5, top: 5,),
                                          child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Wrap(
                                                children: <Widget>[
                                                  group.iconFirst && group.icon != null ? Padding(padding: EdgeInsets.only(right: 8), child: group.icon) : Container(),
                                                  Text(group.title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), overflow: TextOverflow.fade),
                                                  !group.iconFirst && group.icon != null ? Padding(padding: EdgeInsets.only(left: 8), child: group.icon) : Container()
                                                ],
                                              )
                                          ),
                                        ),
                                        group.description != null ? Container(
                                          width: constraints.maxWidth - 75,
                                          padding: EdgeInsets.only(left: 5, bottom: 5,),
                                          child: Text(group.description, overflow: TextOverflow.fade)
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Text("${group.stories.length}", style: textStyle),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(group.isOpened ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up),
                                  ),
                                ],
                              );
                            })
                        )
                    ),
                    group.isOpened ? Wrap(
                      children: group.stories.map((Story story) {
                        return StoryViewInBacklog(
                          story: story, width: MediaQuery.of(context).size.width, vmMax: widget.vmMax,);
                      }).toList(),
                    ) : Container(),
                  ],
                );
              },
            ) : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                  height: MediaQuery.of(context).size.height - Size.fromHeight(kToolbarHeight + kTextTabBarHeight).height,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text("Aucune story à afficher",
                              style: TextStyle(color: solutecGrey),),
                          ),
                        ),
                      ]
                  )
              ),
            )
        ),
        onRefresh: widget.refresh,
      );
    }
  }

  @override
  void dispose() {
    StateProvider().dispose(this);
    super.dispose();
  }

  @override
  void onStateChanged(ObserverState state) {
    if(state == ObserverState.STORYGROUP_ASK_REFRESH) {
      setState(() => _isLoading = true); // si la liste des stories a été update (par exemple filtre), on reconstruit la liste des groupes
      _buildGroups();
    }
  }

}

class StoryGroup {

  String title;
  Widget icon;
  String description;
  List<Story> stories;
  bool isOpened;
  bool iconFirst;

  StoryGroup(this.title, this.stories, this.isOpened, {this.icon, this.description, this.iconFirst = false});

}