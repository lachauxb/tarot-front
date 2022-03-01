// ** AUTO LOADER ** //
import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:origin/config/auto_loader.dart';
import 'package:flutter/services.dart';
import 'package:origin/model/Player.dart';
import 'package:origin/widgets/PlanningPoker/LoadingScreen.dart';
import 'package:origin/widgets/PlanningPoker/PausingScreen.dart';
import 'package:origin/widgets/PlanningPoker/PlayingScreen.dart';
// ** PACKAGES ** //
import 'package:stomp_dart_client/stomp.dart';
import 'dart:async';
// ** SERVICES ** //
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/services/PlanningPokerService.dart';
// ** MODEL ** //
import 'package:origin/model/Theme.dart' as t;
import 'package:origin/model/User.dart';
import 'package:origin/model/PlanningPoker.dart';
// ** OTHERS ** //
import 'package:origin/widgets/PlanningPoker/ClosingScreen.dart';
import 'package:origin/widgets/PlanningPoker/WaitingScreen.dart';

class PlanningPokerActivity extends StatefulWidget {
  @override
  PlanningPokerActivityState createState() => PlanningPokerActivityState();
}

class PlanningPokerActivityState extends State<PlanningPokerActivity>{

  Project project;
  User currentUser;
  PlanningPoker planningPoker;

  bool isLoading = true;
  bool withEffort = false;
  List<t.Theme> selectedThemes = t.Theme.getAll();

  StreamSubscription _connectionChangeStream;
  Toast networkErrorToast;
  bool _isDialogOpen = false;

  // init webSocket and subscribe to it
  void _initWebSocket() async{
    SocketIOHandler.open(project, currentUser, (StompClient client){

      // All subscribes to websocket messages
      SocketIOHandler.subscribe("memberUpdate", (response){
        if(planningPoker == null || planningPoker.state != PlanningPokerState.EN_COURS){
          if(response == null) setState(() => planningPoker = PlanningPoker());
          else{
            if(planningPoker != null){
              planningPoker.players = List();
              response.forEach((playerFromApi) => planningPoker.players.add(Player.fromApi(playerFromApi)));
              if(planningPoker.players.length < 1)
                planningPoker = null;
              setState((){});
            }else{ // si on a pas de pk, c'est qu'on l'a pas encore chargé et qu'on a juste rejoint pour l'instant
              PlanningPokerService.getPlanningPoker(project.id).then((pkFromApi){
                planningPoker = PlanningPoker.fromApi(pkFromApi);
                setState(() => isLoading = false);
              });
            }
          }
        }else if(planningPoker != null && response != null){
          List<Player> players = List<Player>();
          response.forEach((playerFromApi) => players.add(Player.fromApi(playerFromApi)));
          if(!players.contains(planningPoker.host)){
            setState((){});
          }
        }
      });

      SocketIOHandler.send("join");

      SocketIOHandler.subscribe("planningPokerUpdate", (planningPokerState){
        if(planningPoker != null){
          setState(() => planningPoker.state = PlanningPokerState.values.firstWhere((pkState) => pkState.toString().contains(planningPokerState)) );
        }
      });

    });
  }

  @override
  void initState() {
    ConnectionListener connectionStatus = ConnectionListener.getInstance();
    if(!connectionStatus.hasConnection){
      Navigator.of(context).pop();
    }else{
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      ProjectService.getCurrentProject().then((project){
        this.project = project;
        AuthenticationService.getUser().then((user){
          currentUser = user;
          _initWebSocket();
        });
      });

      _connectionChangeStream = ConnectionListener.getInstance().connectionChange.listen((hasConnection) {
        if(!hasConnection && networkErrorToast == null){
          networkErrorToast = Toast(context: context, message: "Votre appareil n'est plus connecté à Internet", title: "Erreur réseau", type: ToastType.WARNING, onTap: (Flushbar<dynamic> flushbar){
            networkErrorToast = null;
            Navigator.pop(context);
          });
          networkErrorToast.show();
        }else if(hasConnection && networkErrorToast != null){
          planningPoker = null;
          setState(() => isLoading = true);
          _initWebSocket();
          networkErrorToast.dismiss();
          networkErrorToast = null;
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SocketIOHandler.close();
    _connectionChangeStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OriginScaffold(
        withoutAppBar: true,
        currentViewId: OriginConstants.planningPokerViewId,
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: new ColorFilter.mode(Colors.grey.withOpacity(0.5), BlendMode.dstATop),
                        image: AssetImage('assets/planning_poker_background.jpg'),
                        fit: BoxFit.cover
                    )
                ),
                child: !isLoading && planningPoker == null ? ClosingScreenView("Une erreur est survenue") : _getScreenToShow()
            )
        )
    );
  }

  Widget _getScreenToShow() {
    if(isLoading){
      return LoadingScreenView();
    }else{
      if(planningPoker.state == PlanningPokerState.NULL){ // si équivalent à NULL, il faut demander si on commence un nouveau PK ou si on continue celui là
        if(!_isDialogOpen){
          _isDialogOpen = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => showDialog(context: context, barrierDismissible: false, builder: (_) => _getPKResumeDialog()).then((_) => _isDialogOpen = false) );
        }
        return Container();
      } else if(planningPoker.state == PlanningPokerState.PARAMETRAGE){
        return planningPoker.host != null ? WaitingScreenView(planningPoker, project, currentUser, withEffort, selectedThemes, (){
          SocketIOHandler.send("updatePlanningPokerState", body: PlanningPokerState.EN_COURS.toString().substring(19));
        }) : ClosingScreenView("L'hôte a quitté la session");
      } else if(!planningPoker.players.contains(planningPoker.host)){
        return PausingScreenView("L'hôte s'est absenté");
      } else if(planningPoker.state == PlanningPokerState.EN_COURS) {
        return PlayingScreenView(planningPoker: planningPoker, currentUser: currentUser);
      } else if(planningPoker.state == PlanningPokerState.TERMINE){
        SocketIOHandler.close();
        return ClosingScreenView("Le planning poker est terminé");
      } else{
        return ClosingScreenView("Une erreur est survenue");
      }
    }
  }

  Widget _getPKResumeDialog(){
    return WillPopScope(
        onWillPop: () async => false, // évite que le dialog se ferme avec le bouton back d'android
        child: SimpleDialog(
            title: Text("Un planning poker vide est déjà en cours, que souhaitez-vous faire ?", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
            contentPadding: EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        onPressed: (){
                          Navigator.of(context).pop(); // pop du dialog first
                          Navigator.of(context).popUntil((route) => route.settings.name != OriginConstants.routePlanningPoker);
                        },
                        child: Text("Quitter", style: TextStyle(color: solutecRed, fontSize: 16))
                    ),
                    SizedBox(
                        width: 150,
                        height: 40,
                        child: RaisedButton(
                            color: solutecRed,
                            onPressed: (){
                              setState(() => isLoading = true);
                              planningPoker = null;
                              SocketIOHandler.send("join", body: "new");
                              Navigator.of(context).pop();
                            },
                            child: Text("Nouveau", style: TextStyle(color: Colors.white, fontSize: 18))
                        )
                    ),
                    SizedBox(
                        width: 150,
                        height: 40,
                        child: RaisedButton(
                            color: solutecRed,
                            onPressed: (){
                              setState(() => isLoading = true);
                              planningPoker = null;
                              SocketIOHandler.send("join", body: "resume");
                              Navigator.of(context).pop();
                            },
                            child: Text("Continuer", style: TextStyle(color: Colors.white, fontSize: 18))
                        )
                    )
                  ]
              )
            ]
        )
    );
  }

}
