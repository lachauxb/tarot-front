// ** AUTO LOADER ** //
import 'dart:async';

import 'package:origin/config/auto_loader.dart';
import 'package:origin/views/BacklogActivity.dart';
// ** MODEL ** //
// ** PACKAGES ** //

class LoadingScreenView extends StatefulWidget {
  @override
  _LoadingScreenViewState createState() => _LoadingScreenViewState();
}

class _LoadingScreenViewState extends State<LoadingScreenView>{

  List<String> texts = [
    "Cela prend plus de temps que prévu",
    "Classification des icônes",
    "Chargement des absents",
    "Récupération des joueurs"
  ];
  String loadingText;

  bool _showSpinner = true;

  Timer timer;
  int timeLeft = 12; // 12s

  @override
  void initState() {
    loadingText = texts.last;
    timer = Timer.periodic(const Duration(seconds: 4), (Timer _timer) => timeLeft > 0 ? setState((){
      int index = (timeLeft/4).round();
      loadingText = texts[index-1];
      timeLeft -= 4;
    }) : setState((){
      timer.cancel();
      loadingText = "Échec du chargement";
      _showSpinner = false;
      Toast.alert(context);
    }));
    super.initState();
  }

  @override
  void dispose() {
    if(timer != null && timer.isActive)
      timer.cancel();
    super.dispose();
  }

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
                        Text("Chargement du Planning Poker en cours", style: TextStyle(fontSize: 30, color: solutecGrey)),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("$loadingText...", style: TextStyle(fontSize: 15, color: solutecGrey)),
                            SizedBox(width: 15),
                            _showSpinner ? SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(solutecRed),
                                strokeWidth: 2
                              )
                            ) : Container()
                          ]
                        )
                      ]
                  )
              )
          ),
          RaisedButton(
              onPressed: () => Navigator.of(context).pop(),
              elevation: 5.0,
              color: solutecRed,
              padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
              child: Text("Annuler", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))
          ),
          Container()
      ]
    );
  }

}


