// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** VIEWS ** //
import 'package:origin/views/StoryActivity.dart';
// ** MODEL ** //
import 'package:origin/model/Notification.dart' as n;
import 'package:origin/model/Notification.dart';
import 'package:origin/model/Story.dart';
import 'package:origin/model/User.dart';
// ** SERVICES ** //
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/services/StoryService.dart';
// ** PACKAGES ** //
import 'package:intl/intl.dart';

class NotificationTile extends StatefulWidget {
  NotificationTile({this.notification, this.onDismiss}) : assert(notification != null, onDismiss != null);
  final n.Notification notification;
  final Function onDismiss;

  @override
  _NotificationTileState createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>{

  bool _isLoading = true;
  List<TextSpan> content = List<TextSpan>();
  Function onTap;

  _buildNotificationContent() async{
    User _user = await AuthenticationService.getUser();
    switch(widget.notification.type){
      case NotificationType.Sprint_stateUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "a modifié l'état du sprint "),
          TextSpan(text: "${widget.notification.title.split("\$").last} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "en "),
          TextSpan(text: "${OriginConstants.sprintStateToText[int.parse(widget.notification.newState)]}",
              style: TextStyle(fontWeight: FontWeight.bold, color: OriginConstants.sprintStateToColor[int.parse(widget.notification.newState)]))
        ];
        break;
      case NotificationType.Role_update:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "vous a fait passer "),
          TextSpan(text: widget.notification.oldState != "" ? "de " : ""),
          TextSpan(text: widget.notification.oldState != "" ? "${widget.notification.oldState} " : "", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: widget.notification.oldState != "" ? "à " : ""),
          TextSpan(text: "${widget.notification.newState}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Rights_update:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "a "),
          TextSpan(text: "${widget.notification.newState} "),
          TextSpan(text: "le droit "),
          TextSpan(text: "${widget.notification.oldState} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "au rôle "),
          TextSpan(text: "${widget.notification.title}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Project_scrumUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "a défini "),
          TextSpan(text: "${widget.notification.newState} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "comme nouveau scrum master du projet "),
          TextSpan(text: "${widget.notification.title}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Project_assignedTo:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          widget.notification.newState.contains(_user.username) ? TextSpan(text: "vous a ajouté au projet ") : TextSpan(text: "vous a retiré du projet "),
          TextSpan(text: "${widget.notification.title}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Story_stateUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "a modifié l'état de la story "),
          TextSpan(text: "${widget.notification.title} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "en "),
          TextSpan(text: "${OriginConstants.storyStateToText[int.parse(widget.notification.newState)]}",
              style: TextStyle(fontWeight: FontWeight.bold, color: OriginConstants.storyStateToColor[int.parse(widget.notification.newState)]))
        ];
        break;
      case NotificationType.Story_memberUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          widget.notification.newState.contains(_user.username) ? TextSpan(text: "vous a ajouté à la story ") : TextSpan(text: "vous a retiré de la story "),
          TextSpan(text: "${widget.notification.title}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Task_stateUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "a modifié l'état de la tâche "),
          TextSpan(text: "${widget.notification.title} ", style: TextStyle(fontWeight: FontWeight.bold)), //TextSpan(text: "${task.title.length > 30 ? task.title.substring(0, 30)+"..." : task.title} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "en "),
          TextSpan(text: "${OriginConstants.taskStateToText[int.parse(widget.notification.newState)]}",
              style: TextStyle(fontWeight: FontWeight.bold, color: OriginConstants.taskStateToColor[int.parse(widget.notification.newState)]))
        ];
        break;
      case NotificationType.Task_testUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "a "),
          TextSpan(text: "${widget.notification.newState == 'true' ? 'validé' : 'invalidé'} ",
              style: TextStyle(fontWeight: FontWeight.bold, color: widget.notification.newState == 'true' ? Colors.lightGreen : Colors.red)),
          TextSpan(text: "le test "),
          TextSpan(text: "${widget.notification.title}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Project_tuteurUpdate:
        content = <TextSpan>[
          TextSpan(text: "${widget.notification.emetteur} ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "vous a défini comme nouveau tuteur du projet "),
          TextSpan(text: "${widget.notification.title}", style: TextStyle(fontWeight: FontWeight.bold))
        ];
        break;
      case NotificationType.Note_newComment:
      // TODO: Handle this case.
        break;
    }

    switch(widget.notification.type){
      case NotificationType.Role_update:
      case NotificationType.Rights_update:
        if(_user.role.hasRight(Right.UPDATE_ROLE_RIGHTS) || _user.role.hasRight(Right.UPDATE_USER_ROLE)){
          onTap = () => Navigator.pushReplacementNamed(context, OriginConstants.routeUserManagement);
        }
        break;
      case NotificationType.Project_scrumUpdate:
      case NotificationType.Project_assignedTo:
      case NotificationType.Project_tuteurUpdate:
        ProjectService.setCurrentProject(Project.fromApi(await ProjectService.getProjectById(widget.notification.objectId)));
        onTap = () => Navigator.pushReplacementNamed(context, OriginConstants.routeDashboard);
        break;
      case NotificationType.Story_stateUpdate:
      case NotificationType.Story_memberUpdate:
      case NotificationType.Task_stateUpdate:
      case NotificationType.Task_testUpdate:
        Story story;
        try{
          story = Story.fromApi(await StoryService.getStoryById(widget.notification.objectId));
        }catch(exception){
          Toast.alert(context);
        }
        if(story != null)
          onTap = () => Navigator.pushNamed(
            context, OriginConstants.routeStory,
            arguments: ScreenArguments(story, 100, OriginConstants.projectsListViewId),
          );
        break;
      case NotificationType.Note_newComment:
      // TODO: Handle this case.
        break;
      case NotificationType.Sprint_stateUpdate:
      // TODO: Handle this case.
        break;
    }
    if(mounted)
      setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _buildNotificationContent();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? Container() : Dismissible(
      key: Key(widget.notification.id.toString()),
      onDismissed: widget.onDismiss,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
            color: Color(0xFF626c79),
            child: Padding(
                padding: EdgeInsets.all(7),
                child: Column(
                  children: <Widget>[
                    RichText(
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: TextStyle(fontSize: 15.0, color: Colors.white,),
                          children: content,
                        )
                    ),
                    Stack(
                      children: <Widget>[
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(widget.notification.project.length > 20 ? "${widget.notification.project.substring(0, 20)}..." : widget.notification.project, style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic))
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(DateFormat('dd MMM yyyy', 'fr_FR').format(widget.notification.date), style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic))
                        )
                      ],
                    )
                  ],
                )
            )
        ),
      ),
    );
  }
}