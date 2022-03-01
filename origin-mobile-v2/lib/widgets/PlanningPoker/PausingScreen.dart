// ** AUTO LOADER ** //
import 'dart:async';

import 'package:origin/config/auto_loader.dart';
import 'package:origin/views/BacklogActivity.dart';
// ** MODEL ** //
// ** PACKAGES ** //

class PausingScreenView extends StatefulWidget {

  final String title;
  PausingScreenView(this.title) : assert(title != null);

  @override
  _PausingScreenViewState createState() => _PausingScreenViewState();
}

class _PausingScreenViewState extends State<PausingScreenView>{

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(),
          Center(
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
                        Text("Veuillez patienter...", style: TextStyle(fontSize: 15, color: solutecGrey)),
                      ]
                  )
              )
          ),
          RaisedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.settings.name == OriginConstants.routeBacklog || route.settings.name == OriginConstants.routeProjectsList),
              elevation: 5.0,
              color: solutecRed,
              padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
              child: Text("Quitter", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))
          ),
          Container()
      ]
    );
  }

}


