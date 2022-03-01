// ** AUTO LOADER ** //
import 'dart:async';

import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Actor.dart';
import 'package:origin/model/Epic.dart';
import 'package:origin/model/StoryState.dart';
import 'package:origin/model/Theme.dart' as t;
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/services/StoryService.dart';
// ** MODEL ** //
import 'package:origin/model/Exigence.dart';
import 'package:origin/model/FollowTask.dart';
import 'package:origin/model/Story.dart';
import 'package:origin/services/UserService.dart';
import 'package:origin/widgets/DropdownFloatingActionButton.dart';
import 'package:origin/widgets/Backlog/ExigenceViewInBacklog.dart';
import 'package:origin/widgets/Backlog/FollowTaskViewInBacklog.dart';
import 'package:origin/widgets/Backlog/ListViewGroupStory.dart';
import 'package:origin/widgets/Backlog/ListViewStory.dart';
// ** OTHERS ** //

class BacklogActivity extends StatefulWidget {
  @override
  BacklogActivityState createState() => BacklogActivityState();
}

class BacklogActivityState extends State<BacklogActivity> with SingleTickerProviderStateMixin { // TickerProvider nécessaire pour l'utilisation des tab

  Project project;
  User currentUser;

  TabController _tabController;

  List<Story> stories = List<Story>(); // correspond à l'ensemble des stories connues sur l'appli
  List<Story> listeTriee = List<Story>();
  List<Story> storiesToShow = List<Story>(); // correspond aux US affichées sur l'écran
  List<dynamic> followTasks;
  List<dynamic> exigences;

  bool isLoading = true;
  bool showSearchField = false;
  bool searchInProgress = false;
  int selectedTri = Story.stateComparison; // default
  int triOrder = Story.sortAsc; // default
  int vmMax = 0;
  String lastQuery = "";

  List<t.Theme> themes;
  List<t.Theme> selectedThemes = List<t.Theme>();
  List<Epic> epics;
  List<Epic> epicsToShow = List<Epic>();
  List<Epic> selectedEpics = List<Epic>();
  List<Actor> actors;
  List<Actor> selectedActors = List<Actor>();
  List<StoryState> states;
  List<StoryState> selectedStates = List<StoryState>();

  GroupByID _groupedBy = GroupByID.NONE;
  StreamSubscription _connectionChangeStream;
  bool hasConnection = false;

  loadDatas() async {
    ProjectService.getCurrentProject().then((project){
      this.project = project;
      var apiCalls = <Future>[
        t.Theme.loadProjectThemesList(project.id),
        Actor.loadProjectActorsList(project.id),
        StoryService.getFollowTasks(project.id),
        StoryService.getExigences(project.id),
        AuthenticationService.getUser()
      ];

      Future.wait(apiCalls).then((List<dynamic> results){

        currentUser = results[4];

        themes = t.Theme.getAll();
        themes.forEach((theme) => selectedThemes.add(theme));

        Epic.loadProjectEpicsList(project.id).then((result){

          epics = Epic.getAll();
          epics.forEach((epic){
            if(selectedThemes.contains(t.Theme.getById(epic.idTheme)))
              epicsToShow.add(epic);
          });
          epicsToShow.forEach((epic) => selectedEpics.add(epic));
          actors = Actor.getAll();
          actors.forEach((actor) => selectedActors.add(actor));
          states = StoryState.getAll();
          if(selectedStates.isEmpty) // au cas ou on vient du dashboard pour pas écraser le tri
            states.forEach((state) => selectedStates.add(state));
          followTasks = results[2]; // chargement des tâches de suivis
          exigences = results[3]; // chargement des exigences
          StoryService.getAllFromProjectID(project.id).then((List<dynamic> storiesFromApi){
            // chargement des stories
            storiesFromApi.forEach((storyFromApi) => stories.add(Story.fromApi(storyFromApi)));
            if(stories.length > 50)
              showSearchField = true;
            vmMax = stories.length > 0 ? (stories.length >= 2 ? stories.reduce((Story s1, Story s2) => s1.vm > s2.vm ? s1 : s2).vm : stories.first.vm) : 0;
            stories.forEach((story){
              if(story.idStoryState == null || selectedStates.contains(StoryState.getById(story.idStoryState)))
                listeTriee.add(story);
            });
            Story.sortStoryList(listeTriee, [selectedTri], triOrder);
            storiesToShow.addAll(listeTriee);

            setState(() => isLoading = false);
          });
        });
      });
    });
  }

  @override
  initState(){
    ConnectionListener listener = ConnectionListener.getInstance();
    hasConnection = listener.hasConnection;
    _connectionChangeStream = listener.connectionChange.listen((hasConnectionFromCallback) {
      setState(() => hasConnection = hasConnectionFromCallback);
    });

    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0)..addListener(() => // initialisation du controller des différents onglets
      setState(() {})
    );

    loadDatas();
    super.initState();
  }

  @override
  void dispose() {
    _connectionChangeStream.cancel();
    super.dispose();
  }

/// SECTION RAFRAîCHISSEMENT DES DONNÉES ///

  Future<void> refreshStories() async {

    stories.clear();
    listeTriee.clear();
    storiesToShow.clear();
    vmMax = 0;

    var result = await StoryService.getAllFromProjectID(project.id);
    for (var story in result){
      Story s = Story.fromApi(story);
      stories.add(s);
      if(s.vm > vmMax)
        vmMax = s.vm;
    }

    // on retire les stories qui ne correspondent pas aux critères de tri perso
    stories.forEach((story){
      if((story.idTheme == null || selectedThemes.contains(t.Theme.getById(story.idTheme))) &&
          (story.idEpic == null || selectedEpics.contains(Epic.getById(story.idEpic))) &&
          (story.idActor == null || selectedActors.contains(Actor.getById(story.idActor))) &&
          (story.idStoryState == null || selectedStates.contains(StoryState.getById(story.idStoryState)))){
        listeTriee.add(story);
      }
    });

    // on ordonne les stories restantes
    setState((){
      storiesToShow = Story.sortStoryList(listeTriee, [selectedTri], triOrder);
      searchInProgress = true;
    });
    StateProvider().notify(ObserverState.LIST_REFRESHED);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => StateProvider().notify(ObserverState.STORYGROUP_ASK_REFRESH)); // permet de notifier une fois le build fini pour que les infos soient transmises
  }

  Future<void> _refreshFollowTasks() async {
    var result = await StoryService.getFollowTasks(project.id);
    setState(() {
      followTasks = result;
    });
  }

  Future<void> _refreshExigences() async {
    var result = await StoryService.getExigences(project.id);
    setState(() {
      exigences = result;
    });
  }

  /// SECTION CONSTRUCTION DES "CARTES" GRAPHIQUES REPRÉSENTANT LES DONNÉES ///

  List<Widget> followTasksViewsBuilder(width){
    List<Widget> children = new List<Widget>();
    for (var iterator in followTasks){
      children.add(FollowTaskViewInBacklog(followTask: FollowTask.fromApi(iterator), width: width));
    }
    return children;
  }

  List<Widget> exigencesViewsBuilder(){
    List<Widget> children = new List<Widget>();
    for (var exigence in exigences){
      children.add(ExigenceViewInBacklog(exigence: Exigence.fromApi(exigence)));
    }
    return children;
  }

  /// SECTION CONSTRUCTION DE L'INTERFACE GLOBALE ///

  @override
  Widget build(BuildContext context) {
    if(isLoading && ModalRoute.of(context).settings.arguments != null)
      selectedStates = ModalRoute.of(context).settings.arguments;

    if(stories.isNotEmpty) {
      return OriginScaffold(
        isLoading: isLoading,
        title: project != null ? project.name : "Project inconnu",
        currentViewId: OriginConstants.backlogViewId,
        bottomTabBar: TabBar(
          tabs: [
            Tab(text: "Backlog",),
            Tab(text: "Suivi"),
            Tab(icon: Icon(Icons.library_books)),
          ],
          controller: _tabController,
        ),
        body: TabBarView(
          children: [
            /** premier onglet, liste des US **/
            Column(
              children: <Widget>[
                showSearchField ? SearchBar<Story>(
                  label: "Rechercher une story",
                  hint: "Je peux...",
                  listOfValues: listeTriee,
                  initialSearch: lastQuery,
                  onChanged: (String query, List<Story> filteredList){
                    lastQuery = query;
                    setState((){
                      searchInProgress = false;
                      storiesToShow = filteredList;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) => StateProvider().notify(ObserverState.STORYGROUP_ASK_REFRESH)); // permet de notifier une fois le build fini pour que les infos soient transmises
                  },
                ) : Container(),
                storiesToShow.isNotEmpty ? Expanded(
                    child: _groupedBy == GroupByID.NONE ? ListViewStory(storiesToShow, refreshStories, vmMax) : ListViewGroupStory(storiesToShow, refreshStories, vmMax, _groupedBy)
                ) : Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text("Aucune story à afficher", style: TextStyle(color: solutecGrey))
                            )
                          )
                        ]
                    )
                )
              ]
            ),
            /** deuxième onglet, liste des followTasks **/
            RefreshIndicator(
              child: ListView(
                padding: EdgeInsets.all(5),
                children: followTasksViewsBuilder(MediaQuery.of(context).size.width)
              ),
              onRefresh: _refreshFollowTasks
            ),
            /** troisième onglet, liste des exigences **/
            RefreshIndicator(
              child: ListView(
                padding: EdgeInsets.all(5),
                children: exigencesViewsBuilder()
              ),
              onRefresh: _refreshExigences
            )
          ],
          controller: _tabController
        ),
        appbarExtraIcon: hasConnection && project.members.contains(currentUser) ? GestureDetector(
          onTap: () {
            if(PushNotificationHandler.lastToast != null && PushNotificationHandler.lastToast.isShowing())
              PushNotificationHandler.lastToast.dismiss();
            Navigator.pushNamed(context, OriginConstants.routePlanningPoker);
            },
          child: Icon(OriginIcons.playing_cards)
        ) : null,
        floatingActionButton: _tabController.index == 0 ? DropdownFloatingActionButton(
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
              heroTag: "btnTriAvance",
              backgroundColor: solutecGrey,
              onPressed: () => showDialog(context: context, builder: (_) => DialogContent(backlog: this)),
              tooltip: "Tri avancé",
              child: Icon(Icons.sort),
            )
          ]
        ) : null,
      );
    }else{
      return OriginScaffold(
        isLoading: isLoading,
        title: project != null ? project.name : "Chargement...",
        currentViewId: OriginConstants.backlogViewId,
        body: RefreshIndicator(
          onRefresh: refreshStories,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text("Aucune story à afficher", style: TextStyle(color: solutecGrey))
                          )
                      )
                    ]
                )
            )
          )
        )
      );
    }
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
          setState(() => storiesToShow = Story.sortStoryList(listeTriee, [selectedTri], triOrder));
      },
      tooltip: tooltip,
      child: content,
    );
  }

}

/// MODAL DE PERSONNALISATION DU TRI
class DialogContent extends StatefulWidget {

  final BacklogActivityState backlog;

  DialogContent({@required this.backlog});

  @override
  _DialogContentState createState() => new _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {

  _updateGroupedBy(GroupByID id) {
    setState(() => widget.backlog._groupedBy != id ? widget.backlog._groupedBy = id : widget.backlog._groupedBy = GroupByID.NONE);
  }

  @override
  Widget build(BuildContext context) {
    return OriginDialog(
        title: "Tri personnalisé",
        content: <Widget>[
            Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Thèmes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownSelector(
                      listOfValues: widget.backlog.themes,
                      selectedValues: widget.backlog.selectedThemes,
                      onChanged: (){
                        setState(() {
                          widget.backlog.epicsToShow.clear();
                          widget.backlog.epics.forEach((epic){
                            if(widget.backlog.selectedThemes.contains(t.Theme.getById(epic.idTheme))) {
                              widget.backlog.epicsToShow.add(epic);
                              if(!widget.backlog.selectedEpics.contains(epic))
                                widget.backlog.selectedEpics.add(epic);
                            }else if(widget.backlog.selectedEpics.contains(epic))
                              widget.backlog.selectedEpics.remove(epic);
                          });
                        });
                      },
                    ),
                  ],
                )
            ),
            SizedBox(height: 15),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Épics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownSelector(
                    listOfValues: widget.backlog.epicsToShow,
                    selectedValues: widget.backlog.selectedEpics,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Acteurs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownSelector(
                    listOfValues: widget.backlog.actors,
                    selectedValues: widget.backlog.selectedActors,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("États", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownSelector(
                    listOfValues: widget.backlog.states,
                    selectedValues: widget.backlog.selectedStates,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Divider(),
            /// GROUP BY SECTION
            Text("Grouper par", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.start,
                runSpacing: 10,
                children: <Widget>[ // GROUP BUTTONS
                  MaterialButton(
                    padding: EdgeInsets.all(20),
                    shape: CircleBorder(),
                    color: widget.backlog._groupedBy == GroupByID.THEME ? solutecRed : Colors.red[200],
                    textColor: Colors.white,
                    child: Text("Thème"),
                    onPressed: () => _updateGroupedBy(GroupByID.THEME),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(20),
                    shape: CircleBorder(),
                    color: widget.backlog._groupedBy == GroupByID.EPIC ? solutecRed : Colors.red[200],
                    textColor: Colors.white,
                    child: Text("Épic"),
                    onPressed: () => _updateGroupedBy(GroupByID.EPIC),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(20),
                    shape: CircleBorder(),
                    color: widget.backlog._groupedBy == GroupByID.STATE ? solutecRed : Colors.red[200],
                    textColor: Colors.white,
                    child: Text("État"),
                    onPressed: () => _updateGroupedBy(GroupByID.STATE),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(20),
                    shape: CircleBorder(),
                    color: widget.backlog._groupedBy == GroupByID.PRIORITY ? solutecRed : Colors.red[200],
                    textColor: Colors.white,
                    child: Text("Priorité"),
                    onPressed: () => _updateGroupedBy(GroupByID.PRIORITY),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.all(20),
                    shape: CircleBorder(),
                    color: widget.backlog._groupedBy == GroupByID.SPRINT ? solutecRed : Colors.red[200],
                    textColor: Colors.white,
                    child: Text("Sprint"),
                    onPressed: () => _updateGroupedBy(GroupByID.SPRINT),
                  ),
                ],
              ),
            ),
          ],
        bottom: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Text("Valider", style: TextStyle(color: Colors.white)),
          elevation: 5.0,
          color: Colors.green,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: (){
            Navigator.of(context, rootNavigator: true).pop(true);
            widget.backlog.refreshStories();
          },
        )
    );
  }
}