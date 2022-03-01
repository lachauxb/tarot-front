// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'User.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Player {

  User user;
  bool isObserver;
  double pick;

  Player();

  Player.fromApi(Map<String, dynamic> playerFromApi){
    this.user = User.fromApi(playerFromApi["user"]);
    this.isObserver = playerFromApi["observer"];
    this.pick = -1;
  }


  @override
  bool operator ==(Object other) => identical(this, other) || (other is Player && runtimeType == other.runtimeType && user.id == other.user.id) || (other is User && user.id == other.id);
  @override
  int get hashCode => user.id.hashCode;

}