// ** AUTO LOADER ** //
import 'dart:async';

import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Player.dart';
import 'package:origin/model/Story.dart';
// ** MODEL ** //
import 'package:origin/model/Theme.dart' as t;
import 'package:origin/model/PlanningPoker.dart';
import 'package:origin/model/User.dart';
import 'package:origin/services/PlanningPokerService.dart';
import 'package:origin/widgets/PlanningPoker/StopPlanningPokerButton.dart';

import '../UserTrigram.dart';
// ** PACKAGES ** //

// ignore: must_be_immutable
class WaitingScreenView extends StatefulWidget {

  PlanningPoker planningPoker;
  final Project project;
  final User currentUser;
  bool withEffort;
  List<t.Theme> selectedThemes;
  Function onStartPressed;

  WaitingScreenView(this.planningPoker, this.project, this.currentUser, this.withEffort, this.selectedThemes, this.onStartPressed) : assert(planningPoker != null && project != null && currentUser != null);

  @override
  _WaitingScreenViewState createState() => _WaitingScreenViewState();
}

class _WaitingScreenViewState extends State<WaitingScreenView>{

  PlanningPoker planningPoker;

  bool isUpdatingPKState = false;
  int timeLeft = 15; // 15s

  @override
  void initState() {
    planningPoker = widget.planningPoker;

    SocketIOHandler.subscribe("storiesUpdate", (List response){
      planningPoker.stories = List();
      setState(() => response.forEach((storyFromApi) => planningPoker.stories.add(Story.fromApi(storyFromApi))) );
      if(planningPoker.stories.length == 0 && planningPoker.host == widget.currentUser){
        Toast(context: context, message: "Aucune US n'a été trouvée pour vos critères", type: ToastType.INFO, duration: const Duration(seconds: 2)).show();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<UserTrigram> onlineUsers = List(); List<UserTrigram> expectedUsers = List(); List<UserTrigram> observers = List();
    if(planningPoker != null) {

      UserTrigram hostTrigram = UserTrigram(user: planningPoker.host, icon: OriginIcons.crown, iconColor: Colors.yellow[700]);
      planningPoker.players.contains(planningPoker.host) ? onlineUsers.add(hostTrigram) : expectedUsers.add(hostTrigram);

      planningPoker.players.forEach((Player player){
        if(player.isObserver){
          observers.add(UserTrigram(user: player.user, icon: OriginIcons.eye, iconColor: solutecRed));
        }else if(player.user != planningPoker.host){
          onlineUsers.add(UserTrigram(user: player.user));
        }
      });

      planningPoker.expectedPlayers.forEach((expectedPlayer){
        if(!planningPoker.players.contains(expectedPlayer) && expectedPlayer != planningPoker.host){
          expectedUsers.add(UserTrigram(user: expectedPlayer));
        }
      });

      onlineUsers.addAll(observers);
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                    children: <Widget>[
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          color: solutecRed,
                          icon: Icon(OriginIcons.logout_2),
                          tooltip: "Quitter le PK"
                      ),
                      widget.currentUser == planningPoker.host ? IconButton( // ignore -> permet de centrer "Salle d'attente"
                          iconSize: 0,
                          onPressed: null,
                          icon: Icon(Icons.cancel)
                      ) : Container()
                    ]
                ),
                Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200].withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Text("Salle d'attente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                ),
                Row(
                    children: <Widget>[
                      widget.currentUser == planningPoker.host ? StopPlanningPokerButton() : Container(),
                      widget.currentUser == planningPoker.host ? IconButton(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (_) => SettingsDialog(onClosed: (bool withEffort){
                                widget.withEffort = withEffort;
                                PlanningPokerService.updatePlanningPokerParams(widget.project.id, widget.withEffort, widget.selectedThemes);
                              }, selectedThemes: widget.selectedThemes, withEffort: widget.withEffort)
                          ),
                          color: solutecRed,
                          icon: Icon(Icons.settings),
                          tooltip: "Paramétrage du PK"
                      ) : (!widget.project.members.contains(widget.currentUser) ? IconButton(
                          onPressed: () => PlanningPokerService.updateObserver(widget.project.id, widget.currentUser.id),
                          color: observers.any((observer) => observer.user == widget.currentUser) ? solutecRed : disabledSolutecRed,
                          iconSize: 32,
                          icon: Icon(observers.any((observer) => observer.user == widget.currentUser) ? OriginIcons.eye : OriginIcons.eye_off),
                          tooltip: "Observateur / Participant"
                      ) : Container())
                    ]
                )
              ]
          ),
          SizedBox(height: 25),
          Container(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey[200].withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                        children: <Widget>[
                          Text("En ligne", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Wrap(children: onlineUsers)
                        ]
                    ),
                    Column(
                        children: <Widget>[
                          Text("En attente", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Wrap(children: expectedUsers)
                        ]
                    )
                  ]
              )
          ),
          SizedBox(height: 30),
          Container(
              child: Stack(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.center,
                        child: planningPoker.host == widget.currentUser ? RaisedButton(
                            onPressed: !isUpdatingPKState && planningPoker.stories.length > 0 ? (){
                              setState(() => isUpdatingPKState = true);
                              widget.onStartPressed();
                            } : null,
                            elevation: 5.0,
                            color: solutecRed,
                            disabledColor: disabledSolutecRed,
                            padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                            child: isUpdatingPKState ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ) : Text("Lancer", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))
                        ) : Container() // todo lancement en cours avec spinner
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200].withOpacity(0.5),
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Text(planningPoker.stories.length.toString()+" US", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                        )
                    )
                  ]
              )
          ),
          SizedBox(height: 10)
        ]
    );
  }

}

/// DIALOG PARAMETRAGE
// ignore: must_be_immutable
class SettingsDialog extends StatefulWidget {

  final Function onClosed;
  List<t.Theme> selectedThemes;
  bool withEffort;
  SettingsDialog({this.onClosed, this.selectedThemes, this.withEffort});

  @override
  _SettingsDialogState createState() => new _SettingsDialogState();
}
class _SettingsDialogState extends State<SettingsDialog> {

  List<t.Theme> themes;

  @override
  void initState() {
    themes = t.Theme.getAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OriginDialog(
        title: "Paramétrage",
        content: <Widget>[
          Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("User Story", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            GestureDetector(
                                onTap: () => setState(() => widget.withEffort = false),
                                child: Row(
                                    children: <Widget>[
                                      Radio(
                                          value: false,
                                          groupValue: widget.withEffort,
                                          onChanged: (bool value) => setState(() => widget.withEffort = value)
                                      ),
                                      Text("Sans effort")
                                    ]
                                )
                            ),
                            GestureDetector(
                                onTap: () => setState(() => widget.withEffort = true),
                                child: Row(
                                    children: <Widget>[
                                      Radio(
                                          value: true,
                                          groupValue: widget.withEffort,
                                          onChanged: (bool value) => setState(() => widget.withEffort = value)
                                      ),
                                      Text("Avec effort")
                                    ]
                                )
                            )
                          ]
                      )
                    ]
                ),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Thèmes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      DropdownSelector(
                          listOfValues: themes,
                          selectedValues: widget.selectedThemes
                      )
                    ]
                )
              ]
          )
        ],
        bottom: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Text("Valider", style: TextStyle(color: Colors.white)),
            elevation: 5.0,
            color: Colors.green,
            disabledColor: Colors.green[100],
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
            onPressed: (){
              if(widget.onClosed != null)
                widget.onClosed(widget.withEffort);
              Navigator.of(context, rootNavigator: true).pop(true);
            }
        )
    );
  }

}

