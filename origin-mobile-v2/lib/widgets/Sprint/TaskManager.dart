// ** AUTO LOADER ** //
import 'package:flutter/gestures.dart';
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:flutter/material.dart';
import 'package:origin/model/FollowTask.dart';
import 'package:origin/services/StoryService.dart';
// ** SERVICES ** //
import 'package:origin/services/TaskService.dart';
import 'package:origin/services/TestService.dart';
// ** MODEL ** //
import 'package:origin/model/Task.dart';
import 'package:origin/model/Story.dart';
import 'package:origin/model/Test.dart';
// ** OTHERS ** //
import 'package:origin/widgets/Comment/CommentButton.dart';

class TaskManager extends StatefulWidget {
  final Story story;
  final List<FollowTask> followTasks;
  TaskManager({Key key, this.story, this.followTasks}): super(key: key);

  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> with TickerProviderStateMixin{
  Map<int, Map<int, Widget>> taskLists;
  Map<int, bool> willAccept = {2: false, 3: false, 4: false, 5: false};
  Map<int, bool> mustCollapse = {2: false, 3: false, 4: false, 5: false};
  Map<int, bool> collapsed = {2: false, 3: false, 4: false, 5: false};

  @override
  void initState(){
    super.initState();

    taskLists ={2 : {}, 3 : {}, 4 : {}, 5 : {}};
    generateTaskTiles();

    /// critères pour utiliser l'affichage réduit des tâches
    /// peuvent changer pour convenir à différents formats d'écran
    if(taskLists[2].length + taskLists[3].length + taskLists[4].length + taskLists[5].length >= 4){ // 4 tâches ou plus dans la Story
      for(int i = 2; i <= 5; i++){
        mustCollapse[i] = taskLists[i].length > 1; //plus d'une tâche par état
        collapsed[i] = taskLists[i].length > 1;
      }
    }
  }

  /// Crée le visuel d'une tâche
  Widget generateTile(task){
    int testCount = 0;
    if(task.runtimeType == Task)
      task.listTests.forEach((test){
        if(test.checked){
          testCount = testCount +1;
        }
      });
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return LongPressDraggable(
        data: task.runtimeType == Task ? Task.copy(task) : FollowTask.copy(task),
        onDragCompleted: (){
          setState(() {
            taskLists[task.taskState].remove(task.id);
            if(taskLists[2].length + taskLists[3].length + taskLists[4].length + taskLists[5].length < 4 || taskLists[task.taskState].length <= 1) {
              mustCollapse[task.taskState] = false;
              collapsed[task.taskState] = false;
            }
          });
        },
        feedback: DefaultTextStyle( // apparence en cours de déplacement
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 14,
            fontFamily: "OpenSans",
          ),
          child: Container(
            padding: EdgeInsets.all(5.0),
            //width: MediaQuery.of(context).size.width * 0.85,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 3, spreadRadius: 1)], // Élévation
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                task.runtimeType == Task ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: constraints.maxWidth - 40,
                      child: Text(task.title),
                    ),
                    Material(
                      child: CommentButton(item: task)
                    )
                  ]
                ) : Container(
                  width: constraints.maxWidth,
                  child: Text(task.title)
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 5,
                  children: <Widget>[
                    task.runtimeType == Task ? Text('Tests: $testCount/${task.listTests.length}') : Container(),
                    Text('Effort: ${task.effort}')
                  ]
                )
              ]
            )
          )
        ),
        child: GestureDetector( // apparence en fonctionnement normal
          onTap: task.runtimeType == Task && task.listTests.length > 0 ? () {
            showDialog(
              context: context,
              builder: (_) => TestValidationDialog(task: task, validating: false,),
            ).then((updatedTests){
              if(updatedTests != null) {
                setState(() {
                  task.listTests = updatedTests;
                });
              }
            });
          }: null,
          child: Container(
            margin: EdgeInsets.only(top: 5.0),
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                task.runtimeType == Task ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: constraints.maxWidth - 40,
                      child: Text(task.title)
                    ),
                    Material(
                      child: CommentButton(item: task)
                    )
                  ]
                ) : Container(
                  width: constraints.maxWidth,
                  child: Text(task.title),
                ),
                Container(
                  width: constraints.maxWidth,
                  child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: <Widget>[
                        task.runtimeType == Task ? Text('Tests: $testCount/${task.listTests.length}') : Container(),
                        Text('Effort: ${task.effort}')
                      ]
                  )
                )
              ]
            )
          )
        ),
        childWhenDragging: Container( // widget affiché à l'emplacement initial pendant un déplacement
          margin: EdgeInsets.only(top: 5.0),
          padding: EdgeInsets.all(5.0),
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.all(Radius.circular(6.0)),
          ),
          child: Row(),
        ),
      );
    },);
  }

  /// lance la création des visuels de toutes les tâches de la Story
  void generateTaskTiles(){
    if(widget.story != null) {
      for (Task task in widget.story.listTasks) {
        if (![2, 3, 4, 5].contains(task
            .taskState)) { // prise en compte de l'état 1, ne devrait jamais se produire
          task.taskState = 2;
          TaskService.changeTaskState(task.id, 2);
        }
        taskLists[task.taskState][task.id] = generateTile(task);
      }
    } else {
      widget.followTasks.forEach((task){
        if (![2, 3, 4, 5].contains(task
            .taskState)) { // prise en compte de l'état 1, ne devrait jamais se produire
          task.taskState = 2;
          TaskService.changeTaskState(task.id, 2);
        }
        taskLists[task.taskState][task.id] = generateTile(task);
      });
    }
  }

  /// Création des blocs d'état des tâches
  Widget taskTileByState({int taskStateId}){
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 3, spreadRadius: 1)], // Élévation
        ),
        child: DragTarget(
          builder: (BuildContext context, List<Task> candidateData, rejectedData) {
            return Column(
              children: <Widget>[
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: OriginConstants.taskStateToColor[taskStateId],
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0),
                        topRight: Radius.circular(32.0)),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {collapsed[taskStateId] = !collapsed[taskStateId];}),
                  child: Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(OriginConstants.taskStateToText[taskStateId],
                          style: TextStyle(
                              color: solutecGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w900
                          ),
                        ),
                        mustCollapse[taskStateId] ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            collapsed[taskStateId] ? Text(
                              "+${taskLists[taskStateId].length - 1}",
                              style: TextStyle(
                                color: solutecGrey,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ) : Container(),
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              child: Icon(collapsed[taskStateId] ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: solutecGrey,),
                            ),
                          ],
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40.0),
                  child: AnimatedContainer( //todo remplacer par un container classique ou faire fonctionner l'animation
                    duration: Duration(milliseconds: 500),
                    padding: EdgeInsets.only(left: 5.0, bottom: 5.0, right: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: (mustCollapse[taskStateId] && collapsed[taskStateId]) ? (taskLists[taskStateId].isNotEmpty ? [taskLists[taskStateId].values.first] : []) : taskLists[taskStateId].values.toList(),
                        ),
                        willAccept[taskStateId] ? Container(
                          margin: EdgeInsets.only(top: 5.0),
                          padding: EdgeInsets.all(5.0),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: Row(),
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          onWillAccept: (Task data) {//triggered quand un draggable survole le widget
            if ((data.taskState != taskStateId) && ( // la tâche doit être dans un état différent de celui du bloc d'éat
                taskLists[2].containsKey(data.id) || // et venir de la bonne story
                    taskLists[3].containsKey(data.id) ||
                    taskLists[4].containsKey(data.id) ||
                    taskLists[5].containsKey(data.id)
            )){
              setState(() {
                willAccept[taskStateId] = true;
              });
              return true;
            }
            return false;
          },
          onAccept: (Task data){ // triggered quand un draggable est lâché sur ce bloc d'état
            bool testsValidated = true;
            if(taskStateId == 5){ //vérification des tests pour terminer une tâche
              if(widget.story != null)
                for(Test test in data.listTests){
                  if(test.checked == false) {
                    testsValidated = false;
                  }
                }
              if(!testsValidated){
                showDialog( // demande de validation des tests
                  context: context,
                  builder: (_) => TestValidationDialog(task: data, validating: true,),
                ).then((updatedTests){
                  testsValidated = true;
                  for(Test test in updatedTests){ // nouvelle vérification des tests
                    if(test.checked == false) {
                      testsValidated = false;
                    }
                  }
                  if(testsValidated){
                    taskLists[data.taskState].remove(data.id);
                    data.taskState = taskStateId;
                    taskLists[taskStateId][data.id] = generateTile(data);
                    if(taskLists[5].length == widget.story.listTasks.length) { // si toutes les tâches sont terminées
                      StoryService.changeStoryState(widget.story.id, 8).then((value){ // on termine la Story
                        StateProvider().notify(ObserverState.STORY_UPDATED);
                      });
                    } else if(taskLists[2].isEmpty && taskLists[3].isEmpty){ // s'il ne reste que des tâches à tester
                      StoryService.changeStoryState(widget.story.id, 7).then((value){ // la Story passe également dans l'état à tester
                        StateProvider().notify(ObserverState.STORY_UPDATED);
                      });
                    }
                    TaskService.changeTaskState(data.id, taskStateId).then((value){
                      StateProvider().notify(ObserverState.STORY_UPDATED);
                    });
                    setState(() {
                      willAccept[taskStateId] = false;
                      if(widget.story.listTasks.length >= 4 && taskLists[taskStateId].length > 1){
                        mustCollapse[taskStateId] = true;
                        collapsed[taskStateId] = false;
                      }
                    });
                  }
                },);
              }else{ // les tests étaient validés
                taskLists[data.taskState].remove(data.id);
                data.taskState = taskStateId;
                taskLists[taskStateId][data.id] = generateTile(data);
                if(widget.story != null) {
                  if (taskLists[2].isEmpty && taskLists[3].isEmpty &&
                      taskLists[4]
                          .isEmpty) { // si toutes les tâches sont terminées
                    StoryService.changeStoryState(widget.story.id, 8).then((
                        value) { // on termine la Story
                      StateProvider().notify(ObserverState.STORY_UPDATED);
                    });
                  } else if (taskLists[2].isEmpty && taskLists[3]
                      .isEmpty) { // s'il ne reste que des tâches à tester
                    StoryService.changeStoryState(widget.story.id, 7).then((
                        value) { // la Story passe également dans l'état à tester
                      StateProvider().notify(ObserverState.STORY_UPDATED);
                    });
                  }
                }
                widget.story != null ? TaskService.changeTaskState(data.id, taskStateId).then((
                    value) {
                  StateProvider().notify(ObserverState.STORY_UPDATED);
                }) : TaskService.changeFollowTaskState(data.id, taskStateId).then((
                    value) {
                  StateProvider().notify(ObserverState.STORY_UPDATED);
                });
                setState(() {
                  willAccept[taskStateId] = false;
                  if(taskLists[2].length + taskLists[3].length + taskLists[4].length + taskLists[5].length >= 4 && taskLists[taskStateId].length > 1){
                    mustCollapse[taskStateId] = true;
                    collapsed[taskStateId] = false;
                  }
                });
              }
            }else{ // Le nouvel état est autre que terminé
              taskLists[data.taskState].remove(data.id);
              data.taskState = taskStateId;
              taskLists[taskStateId][data.id] = generateTile(data);
              if(widget.story != null) {
                if (taskStateId == 4 && taskLists[2].isEmpty && taskLists[3]
                    .isEmpty) { //toutes les tâches sont à tester ou terminées
                  StoryService.changeStoryState(widget.story.id, 7).then((
                      value) { // La story passe en "à tester"
                    StateProvider().notify(ObserverState.STORY_UPDATED);
                  });
                } else if ((taskStateId == 2 || taskStateId == 3) &&
                    (taskLists[2].length + taskLists[3].length ==
                        1)) { //une tâche arrive dans "à faire" ou "en cours" alors qu'il n'y en avait aucune
                  StoryService.changeStoryState(widget.story.id, 6).then((
                      value) { // La story retourne à l'état "en cours"
                    StateProvider().notify(ObserverState.STORY_UPDATED);
                  });
                }
              }
              widget.story != null ? TaskService.changeTaskState(data.id, taskStateId).then((
                  value) {
                StateProvider().notify(ObserverState.STORY_UPDATED);
              }) : TaskService.changeFollowTaskState(data.id, taskStateId).then((
                  value) {
                StateProvider().notify(ObserverState.STORY_UPDATED);
              });
              setState(() {
                willAccept[taskStateId] = false;
                if(taskLists[2].length + taskLists[3].length + taskLists[4].length + taskLists[5].length >= 4 && taskLists[taskStateId].length > 1){
                  mustCollapse[taskStateId] = true;
                  collapsed[taskStateId] = false;
                }
              });
            }},
          onLeave: (data){ // triggered quand un draggable ne survole plus le bloc d'état
            setState(() {
              willAccept[taskStateId] = false;
            });
          },
        ),
      );
    },);
  }


  @override
  Widget build(BuildContext context){
    return Expanded(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                MediaQuery.of(context).orientation == Orientation.portrait ?
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    taskTileByState(taskStateId: 2),
                    taskTileByState(taskStateId: 3),
                    taskTileByState(taskStateId: 4),
                    taskTileByState(taskStateId: 5),
                  ],
                ):
                LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: constraints.maxWidth / 4,
                        padding: EdgeInsets.only(right: 7.5),
                        child: taskTileByState(taskStateId: 2),
                      ),
                      Container(
                        width: constraints.maxWidth / 4,
                        padding: EdgeInsets.only(left: 2.5, right: 5),
                        child: taskTileByState(taskStateId: 3),
                      ),
                      Container(
                        width: constraints.maxWidth / 4,
                        padding: EdgeInsets.only(left: 5, right: 2.5),
                        child: taskTileByState(taskStateId: 4),
                      ),
                      Container(
                        width: constraints.maxWidth / 4,
                        padding: EdgeInsets.only(left: 7.5),
                        child: taskTileByState(taskStateId: 5),
                      ),
                    ],
                  );
                },),
              ],
            ),
          );
  }

  @override
  void dispose(){
    super.dispose();
  }
}

/// Dialogue de validation des tests
class TestValidationDialog extends StatefulWidget {
  TestValidationDialog({this.task, this.validating});
  final Task task;
  final bool validating; // change l'affichage si le dialogue est automatiquement affiché pendant le changeent d'état d'une tâche

  @override
  _TestValidationDialogState createState() => _TestValidationDialogState();
}

class _TestValidationDialogState extends State<TestValidationDialog>{
  bool changed = false;
  List<Widget> checkboxTiles = List<Widget>();

  /// fonction appelée lors de la fermeture du dialogue
  Future<bool> _onPop() async{
    if(changed){
      _save();
    }
    Navigator.of(context).pop(widget.task.listTests);
    return false;
  }

  /// sauvegarde des nouveaux états en BDD
  Future<void> _save() async{
    int counter = 0;
    widget.task.listTests.forEach((test){
      TestService.changeTestState(test.id, test.checked).then((value){
        counter ++;
        if(counter == widget.task.listTests.length){
          StateProvider().notify(ObserverState.STORY_UPDATED);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // détecte la fermeture du dialogue et appelle _onPop
      onWillPop: changed ? _onPop : null,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.validating ? Container(
                padding: EdgeInsets.only(bottom: 5.0,),
                alignment: Alignment.center,
                child: Text("Validez les tests pour terminer la tâche",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: solutecRed,
                  ),
                ),
              ): Container(),
              Container(
                padding: EdgeInsets.only(bottom: 15.0,),
                alignment: Alignment.center,
                child: Text(widget.task.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: solutecGrey,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => Divider(),
                itemCount: widget.task.listTests.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: widget.task.listTests[index].checked ? Icon( Icons.check_box, color: solutecRed,) : Icon(Icons.check_box_outline_blank,),
                    title: Text(widget.task.listTests[index].title),
                    onTap: (){
                      setState(() {
                        widget.task.listTests[index].checked = !widget.task.listTests[index].checked;
                        changed = true;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
