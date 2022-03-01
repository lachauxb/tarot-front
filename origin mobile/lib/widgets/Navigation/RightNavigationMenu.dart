import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/services/NotificationService.dart';
import 'package:origin/model/Notification.dart' as n;
import 'package:origin/widgets/Navigation/NotificationTile.dart';

class RightNavigationDrawer extends StatefulWidget {
  @override
  RightNavigationDrawerState createState() => RightNavigationDrawerState();
}

class RightNavigationDrawerState extends State<RightNavigationDrawer> {

  User user;
  List<ListTile> userItems = [];

  List<n.Notification> notifications = List<n.Notification>();
  bool notificationsAreLoading = true;

  Toast _settingsToast;

  void loadComments(){
    NotificationService.getUserNotifications(user).then((response){
      notifications.clear();
      if(response != null) {
        response.forEach((notifFromApi) {
          n.Notification notif = n.Notification.fromApi(notifFromApi);
          notifications.add(notif);
        });
        notifications.sort((n.Notification a, n.Notification b) => b.date.compareTo(a.date));
      }
      setState((){notificationsAreLoading = false;});
    });
  }

  @override
  void initState(){
    super.initState();
    _settingsToast = Toast(context: context, message: "Personnalisation & paramétrage de l'application", type: ToastType.INFO, title: "Coming soon...", duration: const Duration(seconds: 2));

    AuthenticationService.getUser().then((user){
      this.user = user;
      userItems = [
        ListTile(
          title: Text("Déconnexion"),
          leading: Icon(Icons.power_settings_new),
          selected: true,
          onTap: _onDisconnect,
        ),
        ListTile(
          title: Text("Paramètres"),
          leading: Icon(Icons.settings),
          onTap: () {
            _settingsToast.show();
          }, // todo
        ),
      ];
      setState((){});
      loadComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Drawer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Container(
                  color: drawerBackgroundColor,
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      DrawerHeader(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("assets/default_avatar.png", height: 90, width: 90),
                            SizedBox(height: 10.0),
                            Text(user != null ? "${user.nom} ${user.prenom}" : "Utilisateur non reconnu", style: TextStyle(color: solutecRed, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: ListTile.divideTiles( // Ajoute des Divider entre les tiles
                            context: context,
                            tiles: userItems,
                          ).toList(),
                        ),
                      ),
                      MediaQuery.of(context).size.height > 500 ? Container(
                        padding: EdgeInsets.only(top: 30.0, bottom: 5,),
                        child: Text("Notifications", maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: solutecRed),),
                      ) : Container(),
                      MediaQuery.of(context).size.height > 500 ? Expanded(
                        child: Container(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            child: notificationsAreLoading ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(solutecRed),
                              ),
                            ) : Scrollbar(
                              child: ListView.builder(
                                padding: EdgeInsets.all(5),
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  if(!notifications[index].dismissed)
                                    return NotificationTile(
                                    notification: notifications[index],
                                    onDismiss :(direction){
                                      setState(() {
                                        notifications[index].dismissed = true;
                                      });
                                      NotificationService.dismissNotification(notifications[index].id).then((value) => StateProvider().notify(ObserverState.NOTIFICATION_UPDATE));
                                      Toast(
                                        context: context,
                                        message: "Vous avez supprimé une notification.",
                                        type: ToastType.INFO,
                                        duration: Duration(seconds: 2),
                                        mainButton: FlatButton(
                                          child: Text("ANNULER"),
                                          textColor: Toast.colors[ToastType.INFO],
                                          onPressed: () {
                                            setState(() {
                                              notifications[index].dismissed = false;
                                            });
                                            NotificationService.dismissNotification(notifications[index].id).then((value) => StateProvider().notify(ObserverState.NOTIFICATION_UPDATE));
                                          },
                                        ),
                                      ).show();
                                    },
                                  );
                                  else
                                    return Container();
                                },
                              ),
                            )
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: drawerBackgroundColor,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset("assets/logo_solutec.png"),
                  ),
                ),
              )
            ],
          )
      );
    });
  }

  void _onDisconnect(){
    // Popup de confirmation
    showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          title: Text("Êtes-vous sûr de vouloir vous déconnecter ?", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),),
          titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 12.0),
          contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
          children: <Widget>[
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Annuler", style: TextStyle(color: solutecRed, fontSize: 16),),
                ),
                SizedBox(
                  width: 170,
                  height: 50,
                  child: RaisedButton(
                    color: solutecRed,
                    onPressed: () {
                      AuthenticationService.disconnect();
                      // Retire toutes les pages de la pile pour éviter qu'un retour en arrière laisse accès à l'appli sans qu'un utilisateur soit connecté
                      Navigator.of(context).pushNamedAndRemoveUntil(OriginConstants.routeLogin, (Route<dynamic> route) => false);
                    },
                    child: Text("Se déconnecter", style: TextStyle(fontSize: 18),),
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
