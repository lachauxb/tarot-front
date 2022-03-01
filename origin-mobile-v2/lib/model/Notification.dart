// ** AUTO LOADER ** //
import 'User.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Notification {

  int id;
  NotificationType type;
  int objectId;
  String project;
  String title;
  User emetteur;
  DateTime date;
  String oldState;
  String newState;
  bool dismissed = false;

  Notification({this.id, this.type, this.objectId, this.project, this.title, this.emetteur, this.date, this.oldState, this.newState});

  Notification.fromApi(Map<String, dynamic> notifFromApi){
    this.id = notifFromApi["notificationId"];
    this.type = NotificationType.values.firstWhere((e) => e.toString() == "NotificationType.${notifFromApi["type"]}");
    this.objectId = notifFromApi["objectId"];
    this.project = notifFromApi["project"];
    this.title = notifFromApi["title"].trim();
    this.emetteur = notifFromApi["emetteur"] != null ? User.fromApi(notifFromApi["emetteur"]) : null;
    this.date = DateTime.parse(notifFromApi['date']);
    this.oldState = notifFromApi["oldState"].trim();
    this.newState = notifFromApi["newState"].trim();
  }

}

enum NotificationType {
  // general
  Sprint_stateUpdate, // + en tant que tuteur
  Role_update,
  Rights_update,
  Project_scrumUpdate, // + en tant que tuteur
  Project_assignedTo,
  // si je suis assigné à une story
  Story_stateUpdate,
  Story_memberUpdate,
  Task_stateUpdate,
  Task_testUpdate,
  // en tant que tuteur
  Project_tuteurUpdate,
  // si je suis dans un fil de discussion (commentaires)
  Note_newComment
}