// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/services/CommentService.dart';
// **  VIEWS   ** //
// **  OTHERS  ** //
import 'package:origin/model/Story.dart';
import 'package:origin/model/Comment.dart';
import 'package:origin/model/FollowTask.dart';

class Sprint{
  int id;
  String name;
  String description;
  DateTime beginningDate;
  DateTime endingDate;
  bool active;
  int state;
  int sprintDurationDays;
  int sprintDurationHours;
  int sprintRealDurationHours;
  int sprintRealDurationDays;
  int businessValue;
  int realBusinessValue;
  int sumBusinessValue;
  double sumEffort;
  double realEffort;
  double velocity;
  List<Story> listStories = List<Story>();
  List<Comment> comments = List<Comment>();
  List<FollowTask> followTasks = List<FollowTask>();

  Sprint({this.name, this.description, this.businessValue, this.realBusinessValue,
  this.id, this.beginningDate, this.endingDate, this.sprintDurationDays,
  this.sprintDurationHours, this.sprintRealDurationHours, this.sprintRealDurationDays,
  this.sumEffort, this.realEffort, this.velocity, this.active,
  this.state, this.listStories,});

  Sprint.fromApi(Map<String, dynamic> sprintFromApi){
    this.id = sprintFromApi["sprintId"];
    this.name = sprintFromApi["name"]?.replaceAll("\n", "");
    this.description = sprintFromApi["description"]?.replaceAll("\n", "");
    this.businessValue = sprintFromApi["businessValue"];
    this.beginningDate = DateTime.parse(sprintFromApi['beginningDate'].substring(0, 13) + ' -02');
    this.endingDate = DateTime.parse(sprintFromApi['endingDate'].substring(0, 13) + ' -02');
    this.sprintDurationDays = sprintFromApi["sprintDurationDays"];
    this.sprintDurationHours = sprintFromApi["sprintDurationHours"];
    this.sprintRealDurationDays = sprintFromApi["sprintRealDurationDays"];
    this.sumEffort = sprintFromApi["sumEffort"];
    this.realEffort = sprintFromApi["effortTermine"];
    this.realBusinessValue = sprintFromApi["businessValueTerminee"];
    this.sumBusinessValue = sprintFromApi["sumBusinessValue"];
    this.velocity = sprintFromApi["velocity"];
    this.active = sprintFromApi["active"];
    this.state = sprintFromApi["sprintState"] != null ? sprintFromApi["sprintState"]["sprintStateNumber"] : null;
    if(sprintFromApi['noteList'] != null)
      sprintFromApi['noteList'].forEach((comment){
        this.comments.add(Comment.fromApi(comment));
      });
    if(sprintFromApi['followTaskToDo'] != null)
      sprintFromApi['followTaskToDo'].forEach((followTask){
        this.followTasks.add(FollowTask.fromApi(followTask));
      });
  }

  Future<void> reloadComments() async{
    this.comments.clear();
    var commentsFomApi = await CommentService.getAllComments(this);
    commentsFomApi.forEach((comment){
      this.comments.add(Comment.fromApi(comment));
    });
  }

}
