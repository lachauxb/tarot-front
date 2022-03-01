// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:origin/core/stateListener.dart';
// ** SERVICES ** //
import 'package:origin/services/StoryService.dart';
import 'package:origin/services/UserService.dart';
// ** MODEL ** //
import 'package:origin/model/Story.dart';
import 'package:origin/model/Epic.dart';
import 'package:origin/model/Theme.dart' as t;
import 'package:origin/model/Priority.dart';
import 'package:origin/model/User.dart';
// ** WIDGET ** //
import 'package:origin/widgets/Sprint/TaskManager.dart';
import 'package:origin/widgets/Story/StoryStateChip.dart';
import 'package:origin/widgets/UserTrigram.dart';
import 'package:origin/widgets/Comment/CommentButton.dart';
// ** OTHERS ** //

/// classe permettant de récupérer des arguments pour une route nommée
class ScreenArguments {
  Story story;
  final int vmMax;
  final String previousViewId;

  ScreenArguments(this.story, this.vmMax, this.previousViewId);
}

class StoryActivity extends StatefulWidget {
  StoryActivity({Key key,}) : super(key: key);


  @override
  _StoryActivityState createState() => _StoryActivityState();
}

class _StoryActivityState extends State<StoryActivity> implements StateListener{

  ScreenArguments args;
  Project project;

  bool _isLoading = true;

  /// actualisation des informations de la page
  Future<void> reloadData() async{
    StoryService.getStoryById(args.story.id).then((Map<String, dynamic> results) {
      args.story.reloadFromShortApi(results);
      setState(() {});
    });

    /*var apiCalls = <Future>[
      StoryService.getStoryById(args.story.id),
      //StoryService.getStoryTasks(args.story.id),
      UserService.getStoryUsers(args.story.id)
    ];

    Future.wait(apiCalls).then((List<dynamic> results){
      args.story.reloadFromShortApi(results[0]);
      //args.story.reloadTasksFromApi(results[1]);
      //args.story.loadUsersFromApi(results[1]);
      setState(() {});
    });*/
  }

  ///pas de chargement de données au lancement de cette page
  ///on se base sur ce qui est fourni pas la page précédente
  @override
  void initState(){
    super.initState();
    ProjectService.getCurrentProject().then((project) => setState((){
      this.project = project;
      _isLoading = false;
    }));
    StateProvider().subscribe(this);
  }

  @override
  void onStateChanged(ObserverState state) {
    if(state == ObserverState.STORY_UPDATED) {
      reloadData();
    }
  }

  ///fonction blocante pour le RefreshIndicator
  Future<void> _onRefresh() async{
    await reloadData();
  }

  /// Liste des utilisateurs affectés à la Story
  Widget userList({@required double maxWidth}){
    List<Widget> columnWidgets = List<Widget>();
    List<Widget> currentRowWidgets = List<Widget>();
    args.story.users.forEach((user){
      if((currentRowWidgets.length + 1) * OriginConstants.userTrigramSize.width > maxWidth){
        columnWidgets.add(Row(children: List.from(currentRowWidgets),));
        currentRowWidgets.clear();
      }
      currentRowWidgets.add(UserTrigram(user: user,));
    });
    if(currentRowWidgets.isNotEmpty)
      columnWidgets.add(Row(children: List.from(currentRowWidgets),));
    return Container(
      child: Column(children: columnWidgets, crossAxisAlignment: CrossAxisAlignment.start,),
    );
  }

  @override
  Widget build(BuildContext context){
    if(args == null)
      args = ModalRoute.of(context).settings.arguments;

    return OriginScaffold(
      title: args.story.title,
      currentViewId: OriginConstants.storyViewId,
      previousViewId: args.previousViewId,
      isLoading: _isLoading,
      body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox.fromSize(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              child: Card(
                margin: EdgeInsets.all(5.0),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: constraints.maxWidth - 30,
                              padding: EdgeInsets.only(bottom: 5.0),
                              child: Text(
                                args.story.title,
                                overflow: TextOverflow.clip,
                                maxLines: 5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: solutecGrey,
                                ),
                              ),
                            ),
                            CommentButton(item: args.story),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 5.0),
                              width: constraints.maxWidth - OriginConstants.storyStateChipWidth,
                              child: args.story.idTheme != null && args.story.idEpic != null ? Container(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text("${t.Theme.getById(args.story.idTheme)?.name}"
                                    " - ${Epic.getById(args.story.idEpic)?.name}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ) : null,
                            ),
                            StoryStateChip(storyState: args.story.idStoryState),
                          ],
                        ),
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
                                    child: Text("VM: ", style: TextStyle(
                                        fontSize: 14, color: solutecGrey)),
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
                                              value: args.vmMax != 0 ? (args.story.vm / args.vmMax) : 1,
                                              valueColor: AlwaysStoppedAnimation(solutecGrey),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                  args.story.vm.toString(),
                                                  style: TextStyle(color: solutecGrey)),
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
                                    padding: EdgeInsets.only(
                                        left: constraints.maxWidth * 0.3),
                                    child: Text(
                                      "Effort: ${args.story.realEffort
                                          .toString()}/${args.story.effort
                                          .toString()}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: solutecGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [Priority.getById(args.story.idPriority).icon],
                                mainAxisAlignment: MainAxisAlignment.end,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            userList(maxWidth: constraints.maxWidth -
                                OriginConstants.userTrigramSize.height),
                            PopupMenuButton( // menu déroulant
                              child: Container(
                                height: OriginConstants.userTrigramSize.height,
                                width: OriginConstants.userTrigramSize.height,
                                child: Icon(Icons.person_add, color: solutecGrey),
                              ),
                              onSelected: (User user) {
                                setState(() {
                                  if (args.story.users.contains(user)) {
                                    args.story.users.remove(user);
                                  }
                                  else {
                                    args.story.users.add(user);
                                  }
                                });
                                List<Map<String, dynamic>> jsonUsers = List<Map<String, dynamic>>();
                                args.story.users.forEach((user) {
                                  jsonUsers.add({"userId": user.id});
                                });
                                UserService.updateStoryUsers(args.story.id, jsonUsers).then((onValue) {
                                  StateProvider().notify(ObserverState.STORY_UPDATED);
                                });
                              },
                              itemBuilder: (context) {
                                return project.members.map((User value) {
                                  return PopupMenuItem<User>(
                                    value: value,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.check,
                                          color: args.story.users.contains(value) ? solutecRed : Colors.transparent,
                                        ),
                                        SizedBox(width: 16),
                                        Text("${value.prenom} ${value.nom}"),
                                      ],
                                    ),
                                  );
                                },).toList();
                              },
                            ),
                          ],
                        ),
                        TaskManager(story: args.story),
                      ],
                    );
                  },),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose(){
    StateProvider().dispose(this);
    super.dispose();
  }
}