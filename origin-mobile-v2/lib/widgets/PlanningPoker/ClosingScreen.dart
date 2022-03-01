// ** AUTO LOADER ** //
import 'dart:async';

import 'package:origin/config/auto_loader.dart';
import 'package:origin/views/BacklogActivity.dart';
// ** MODEL ** //
// ** PACKAGES ** //

class ClosingScreenView extends StatefulWidget {

  final String title;
  ClosingScreenView(this.title) : assert(title != null);

  @override
  _ClosingScreenViewState createState() => _ClosingScreenViewState();
}

class _ClosingScreenViewState extends State<ClosingScreenView>{

  Timer timer;
  double timeLeft = 4;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (Timer _timer) => timeLeft > 0 ? setState(() => timeLeft -= 0.05) : _close());
    super.initState();
  }

  @override
  void dispose() {
    if(timer.isActive)
      timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.grey[200].withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(widget.title, style: TextStyle(fontSize: 30, color: solutecGrey)),
                  Text("Le planning poker va se fermer dans", style: TextStyle(fontSize: 15, color: solutecGrey)),
                  SizedBox(height: 15),
                  Stack(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: timeLeft / 4,
                                valueColor: AlwaysStoppedAnimation(Color(0xFF3c4858))
                            )
                        ),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 4, left: 1),
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text("${timeLeft.round()+1}", style: TextStyle(fontSize: 20, color: solutecGrey))
                            )
                        )
                      ]
                  )
                ]
            )
        )
    );
  }

  void _close(){
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
  }

}


