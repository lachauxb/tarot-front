import 'package:origin/config/auto_loader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/services/ProjectService.dart';
import 'package:origin/model/User.dart';

class PushNotificationHandler{
  PushNotificationHandler._();

  factory PushNotificationHandler() => _instance;

  static final PushNotificationHandler _instance = PushNotificationHandler._();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static Toast lastToast;
  GlobalKey<NavigatorState> navigatorKey; // Clé globale pour accéder au context et afficher les Toast
  bool _initialized = false;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    if (!_initialized) {
      _firebaseMessaging.requestPermission();
      this.navigatorKey = navigatorKey;
      /*_firebaseMessaging.configure(
        onMessage: _showMessageAsToast, //Notification reçue pendant l'utilisation de l'appli
        onResume: _navigateToPlanningPoker, //Notification reçue lorsque l'appli est en arrière plan
        onLaunch: _navigateToPlanningPoker, //Notification reçue lorsque l'appli n'est pas lancée
      );*/
      _firebaseMessaging.getInitialMessage().then((message) {
        if (message != null){
          return _navigateToPlanningPoker(message.data);
        }
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) => _showMessageAsToast(message.data));
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) => _navigateToPlanningPoker(message.data));
      _initialized = true;
    }
  }

  //récupère un nouveau token pour l'utilisateur courrant
  static Future<String> getToken() async{
    String token = await _firebaseMessaging.getToken();
    return token;
  }

  //Affiche si possible la notification au bas de l'écran
  Future<void> _showMessageAsToast(Map<String, dynamic> message) async{
    User currentUser = await AuthenticationService.getUser();
    try {
      if(message.containsKey('data') &&
          message['data'].containsKey('userId') &&
          int.parse(message['data']['userId']) == currentUser.id &&
          message['data'].containsKey('projectId')
      ) {
        lastToast = Toast(
          context: navigatorKey.currentState.overlay.context,
          title: message["notification"]["title"],
          message: message["notification"]["body"],
          type: ToastType.INFO,
          duration: Duration(seconds: 10),
          onTap: (_) {
            ProjectService.getProjectById(
                int.parse(message["data"]["projectId"]))
                .then((projectFromApi) {
              Project project = Project.fromApi(projectFromApi);
              ProjectService.setCurrentProject(project);
              Navigator.pop(navigatorKey.currentState.overlay.context);
              Navigator.pushNamed(navigatorKey.currentState.overlay.context,
                  OriginConstants.routePlanningPoker);
            });
          },
        );
        lastToast.show();
      }
    } catch(error){
      print("erreur à la réception d'une notification: $error");
    }
  }

  //Redirige vers le planning poker au lancement de l'application
  Future<void> _navigateToPlanningPoker(Map<String, dynamic> message) async{
    ProjectService.getProjectById(int.parse(message["data"]["projectId"]))
        .then((projectFromApi) {
      Project project = Project.fromApi(projectFromApi);
      ProjectService.setCurrentProject(project);
      Navigator.pushNamed(navigatorKey.currentState.overlay.context,
          OriginConstants.routePlanningPoker);
    });
  }
}