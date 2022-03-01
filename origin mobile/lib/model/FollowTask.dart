import 'package:origin/model/Task.dart';

class FollowTask extends Task{

  int id;
  String title;
  double effort;
  DateTime endDate;
  double performedDuration;
  int taskState;
  int priorityId;

  FollowTask({int id, String title, double effort, DateTime endDate, double performedDuration, int taskState, int priorityId}){
    this.id = id;
    this.title = title;
    this.effort = effort;
    this.endDate = endDate;
    this.performedDuration = performedDuration;
    this.taskState = taskState;
    this.priorityId = priorityId;
  }

  FollowTask.fromApi(Map<String, dynamic> followTaskFromApi){
    this.priorityId = followTaskFromApi['priority'] != null ? followTaskFromApi['priority']['priorityId'] : null;
    this.id = followTaskFromApi['followTaskId'];
    this.title = followTaskFromApi['description']?.replaceAll("\n", "");
    this.effort = followTaskFromApi['effort'];
    this.endDate = followTaskFromApi['endingDate'] != null ? DateTime.parse(followTaskFromApi['endingDate']?.substring(0, 19)) : null;
    this.performedDuration = followTaskFromApi['performedDuration'];
    this.taskState = followTaskFromApi['taskState'] != null ? followTaskFromApi['taskState']['taskStateValue'] : null;
  }

  FollowTask.copy(FollowTask task){
    this.id = task.id;
    this.title = task.title;
    this.effort = task.effort;
    this.endDate = task.endDate;
    this.performedDuration = task.performedDuration;
    this.taskState = task.taskState;
    this.priorityId = task.priorityId;
  }
}