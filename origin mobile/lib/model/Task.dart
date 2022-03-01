// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/services/CommentService.dart';
// ** OTHERS ** //
import 'package:origin/model/Test.dart';
import 'package:origin/model/Comment.dart';

class Task {
  int id;
  String title;
  String description;
  double effort;
  DateTime endingDate;
  double performedDuration;
  double realDuration;
  int taskState;
  List<Test> listTests = List<Test>();
  List<Comment> comments = List<Comment>();

  Task({this.id, this.title, this.description,
    this.effort, this.endingDate, this.performedDuration,
    this.realDuration, this.taskState, this.listTests,});

  Task.fromApi(Map<String, dynamic> taskFromApi){
    this.id = taskFromApi['taskId'];
    this.title = taskFromApi['title']?.replaceAll("\n", "");
    this.description = taskFromApi['description']?.replaceAll("\n", "");
    this.effort = taskFromApi['effort'];
    this.endingDate = taskFromApi['endingDate'] != null ? DateTime.parse(taskFromApi['endingDate'].substring(0, 13) + ' -02'): null;
    this.performedDuration = taskFromApi['performedDuration'];
    this.realDuration = taskFromApi['realDuration'];
    this.taskState = taskFromApi["taskState"] != null ? taskFromApi["taskState"]['taskStateValue'] : 0;
    if(taskFromApi['noteList'] != null)
      taskFromApi['noteList'].forEach((comment){
        this.comments.add(Comment.fromApi(comment));
      });
  }

  /// crée une tâche ainsi que les tests qui lui sont associés
  Task.fromApiWithTests(Map<String, dynamic> taskFromApi){
    this.id = taskFromApi['taskId'];
    this.title = taskFromApi['title'];
    this.description = taskFromApi['description'];
    this.effort = taskFromApi['effort'];
    this.endingDate = taskFromApi['endingDate'] != null ? DateTime.parse(taskFromApi['endingDate'].substring(0, 13) + ' -02'): null;
    this.performedDuration = taskFromApi['performedDuration'];
    this.realDuration = taskFromApi['realDuration'];
    this.taskState = taskFromApi["taskState"] != null ? taskFromApi["taskState"]['taskStateValue'] : 0;
    if(taskFromApi['noteList'] != null)
      taskFromApi['noteList'].forEach((comment){
        this.comments.add(Comment.fromApi(comment));
      });
    this.listTests = List<Test>();
    taskFromApi['testList'].forEach((test){
      this.listTests.add(Test.fromApi(test));
    });
  }

  Task.copy(Task task){
    this.id = task.id;
    this.title = task.title;
    this.description = task.description;
    this.effort = task.effort;
    this.endingDate = task.endingDate;
    this.performedDuration = task.performedDuration;
    this.realDuration = task.realDuration;
    this.taskState = task.taskState;
    this.listTests = task.listTests;
    this.comments = task.comments;
  }

  Future<void> reloadComments() async{
    this.comments.clear();
    var commentsFomApi = await CommentService.getAllComments(this);
    commentsFomApi.forEach((comment){
      this.comments.add(Comment.fromApi(comment));
    });
  }

  @override
  String toString(){
    return "Tâche: ${this.title}, État: ${OriginConstants.taskStateToText[this.taskState]}";
  }

}
