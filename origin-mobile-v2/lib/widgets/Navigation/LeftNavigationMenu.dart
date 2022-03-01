import 'package:flutter/material.dart';
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/config/theme.dart';

class LeftNavigationDrawer extends StatefulWidget {

  final String currentViewId;

  LeftNavigationDrawer({this.currentViewId});

  @override
  LeftNavigationDrawerState createState() => LeftNavigationDrawerState(currentViewId: currentViewId);
}

class LeftNavigationDrawerState extends State<LeftNavigationDrawer>{
  LeftNavigationDrawerState({this.currentViewId});

  final String currentViewId;
  Project project;

  List<ListTile> navigationTiles = [];
  List<ListTile> projectTiles = [];

  @override
  void initState() {
    super.initState();

    navigationTiles = [
      ListTile(leading: Icon(Icons.folder), title: Text(OriginConstants.projectsListViewId),
        onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(OriginConstants.routeProjectsList, (Route<dynamic> route) => false),
        selected: currentViewId == OriginConstants.projectsListViewId,
      )
    ];

    /// Gestion des utilisateurs uniquement diponible pour les administrateurs
    AuthenticationService.getUser().then((User user){
      if(user != null && (user.hasRight(Right.UPDATE_ROLE_RIGHTS) || user.hasRight(Right.UPDATE_USER_ROLE))) {
        setState(() {
          navigationTiles.add(ListTile(leading: Icon(Icons.wc), title: Text(OriginConstants.userManagementViewId),
            onTap: () => Navigator.pushReplacementNamed(context, OriginConstants.routeUserManagement),
            selected: currentViewId == OriginConstants.userManagementViewId,
          ),);
        });
      }
    });

    ProjectService.getCurrentProject().then((project){
      if(project != null){
        this.project = project;

        /// Dashboard, Backlog & Sprint
        projectTiles = [
          ListTile(leading: Icon(Icons.dashboard), title: Text(OriginConstants.dashboardViewId),
            onTap: () => Navigator.pushReplacementNamed(context, OriginConstants.routeDashboard),
            selected: currentViewId == OriginConstants.dashboardViewId,
          ),
          ListTile(leading: Icon(Icons.assignment), title: Text(OriginConstants.backlogViewId),
            onTap: () => Navigator.pushReplacementNamed(context, OriginConstants.routeBacklog),
            selected: currentViewId == OriginConstants.backlogViewId,
          ),
          ListTile(leading: Icon(Icons.polymer), title: Text(OriginConstants.sprintViewId),
            onTap: () => Navigator.pushReplacementNamed(context, OriginConstants.routeSprint),
            selected: currentViewId == OriginConstants.sprintViewId,
          )
        ];

        if(!project.enSprint){
          projectTiles.insert(2,
              ListTile(leading: Icon(Icons.list), title: Text(OriginConstants.intersprintViewId),
                onTap: () => Navigator.pushReplacementNamed(context, OriginConstants.routeIntersprint),
                selected: currentViewId == OriginConstants.intersprintViewId,
              )
          );
        }

        if(project.planningPokerEnCours){
          projectTiles.add(ListTile(leading: Icon(OriginIcons.playing_cards), title: Text(OriginConstants.planningPokerViewId),
            onTap: () {
              if(PushNotificationHandler.lastToast != null && PushNotificationHandler.lastToast.isShowing())
                PushNotificationHandler.lastToast.dismiss();
              Navigator.pushNamed(context, OriginConstants.routePlanningPoker);
              },
            selected: currentViewId == OriginConstants.planningPokerViewId,
          )
          );
        }

        setState((){});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: drawerBackgroundColor,
        padding: EdgeInsets.all(5.0),
        child: ListView(
          children: <Widget>[
            new DrawerHeader(
              child: Image.asset("assets/logo_origin.png"),
            ),
            // Tiles de navigation globale
            Container(
              child: Column(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: navigationTiles,
                ).toList(),
              ),
            ),
            // Tiles propres au projet
            project != null ? Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 50.0, bottom: 5,),
                    child: Text(project.name,
                      maxLines: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: solutecRed
                      ),
                    ),
                  ),
                  Column(
                    children: ListTile.divideTiles( // Ajoute des divider entre les tiles
                      context: context,
                      tiles: projectTiles,
                    ).toList(),
                  ),
                ],
              ),
            ) : null,

          ].where((child) => child != null).toList(), // Permet de remplacer le widget par null si aucun projet n'est selectionné
        ),
      ),
    );
  }
}
