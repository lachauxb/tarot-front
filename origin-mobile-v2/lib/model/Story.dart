// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/services/CommentService.dart';
// ** MODEL ** //
import 'package:origin/model/Epic.dart';
import 'package:origin/model/Priority.dart';
import 'package:origin/model/Task.dart';
import 'package:origin/model/User.dart';
import 'package:origin/model/Comment.dart';
// ** OTHERS ** //

class Story {

  int id;
  String name;
  String title;
  String description;
  int vm; // Valeur métier - Business value
  double realEffort = 0;
  double effort;
  double ratio; // vm/effort -> ne semble pas fonctionner dans le back todo
  String commitUrl; // aucune idée de ce que c'est
  DateTime endDate;
  double release; // Utilisé pour le versionnage

  int idStoryState; // StoryState
  int idPriority; // Priority
  int idSprint; // Sprint
  int idActor; // Actor
  int idTheme; // Theme
  int idEpic; // Epic
  List<Task> listTasks = List<Task>();
  List<User> users = List<User>();
  List<Comment> comments = List<Comment>();

  Story({this.id, this.name, this.title,
    this.description, this.vm, this.effort,
    this.ratio, this.commitUrl, this.endDate,
    this.release, this.listTasks, this.idStoryState,
    this.idPriority, this.idSprint, this.idActor,
    this.idTheme, this.idEpic, this.realEffort, this.users, this.comments});

  // construit un objet story à partir du retour du back end
  Story.fromApi(Map<String, dynamic> storyFromApi){
    this.id = storyFromApi['storyId'];
    this.name = storyFromApi['name']?.replaceAll("\n", "");
    this.title = storyFromApi['storyTitle']?.replaceAll("\n", "");
    this.description = storyFromApi['description']?.replaceAll("\n", "");
    this.vm = storyFromApi['businessValue'];
    this.effort = storyFromApi['effort'];
    //ratio: story['ratio'], on récupère NaN ???
    this.commitUrl = storyFromApi['commitUrl'];
    this.endDate = storyFromApi['endingDate'] != null ? DateTime.parse(storyFromApi['endingDate'].substring(0,19)) : null; // exemple: 2019-08-01T12:07:18.015+0000 -> on s'arrête à ..07:18
    this.release = storyFromApi['release'];
    this.idSprint = storyFromApi['sprint'] != null ? storyFromApi['sprint']['sprintId'] : null;
    this.idStoryState = storyFromApi['userStoryState'] != null ? storyFromApi['userStoryState']['userStoryStateNumber'] : null;
    this.idPriority = storyFromApi['priority'] != null ? storyFromApi['priority']['priorityId'] : null;
    this.idEpic = storyFromApi['epicStory'] != null ? storyFromApi['epicStory']['epicStoryId'] : null;
    this.idTheme = this.idEpic != null ? Epic.getById(this.idEpic)?.idTheme : null;
    this.idActor = storyFromApi['actor'] != null ? storyFromApi['actor']['actorId'] : null;
    if(storyFromApi['noteList'] != null) {
      storyFromApi['noteList'].forEach((comment) {
        this.comments.add(Comment.fromApi(comment));
      });
    }
    if(storyFromApi['taskList'] != null) {
      storyFromApi['taskList'].forEach((taskFromApi) {
        Task task = Task.fromApiWithTests(taskFromApi);
        this.listTasks.add(task);
        if(task.taskState == 5)
          this.realEffort = this.realEffort + task.effort;
      });
    }
    if(storyFromApi['userStoryList'] != null) {
      storyFromApi['userStoryList'].forEach((userFromApi) {
        this.users.add(User.fromApi(userFromApi));
      });
    }
  }

  reloadFromShortApi(Map<String, dynamic> storyFromApi){
    this.id = storyFromApi['storyId'];
    this.name = storyFromApi['name'];
    this.title = storyFromApi['storyTitle'];
    this.description = storyFromApi['description'];
    this.vm = storyFromApi['businessValue'];
    this.effort = storyFromApi['effort'];
    this.commitUrl = storyFromApi['commitUrl'];
    this.endDate = storyFromApi['endingDate'] != null ? DateTime.parse(storyFromApi['endingDate'].substring(0,19)) : null; // exemple: 2019-08-01T12:07:18.015+0000 -> on s'arrête à ..07:18
    this.idStoryState = storyFromApi['userStoryState'] != null ? storyFromApi['userStoryState']['userStoryStateNumber'] : null;
    if(storyFromApi['noteList'] != null) {
      this.comments.clear();
      storyFromApi['noteList'].forEach((comment) {
        this.comments.add(Comment.fromApi(comment));
      });
    }
    if(storyFromApi['taskList'] != null) {
      this.listTasks.clear();
      this.realEffort = 0;
      storyFromApi['taskList'].forEach((taskFromApi) {
        Task task = Task.fromApiWithTests(taskFromApi);
        this.listTasks.add(task);
        if(task.taskState == 5)
          this.realEffort = this.realEffort + task.effort;
      });
    }
    if(storyFromApi['userStoryList'] != null) {
      this.users.clear();
      storyFromApi['userStoryList'].forEach((userFromApi) {
        this.users.add(User.fromApi(userFromApi));
      });
    }
  }

  Future<void> reloadComments() async{
    this.comments.clear();
    var commentsFomApi = await CommentService.getAllComments(this);
    commentsFomApi.forEach((comment){
      this.comments.add(Comment.fromApi(comment));
    });
  }

  /// CONSTANTES DE TRI DES STORIES ///
  static const priorityComparison = 1;
  static const stateComparison = 2;
  static const vmComparison = 3;
  static const effortComparison = 4;
  static const sortAsc = 49;
  static const sortDesc = 50;
  /// FONCTION A UTILISER POUR TRIER UNE LISTE D'US ///
  static List<Story> sortStoryList(List<Story> stories, List<int> valuesToCompare, int sortOrder){
    for(int valueToCompare in valuesToCompare){
      switch(valueToCompare){
        case priorityComparison:
          return _sortListOnPriority(stories, sortOrder);
          break;
        case stateComparison:
          return _sortListOnState(stories, sortOrder);
          break;
        case vmComparison:
          return _sortListOnVM(stories, sortOrder);
          break;
        case effortComparison:
          return _sortListOnEffort(stories, sortOrder);
          break;
      }
    }
    return List<Story>();
  }

  // tri une liste de story sur la priorité
  static List<Story> _sortListOnPriority(List<Story> stories, int sortOrder){
    Story dump;
    for(Story _ in stories){
      for(var i = 0; i < stories.length-1; i++){
        if(sortOrder == sortAsc){
          if(Priority.getById(stories[i].idPriority).number > Priority.getById(stories[i+1].idPriority).number){
            dump = stories[i+1]; stories[i+1] = stories[i]; stories[i] = dump;
          }
        }else if(sortOrder == sortDesc){
          if(Priority.getById(stories[i].idPriority).number <= Priority.getById(stories[i+1].idPriority).number){
            dump = stories[i+1]; stories[i+1] = stories[i]; stories[i] = dump;
          }
        }
      }
    }
    return stories;
  }

  // tri une liste de story sur l'état de l'US
  static List<Story> _sortListOnState(List<Story> stories, int sortOrder){
    Story dump;
    for(Story _ in stories){
      for(var i = 0; i < stories.length-1; i++){
        if(sortOrder == sortAsc){
          if(stories[i].idStoryState > stories[i+1].idStoryState){
            dump = stories[i+1]; stories[i+1] = stories[i]; stories[i] = dump;
          }
        }else if(sortOrder == sortDesc){
          if(stories[i].idStoryState <= stories[i+1].idStoryState){
            dump = stories[i+1]; stories[i+1] = stories[i]; stories[i] = dump;
          }
        }
      }
    }
    return stories;
  }

  // tri une liste de story sur la VM
  static List<Story> _sortListOnVM(List<Story> stories, int sortOrder){
    Story dump;
    for(Story _ in stories){
      for(var i = 0; i < stories.length-1; i++){
        if(sortOrder == sortAsc ? stories[i+1].vm > stories[i].vm : stories[i+1].vm <= stories[i].vm){
          dump = stories[i+1]; stories[i+1] = stories[i]; stories[i] = dump;
        }
      }
    }
    return stories;
  }

  // tri une liste de story sur l'effort
  static List<Story> _sortListOnEffort(List<Story> stories, int sortOrder) {
    Story dump;
    for (Story _ in stories) {
      for (var i = 0; i < stories.length - 1; i++) {
        if (sortOrder == sortAsc ? stories[i + 1].effort > stories[i].effort : stories[i + 1].effort <= stories[i].effort) {
          dump = stories[i + 1];
          stories[i + 1] = stories[i];
          stories[i] = dump;
        }
      }
    }
    return stories;
  }

  @override
  String toString(){
    return this.title;
  }

}