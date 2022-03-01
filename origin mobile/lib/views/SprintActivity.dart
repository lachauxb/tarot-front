// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:origin/core/stateListener.dart';
import 'package:origin/services/AuthenticationService.dart';
// ** SERVICES ** //
import 'package:origin/services/StoryService.dart';
// ** VIEWS ** //
// ** MODEL ** //
import 'package:origin/model/Sprint.dart';
import 'package:origin/model/Story.dart';
import 'package:origin/model/User.dart';
import 'package:origin/widgets/DropdownFloatingActionButton.dart';
import 'package:origin/widgets/Comment/CommentDialog.dart';
import 'package:origin/widgets/Sprint/SprintView.dart';
// ** WIDGETS ** //
// ** OTHERS ** //

/// Activité représentant la liste des sprints d'un projet avec la liste des US embarquées
/// ainsi que leurs tâches et données intéressantes
class SprintActivity extends StatefulWidget {
  @override
  _SprintActivityState createState() => _SprintActivityState();
}

class _SprintActivityState extends State<SprintActivity> with TickerProviderStateMixin implements StateListener {

  Project project;
  List<Sprint> sprints = List<Sprint>();
  TabController _tabController;
  Map<int, ScrollController> sprintDetailsScrollController = Map<int, ScrollController>();
  List<Key> keys = List<Key>();
  bool isLoading = true;

  bool showSearchField = false;
  bool filterByCurrentUser = false;
  bool filterByFollowTask = false;
  int selectedTri = Story.stateComparison; // default
  int triOrder = Story.sortAsc; // default
  User currentUser;

  loadDatas() async {
    ProjectService.getCurrentProject().then((project){
      this.project = project;

      var apiCalls = <Future>[
        ProjectService.getProjectSprints(project.id),
        StoryService.getAllFromProjectID(project.id),
        AuthenticationService.getUser(),
      ];

      Future.wait(apiCalls).then((List<dynamic> results){

        currentUser = results[2];

        // chargement des stories en objets
        Map<int, Story> stories = Map<int, Story>();
        if(results[1] != null)
          results[1].forEach((story){
            Story s = Story.fromApi(story);
            stories[s.id] = s;
          });

        // chargement + construction des sprints en objets
        if(results[0] != null){
          List<Sprint> listSprint = List<Sprint>();
          results[0].forEach((sprint) {
            Sprint currentSprint = Sprint.fromApi(sprint);

            sprint['userStoryList']?.forEach((story) { // Construction des stories

              Story currentStory = stories[story['storyId']]; // récupération de l'objet story avec les infos complètes (construit un peu plus haut)
              currentSprint.listStories.add(currentStory);
            });
            listSprint.add(currentSprint);
          });
          sprints = listSprint;
          sprints.sort((a, b) => b.beginningDate.compareTo(a.beginningDate));
        }
        keys.clear();
        sprints.forEach((_) {keys.add(UniqueKey());});
        if(isLoading) {

          _tabController = TabController(length: sprints.length, initialIndex: 0, vsync: this)..addListener(() { //triggered par un changement de tab
            sprintDetailsScrollController.putIfAbsent( //création d'un controller pour le nouvel onglet
                _tabController.index, () => ScrollController(initialScrollOffset: 140,));
            setState(() {});
          });
          setState(() => isLoading = false);
        }else
          setState((){});
      });
    });
  }

  @override
  void initState(){
    super.initState();
    StateProvider().subscribe(this);
    sprintDetailsScrollController[0] = ScrollController(initialScrollOffset: 140); // offset cachant le panneau d'information sur le sprint
    loadDatas();
  }

  Future<void> _refresh() async {
    sprints.clear();
    await loadDatas();
  }

  @override
  void onStateChanged(ObserverState state) {
    if(state == ObserverState.STORY_UPDATED)
      _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if(sprints.isNotEmpty) {
      Sprint sprint = sprints.elementAt(_tabController.index);
      return OriginScaffold(
          isLoading: isLoading,
          bottomTabBar: TabBar(
            tabs: tabs(),
            controller: _tabController,
            isScrollable: true,
          ),
          title: project != null ? project.name : "Chargement...",
          currentViewId: OriginConstants.sprintViewId,
          body: SprintView(keys[_tabController.index], sprint, sprintDetailsScrollController, _tabController, showSearchField, filterByCurrentUser, filterByFollowTask, currentUser),
          floatingActionButton: DropdownFloatingActionButton(
              tooltip: "Outils de tri",
              icon: Icon(OriginIcons.sliders),
              horizontalButtons: <FloatingActionButton>[
                buildButton(Text("État"), "Tri sur état", "btnState", Story.stateComparison),
                buildButton(Text("Prio."), "Tri sur priorité", "btnPrio", Story.priorityComparison),
                buildButton(Text("VM"), "Tri sur VM", "btnVM", Story.vmComparison),
                buildButton(Text("Eff."), "Tri sur effort", "btnEffort", Story.effortComparison)
              ],
              verticalButtons: <FloatingActionButton>[
                FloatingActionButton(
                  heroTag: "btnSearch",
                  backgroundColor: showSearchField ? solutecRed : Colors.red[200],
                  onPressed: () => setState(() => showSearchField = !showSearchField),
                  tooltip: "Recherche",
                  child: Icon(Icons.search),
                ),
                FloatingActionButton(
                  heroTag: "btnFilterByUser",
                  backgroundColor: filterByCurrentUser ? solutecRed : Colors.red[200],
                  onPressed: () => setState(() => filterByCurrentUser = !filterByCurrentUser),//showDialog(context: context, child: ),
                  tooltip: "Filtrer par utilisateur courrant",
                  child: Icon(Icons.person),
                ),
                FloatingActionButton(
                  heroTag: "btnFilterByFollowTask",
                  backgroundColor: filterByFollowTask ? solutecRed : Colors.red[200],
                  onPressed: () => setState(() => filterByFollowTask = !filterByFollowTask),//showDialog(context: context, child: ),
                  tooltip: "Filter les tâches de suivi",
                  child: Text("Suivi"),
                )
              ]
          ),
          appbarExtraIcon: Container(
              width: 30,
              child: Stack(
                alignment: Alignment.centerRight,
                children: <Widget>[
                  IconButton(
                    icon: Icon(sprint.comments.length > 0 ? Icons.chat_bubble : Icons.chat_bubble_outline),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => CommentDialog(item: sprint),
                    ).then((_) => setState((){})),
                    color: Colors.white,
                    padding: EdgeInsets.all(0.0),
                  ),
                  sprint.comments.length > 0 ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        height: 20,
                        width: 15,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                            color: solutecRed
                        ),
                        child: Text(sprint.comments.length < 10 ? sprint.comments.length.toString() : "9+", style: TextStyle(color: Colors.grey[300], fontSize: 10, fontWeight: FontWeight.bold))
                    ),
                  ) : Container(),
                ],
              )
          )
      );
    } else {
      return OriginScaffold(
        isLoading: isLoading,
        title: project != null ? project.name : "Chargement...",
        currentViewId: OriginConstants.sprintViewId,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text('Aucun sprint à afficher', style: TextStyle(color: solutecGrey),),
            ),
          ),
        ),
      );
    }
  }

  /* ------------------------------------------------------------------------ */

  /// construction des visuels des onglets
  List<Widget> tabs(){
    List<Widget> tabs = List<Widget>();

    sprints.forEach((Sprint sprint){
      Widget tab = LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Tab(
          child: Row(
            children: <Widget>[
              Text(sprint.name.toLowerCase().contains("sprint") ? sprint.name.split("\$").last : "Sprint ${sprint.name.split("\$").last}"),
              sprint.active ? Container(
                padding: EdgeInsets.only(left: 5.0),
                child: Icon(Icons.flash_on, color: Colors.amber),
              ) : Container(),
            ],
          ),
        );
      });

      sprint.active ? tabs.insert(0, tab) : tabs.add(tab); // un sprint en cours se place au début de la
    });

    return tabs;
  }

  /// BUTTONS LIST BUILDERS ///
  Widget buildButton(Widget content, String tooltip, String heroTag, int triId){
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: selectedTri == triId ? solutecRed : Colors.red[200], // to remove on working
      onPressed: (){
        if(selectedTri != triId){
          triOrder = Story.sortAsc;
          selectedTri = triId;
        }else if(selectedTri == triId)
          triOrder = (triOrder == Story.sortAsc ? Story.sortDesc : Story.sortAsc);
        setState(() => sprints[_tabController.index].listStories = Story.sortStoryList(sprints[_tabController.index].listStories, [selectedTri], triOrder));
      },
      tooltip: tooltip,
      child: content,
    );
  }

  @override
  void dispose(){
    super.dispose();
    _tabController.dispose();
    StateProvider().dispose(this);
    sprintDetailsScrollController.values.forEach((controller){
      controller.dispose();
    });
  }
}
