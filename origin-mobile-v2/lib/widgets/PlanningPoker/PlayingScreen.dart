// ** AUTO LOADER ** //
import 'package:flutter/rendering.dart';
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/PlanningPoker.dart';
import 'package:origin/model/User.dart';
import 'package:origin/model/Player.dart';
import 'package:origin/model/Round.dart';
// ** WIDGETS ** //
import 'package:origin/widgets/PlanningPoker/EffortCard.dart';
import 'package:origin/widgets/PlanningPoker/PausingScreen.dart';
import 'package:origin/widgets/UserTrigram.dart';
// ** SERVICES ** //
import 'package:origin/services/PlanningPokerService.dart';
// ** PACKAGES ** //
import 'dart:async';
import 'dart:math';

import 'StopPlanningPokerButton.dart';

class PlayingScreenView extends StatefulWidget {

  final PlanningPoker planningPoker;
  final User currentUser;
  PlayingScreenView({this.planningPoker, this.currentUser}) : assert(planningPoker != null && currentUser != null);

  @override
  _PlayingScreenViewState createState() => _PlayingScreenViewState();
}

class _PlayingScreenViewState extends State<PlayingScreenView>{

  Project project;
  PlanningPoker planningPoker;
  Round round;

  List<Player> waitingList = List();

  List<Widget> firstRow;
  List<Widget> secondRow;
  List<double> selectedValues = List<double>();

  bool isLoading = true;
  bool everyoneReady = false;
  bool hasToWait = false;

  Timer timer;
  double timeLeft = -1; // 1m30
  Timer anticipatedTimer;
  double anticipatedTimeLeft = -1; // 1m30

  double selected = -1;

  ScrollController listViewScrollController = ScrollController();
  bool showLeftArrow;
  bool showRightArrow;

  @override
  void initState() {

    planningPoker = widget.planningPoker;
    firstRow = List<Widget>();
    secondRow = List<Widget>();

    listViewScrollController.addListener(_scrollListener);

    SocketIOHandler.subscribe("memberUpdate", (response){
      response.forEach((playerFromApi){
        Player player = Player.fromApi(playerFromApi);
        if(player.isObserver){
          planningPoker.players.add(player);
        }else if(!planningPoker.players.contains(player)){
          waitingList.add(player);
        }
      });
    });

    SocketIOHandler.subscribe("playerPickUpdate", (Map<String, dynamic> playersPicks){
      playersPicks.forEach((String playerId, dynamic playerPick) {
        round.selectedEffortsByPlayer[int.parse(playerId)] = double.parse("$playerPick");
      });
      if(!round.selectedEffortsByPlayer.containsValue(-1)){
        anticipatedTimeLeft = 4;
        if(anticipatedTimer != null)
          anticipatedTimer.cancel();
        anticipatedTimer = Timer.periodic(const Duration(milliseconds: 50), (Timer _timer) {
          if(anticipatedTimeLeft > 0 && mounted) {
            setState(() => anticipatedTimeLeft -= 0.05);
          }else {
            anticipatedTimer.cancel();
            endPicking();
          }
        });
      }
      if(mounted)
        setState(() {});
    });

    SocketIOHandler.subscribe("roundStarting", (Map<String, dynamic> roundParameters) {
      if(roundParameters != null) {
        Round newRound = Round.fromApi(roundParameters);
        if(round != null && round.story.id != newRound.story.id)
          planningPoker.usDone++;
        round = newRound;
        startRound();
      }
    });

    SocketIOHandler.subscribe("pickingPhaseStopped", (String message) {
      endPicking();
    });

    SocketIOHandler.subscribe("hostPickUpdate", (double hostPick) {
      selected = hostPick;
      arrangeSelectedCards();
      setState(() {});
    });

    ProjectService.getCurrentProject().then((currentProject){
      project = currentProject;
      PlanningPokerService.getPlanningPoker(project.id).then((planningPokerFromApi){
        planningPoker = PlanningPoker.fromApi(planningPokerFromApi);
        if(planningPoker.round != null) {
          round = planningPoker.round;
          startRound();
        }else{
          setState((){});
        }
      });
    });

    super.initState();
  }

  void _scrollListener() {
    if (listViewScrollController.offset >= listViewScrollController.position.maxScrollExtent &&
        !listViewScrollController.position.outOfRange) {
      setState(() {
        showRightArrow = false;
      });
    }
    if (listViewScrollController.offset <= listViewScrollController.position.minScrollExtent &&
        !listViewScrollController.position.outOfRange) {
      setState(() {
        showLeftArrow = false;
      });
    }
    if(listViewScrollController.offset > listViewScrollController.position.minScrollExtent &&
    !showLeftArrow)
      setState(() {
        showLeftArrow = true;
      });
    if(listViewScrollController.offset < listViewScrollController.position.maxScrollExtent &&
        !showRightArrow)
      setState(() {
        showRightArrow = true;
      });
  }

  void startRound(){
    isLoading = false;
    everyoneReady = false;
    showLeftArrow = null;
    showRightArrow = null;
    timeLeft = 90;
    selected = -1;
    arrangeCards();
    if(timer != null)
      timer.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 50), (Timer _timer) {
      if(timeLeft > 0 && mounted) {
        setState(() => timeLeft -= 0.05);
      } else {
        timer.cancel();
        endPicking();
      }
    });
    setState(() => hasToWait = !planningPoker.players.firstWhere((player) => player.user == widget.currentUser).isObserver && !round.selectedEffortsByPlayer.keys.contains(widget.currentUser.id));
  }

  void endPicking(){
    timeLeft = -1;
    if (timer != null){
      timer.cancel();
    }
    anticipatedTimeLeft = -1;
    if(anticipatedTimer != null) {
      anticipatedTimer.cancel();
    }
    everyoneReady = true;
    selected = -1;
    arrangeSelectedCards();
    if(mounted)
      setState(() {});
  }

  @override
  void dispose() {
    if(timer != null && timer.isActive)
      timer.cancel();
    if(anticipatedTimer != null && anticipatedTimer.isActive)
      anticipatedTimer.cancel();
    super.dispose();
  }

  void arrangeCards(){
    firstRow.clear();
    secondRow.clear();
    if(round.effortsList.length > 2) {
      int i = 0;
      for (i; i <= round.effortsList.length / 2 - 0.5; i++) {
        firstRow.add(EffortCard(
          effortValue: round.effortsList[i],
          onTap: onTap,
          selected: selected == round.effortsList[i],
        ));
      }
      for (i; i < round.effortsList.length; i++) {
        secondRow.add(EffortCard(
          effortValue: round.effortsList[i],
          onTap: onTap,
          selected: selected == round.effortsList[i],
        ));
      }
    } else {
      round.effortsList.forEach((double value) {
        firstRow.add(EffortCard(
          effortValue: value,
          onTap: onTap,
          selected: selected == value,
        ));
      });
    }
  }

  void onTap(double effortValue) {
    if (selected != effortValue && !planningPoker.players.firstWhere((player) => player.user.id == widget.currentUser.id).isObserver) {
      selected = effortValue;
      arrangeCards();
      setState(() {});
      SocketIOHandler.send("updatePlayerPick", body: effortValue.toString());
    }
  }

  void endRound(List<double> nextRoundValues){
    PlanningPokerService.endRound(nextRoundValues, project.id);
    setState(() {
      if(waitingList.length > 0) {
        waitingList.forEach((Player player) => planningPoker.players.add(player));
        waitingList = List();
      }
      hasToWait = false;
      isLoading = true;
    });
  }

  void onTapSelecting(double effortValue) {
    if (selected != effortValue && widget.currentUser == planningPoker.host) {
      SocketIOHandler.send("updateHostPick", body: effortValue.toString());
    }
  }

  void arrangeSelectedCards(){
    firstRow.clear();
    secondRow.clear();
    if(selectedValues.isNotEmpty)
      selectedValues.clear();

    List<double> temp = round.selectedEffortsByPlayer.values.toList();
    temp.removeWhere((element) => element == -1);
    if(temp.isNotEmpty) {
      int minIndex = OriginConstants.planningPokerValues.indexOf(
          temp.reduce(min));
      if (minIndex > 0)
        minIndex --;
      int maxIndex = OriginConstants.planningPokerValues.indexOf(
          temp.reduce(max)) + 1;
      if (maxIndex < OriginConstants.planningPokerValues.length)
        maxIndex ++;
      selectedValues = OriginConstants.planningPokerValues.getRange(minIndex, maxIndex).toList();
    } else
      selectedValues = List.from(OriginConstants.planningPokerValues);

    selectedValues.forEach((double possibleValue) {
      List<Widget> userRowList = List<Widget>();
      List<Widget> userColumnList = List<Widget>();
      int count = 0;
      round.selectedEffortsByPlayer.forEach((userId, userEffort) {
        if(possibleValue == userEffort && userRowList.length < 2){
          userRowList.add(UserTrigram(user: planningPoker.players.where((player) => player.user.id == userId).first.user));
        } else if(possibleValue == userEffort)
          count ++;
      });

      Widget row = Row(mainAxisSize: MainAxisSize.min, children: userRowList);
      userColumnList.add(row);

      if(count > 0)
        userColumnList.add(Text("+$count"));

      Widget userColumn = Column(mainAxisSize: MainAxisSize.min, children: userColumnList);
      firstRow.add(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: EffortCard(
                  effortValue: possibleValue,
                  selected: possibleValue == selected,
                  onTap: onTapSelecting,
                ),
              ),
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 0.65*3,
                  child: Container(
                    margin: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200].withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: userColumn,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> listUsersWaitedUpon(){
    List<Widget> usersReadyTrigram = List<Widget>();
    List<Widget> usersNotReadyTrigram = List<Widget>();
    List<Widget> observersTrigram = List<Widget>();
    List<Widget> usersTrigram = List<Widget>();
    planningPoker.players.forEach((player) {
      if(player.user != widget.currentUser){
        if(player.isObserver)
          observersTrigram.add(UserTrigram(user: player.user, icon: Icons.remove_red_eye, iconColor: solutecRed));
        else if(round.selectedEffortsByPlayer[player.user.id] == -1)
          usersNotReadyTrigram.add(UserTrigram(user: player.user, icon: Icons.clear, iconColor: Colors.red));
        else
          usersReadyTrigram.add(UserTrigram(user: player.user, icon: Icons.check, iconColor: Colors.green));
      }
    });
    int maxTrigram = ((MediaQuery.of(context).size.width / 4) / OriginConstants.userTrigramSize.width).floor();
    usersTrigram.addAll(usersNotReadyTrigram);
    usersTrigram.addAll(usersReadyTrigram);
    usersTrigram.addAll(observersTrigram);
    if(maxTrigram < usersTrigram.length) {
      usersTrigram = usersTrigram.getRange(0, maxTrigram).toList();
      usersTrigram.add(Text("+${usersTrigram.length - maxTrigram}"));
    }
    return usersTrigram;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topRight,
          child: widget.currentUser == planningPoker.host ? StopPlanningPokerButton() : Container(),
        ),
        Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(solutecRed),
          ),
        ),
      ],
    )

    /** Ecran d'attente **/
    : hasToWait ? PausingScreenView("Un round est déjà en cours")

    /** Page Validation **/
        : everyoneReady ? LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){

      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            /** header **/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    onPressed: () => _onDisconnect(),
                    color: solutecRed,
                    icon: Icon(OriginIcons.logout_2)
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200].withOpacity(0.5),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: constraints.maxWidth - 150,
                        alignment: Alignment.center,
                        child: Text(round.story.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth - 150,
                        child: round.story.description != null ? Text(round.story.description,
                          style: TextStyle(fontSize: 18,),
                          maxLines: 2,
                        ) : null,
                      ),
                      Container(
                        width: 150,
                      ),
                    ],
                  ),
                ),
                widget.currentUser == planningPoker.host ? IconButton(
                  onPressed: _onClosePK,
                  color: solutecRed,
                  icon: Icon(Icons.cancel),
                  tooltip: "Mettre fin au PK",
                ) : IconButton( // ignore -> permet de centrer "Salle d'attente"
                  iconSize: 0,
                  onPressed: null,
                  icon: Icon(Icons.cancel),
                ),
              ],
            ),

            /** Cartes **/
            Expanded(
              flex: 1,
              child: Container(
                width: constraints.maxWidth,
                alignment: Alignment.center,
                child:LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                  if(showRightArrow == null || showLeftArrow == null) {
                    showRightArrow =  constraints.maxWidth < (constraints.maxHeight * 3.0 / 4.0 * 0.65 + 10.0) * firstRow.length;
                    showLeftArrow = false;
                  }
                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: firstRow.length,
                          controller: listViewScrollController,
                          itemBuilder: (context, index){
                            return firstRow[index];
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: <Widget>[
                            Expanded(flex: 3,
                              child: Align(alignment: Alignment.centerLeft,
                                child: showLeftArrow ? IconButton(
                                  icon: Icon(Icons.chevron_left, color: solutecGrey, size: 35,),
                                  iconSize: 35,
                                  padding: EdgeInsets.all(2.0),
                                  onPressed: () => listViewScrollController.animateTo(
                                    listViewScrollController.position.minScrollExtent,
                                    duration: Duration(milliseconds: 1000),
                                    curve: Curves.easeOutCubic,
                                  ),
                                ) : Container(),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: <Widget>[
                            Expanded(flex: 3,
                              child: Align(alignment: Alignment.centerRight,
                                child: showRightArrow ? IconButton(
                                  icon: Icon(Icons.chevron_right, color: solutecGrey, size: 35,),
                                  iconSize: 35,
                                  onPressed: () => listViewScrollController.animateTo(
                                    listViewScrollController.position.maxScrollExtent,
                                    duration: Duration(milliseconds: 1000),
                                    curve: Curves.easeOutCubic,
                                  ),
                                ) : Container(),
                              ),
                            ),
                            Expanded(flex: 1, child: Container()),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            /** Pied **/
            Container(
              width: constraints.maxWidth,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200].withOpacity(0.5),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("VM: ${round.story.vm}", style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600, fontSize: 15.0),),
                          SizedBox(width: 30),
                          Text("US: ${planningPoker.usDone}/${planningPoker.initialStoryCount}", style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600, fontSize: 15.0),),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: widget.currentUser == planningPoker.host ? RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      disabledColor: Color(0xFFC8E6C9),
                      elevation: 5.0,
                      color: Colors.green,
                      child: Text("Assigner la valeur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15.0),),
                      onPressed: selected >= 0 ? () => endRound([selected]) : null,
                    ): Container(),
                  ),
                  Align(
                    alignment: Alignment(0.5, 0.5),
                    child:  widget.currentUser == planningPoker.host ? PopupMenuButton(
                      child: Container(
                        child: Text("Autres actions", style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),),
                      ),
                      itemBuilder: (BuildContext context){
                        return <String>['Rejouer ces cartes', 'Rejouer toutes les cartes', 'Passer la Story',].map((String action){
                          return PopupMenuItem(
                            value: action,
                            child: Text(action),
                          );
                        }).toList();
                      },
                      onSelected: (String selectedAction){
                        switch(selectedAction) {
                          case 'Rejouer ces cartes': {endRound(selectedValues);}
                          break;
                          case 'Rejouer toutes les cartes': {endRound(List.from(OriginConstants.planningPokerValues));}
                          break;
                          case 'Passer la Story': {endRound([round.story.effort]);}
                          break;
                          default: {}
                          break;
                        }
                      },
                    ) : Container(),
                  ),
                ],
              ),
            )
          ]
      );
    })

    /** Page Selection **/
        : LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            /** header **/
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      onPressed: () => _onDisconnect(),
                      color: solutecRed,
                      icon: Icon(OriginIcons.logout_2)
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200].withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: constraints.maxWidth - 150,
                          alignment: Alignment.center,
                          child: Text(round.story.title,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                            maxLines: 2,
                          ),
                        ),
                        Container(
                          width: constraints.maxWidth - 150,
                          child: round.story.description != null ? Text(round.story.description,
                            style: TextStyle(fontSize: 18,),
                            maxLines: 2,
                          ) : null,
                        ),
                      ],
                    ),
                  ),
                  Stack(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: timeLeft / 90,
                                valueColor: AlwaysStoppedAnimation(solutecRed)
                            )
                        ),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 4, left: 6),
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text("${timeLeft.round() + 1}", style: TextStyle(fontSize: 20, color: solutecRed))
                            )
                        )
                      ]
                  )
                ]
            ),

            /** Cartes **/
            Expanded(flex: 1, child: Container(
              width: constraints.maxWidth,
              child:LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: firstRow,
                );
              }),
            ),),
            Expanded(flex: 1, child: Container(
              width: constraints.maxWidth,
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: secondRow,
                );
              }),
            ),),

            /** Pied **/
            Container(
              width: constraints.maxWidth,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: listUsersWaitedUpon(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200].withOpacity(0.5),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("VM: ${round.story.vm}", style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600, fontSize: 15.0),),
                          SizedBox(width: 30,),
                          Text("US: ${planningPoker.usDone}/${planningPoker.initialStoryCount}", style: TextStyle(color: solutecGrey, fontWeight: FontWeight.w600, fontSize: 15.0),),
                        ],
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          anticipatedTimeLeft > 0 ? Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text("${anticipatedTimeLeft.round()+1}", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700)),
                          ) : Container(),
                          widget.currentUser == planningPoker.host ? RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            disabledColor: Color(0xFFC8E6C9),
                            elevation: 5.0,
                            color: Colors.green,
                            child: Text("Terminer", style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              if(round.selectedEffortsByPlayer.containsValue(-1))
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: Text("Tous les joueurs n'ont pas fait leur choix.\nTerminer tout de même ?", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19, color: solutecGrey), textAlign: TextAlign.center,),
                                      titlePadding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 6.0),
                                      contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0)
                                      ),
                                      children: <Widget>[
                                        ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: Text("Annuler", style: TextStyle(color: solutecRed, fontSize: 16),),
                                            ),
                                            SizedBox(
                                              width: 170,
                                              height: 50,
                                              child: RaisedButton(
                                                color: solutecRed,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  SocketIOHandler.send("stopPickingPhase");
                                                },
                                                child: Text("Terminer", style: TextStyle(fontSize: 18)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              else
                                SocketIOHandler.send("stopPickingPhase");
                            },
                          ) : Container(),
                        ],
                      )
                  ),
                ],
              ),
            )
          ]
      );
    });
  }

  void _onDisconnect() {
    // Popup de confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Êtes-vous sûr de vouloir quitter le planning poker en cours ?", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
          titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 12.0),
          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),
          children: <Widget>[
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Annuler", style: TextStyle(color: solutecRed, fontSize: 16),),
                ),
                SizedBox(
                  width: 170,
                  height: 40,
                  child: RaisedButton(
                      color: solutecRed,
                      onPressed: () {
                        Navigator.of(context).pop();
                        try {
                          Navigator.of(context).popUntil((route) =>
                          route.settings.name == OriginConstants.routeBacklog
                              || route.settings.name == OriginConstants.routeProjectsList
                              || route.settings.name == OriginConstants.routeDashboard
                              || route.settings.name == OriginConstants.routeSprint
                              || route.settings.name == OriginConstants.routeIntersprint
                              || route.settings.name == OriginConstants.routeUserManagement
                              || route.settings.name == OriginConstants.routeStory
                          );
                        } catch (e){
                          Navigator.of(context).pushNamedAndRemoveUntil(OriginConstants.routeProjectsList, (Route<dynamic> route) => false);
                        }
                      },
                      child: Text("Quitter", style: TextStyle(fontSize: 18))
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onClosePK() {
    // Popup de confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Êtes-vous sûr de vouloir clôturer le planning poker en cours ?", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
          titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 12.0),
          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),
          children: <Widget>[
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Annuler", style: TextStyle(color: solutecRed, fontSize: 16)),
                ),
                SizedBox(
                  width: 170,
                  height: 40,
                  child: RaisedButton(
                      color: solutecRed,
                      onPressed: () {
                        Navigator.of(context).pop();
                        SocketIOHandler.send("updatePlanningPokerState", body: PlanningPokerState.TERMINE.toString().substring(19));
                      },
                      child: Text("Clôturer", style: TextStyle(fontSize: 18))
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

}


