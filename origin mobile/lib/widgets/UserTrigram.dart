// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/User.dart';

/// widget affichant le trigramme d'un utilisateur
class UserTrigram extends StatelessWidget {

  final User user;
  final IconData icon;
  final Color iconColor;
  UserTrigram({@required this.user, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(icon != null ? OriginConstants.userTrigramWithIconSize : OriginConstants.userTrigramSize),
      child: Tooltip(
        message: "${user.prenom} ${user.nom}",
        child: Container(
          margin: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                  user.trigram,
                  style: TextStyle(
                    color: solutecGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  )
              ),
              icon != null ? SizedBox(width: 5) : Container(),
              icon != null ? Icon(icon, size: 17, color: iconColor ?? Colors.black) : Container()
            ]
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0,),
        )
      )
    );
  }

}