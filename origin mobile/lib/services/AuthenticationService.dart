// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:origin/services/UserService.dart';
// ** MODEL ** //
import 'package:origin/model/Priority.dart';
import 'package:origin/model/Role.dart';
import 'package:origin/model/StoryState.dart';
import 'package:origin/model/User.dart';
// ** OTHERS ** //

/// Service permettant la gestion centralisée de tout ce qui touche à l'identification de l'utilisateur courant (utilisant l'appli)
class AuthenticationService {

  static User _user; // singleton

  /// Retourne un Future (= promise) d'une requête http post de tentative de connexion vers le back end
  static Future<HttpStatus> connect(String login, String password) async{
    return await HTTPRequestHandler.request(HttpRequest.POST, OriginConstants.login, requestBody: {'name': login, 'pwd': password}).then((response){
      if(response['status'] == HttpStatus.OK)
        HTTPRequestHandler.setToken(response['result']['response']);
      return response['status'];
    });
  }

  /// Ping la fonction de test du back pour s'assurer de la connexion
  static Future<bool> _pingTest() async{
    var response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.ping);
    return response["status"] == HttpStatus.NO_CONTENT;
  }

  /// s'occupe de "connecter localement" l'utilisateur à l'application et de le rediriger vers la bonne interface
  /// -> Retourne la route vers laquelle rediriger l'utilisateur
  static Future<String> logIn() async{
    // récupération du token de session (si il existe, on lance l'application pour l'utilisateur)
    if(await HTTPRequestHandler.getToken() != null)
      if(await _pingTest()){
        ConnectionListener.getInstance().hasConnection = true;
        User user = await getUser(force: true);
        if(user == null){
          disconnect();
        }else {
          Priority.loadPriorityList();
          StoryState.loadStateList();
          Role.loadRolesList();
          if(user.pushNotificationToken == null || user.pushNotificationToken == 'null') {
            PushNotificationHandler.getToken().then((String token) {
              UserService.updatePushNotificationToken(token).then((user){
                AuthenticationService.getUser(force: true);
              });
            });
          }
          return ProjectService.getRoute();
        }
      }
    return null;
  }

  /// retourne l'utilisateur -- ! (peut retourner null si l'utilisateur n'est pas encore connecté ou que l'api ne renvoit pas d'utilisateur) !
  static Future<User> getUser({bool force = false}) async{
    if(_user == null || force){
      final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getUser);
      if(response['status'] == HttpStatus.OK && response['result'] != null){
        var result = response['result'];
        _user = User.fromApi(result);
      }
    }
    return _user;
  }

  /// Déconnexion de l'utilisateur courant et nettoyage du token
  static void disconnect(){
    _user = null;
    ProjectService.setCurrentProject(null);
    HTTPRequestHandler.disconnect();
  }

}