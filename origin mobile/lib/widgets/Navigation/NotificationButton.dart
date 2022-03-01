// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/Notification.dart' as n;
import 'package:origin/model/Notification.dart';
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
// ** SERVICE ** //
import 'package:origin/services/NotificationService.dart';

class NotificationButton extends StatefulWidget{
  final Function onPressed;
  final String tooltip;
  NotificationButton({@required this.onPressed, this.tooltip}) : assert(onPressed != null);

  @override
  State<StatefulWidget> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> implements StateListener{

  int unreadNotifications = 0;

  @override
  void initState() {
    StateProvider().subscribe(this);
    loadData();
    super.initState();
  }

  void loadData(){
    AuthenticationService.getUser().then((user){
      NotificationService.getUserNotifications(user).then((notifications) {
        setState(() {
          unreadNotifications = notifications.length;
        });
      });
    });
  }

  @override
  void onStateChanged(ObserverState state) {
    if(state == ObserverState.NOTIFICATION_UPDATE)
      loadData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        width: 40,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            IconButton(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.person),
              onPressed: null,
              disabledColor: Colors.white,
              tooltip: widget.tooltip,
            ),
            unreadNotifications > 0 ? Align(
              alignment: Alignment.center,
              child: Container(
                  height: 20,
                  width: 15,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      color: solutecRed
                  ),
                  child: Text(unreadNotifications < 10 ? unreadNotifications.toString() : "9+", style: TextStyle(color: Colors.grey[300], fontSize: 10, fontWeight: FontWeight.bold))
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    StateProvider().dispose(this);
    super.dispose();
  }
}