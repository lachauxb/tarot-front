// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/scheduler.dart';
// ** SERVICES ** //
import 'package:origin/services/AuthenticationService.dart';
// **  VIEWS   ** //
import 'package:origin/views/LoginActivity.dart';
import 'package:origin/views/PlanningPokerActivity.dart';
import 'package:origin/views/ProjectsListActivity.dart';
import 'package:origin/views/SprintActivity.dart';
import 'package:origin/views/DashboardActivity.dart';
import 'package:origin/views/BacklogActivity.dart';
import 'package:origin/views/StoryActivity.dart';
import 'package:origin/views/UserManagementActivity.dart';
import 'package:origin/views/IntersprintActivity.dart';
// **  OTHERS  ** //


/// Retire la zone de couleur aux extrémités des widgets défilants
class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

/// Fonction d'initialisation et de lancement de l'application Origin
void main() async{
  initializeDateFormatting("fr_FR", null).then((_) {});
  WidgetsFlutterBinding.ensureInitialized();
  WidgetBuilder activityToRedirect = (BuildContext context) => new LoginActivity();

  // déjà connecté ? alors on redirige là ou il faut sinon on lance juste la page de login
  String routeToRedirect = await AuthenticationService.logIn();
  if(routeToRedirect != null){
    activityToRedirect = OriginApp.routes[routeToRedirect];
  }

  // lancement de l'application
  runApp(
    OriginConstants(
      child: OriginApp(activityToRedirect),
    ),
  );
}

/// Application Origin
class OriginApp extends StatelessWidget {

  final WidgetBuilder activityToRedirect;
  OriginApp(this.activityToRedirect);

  static Map<String, WidgetBuilder> routes = {
    OriginConstants.routeLogin : (BuildContext context) => new LoginActivity(),
    OriginConstants.routeProjectsList : (BuildContext context) => new ProjectsListActivity(),
    OriginConstants.routeDashboard : (BuildContext context) => new DashboardActivity(),
    OriginConstants.routeBacklog : (BuildContext context) => new BacklogActivity(),
    OriginConstants.routeIntersprint : (BuildContext context) => new IntersprintActivity(),
    OriginConstants.routeSprint : (BuildContext context) => new SprintActivity(),
    OriginConstants.routeUserManagement : (BuildContext context) => new UserManagementActivity(),
    OriginConstants.routeStory : (BuildContext context) => new StoryActivity(),
    OriginConstants.routePlanningPoker : (BuildContext context) => new PlanningPokerActivity()
  };

  final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context){
    try{
      return MaterialApp(
          builder: (context, child){
            PushNotificationHandler pushNotificationHandler = PushNotificationHandler();
            SchedulerBinding.instance.addPostFrameCallback((_) {
          pushNotificationHandler.init(navigatorKey);
        });
            return ScrollConfiguration(
              behavior: NoGlowBehavior(),
              child: child,
            );
          },
          title: 'Origin',
          theme: ThemeData(
            primaryColor: solutecRed,
            fontFamily: 'OpenSans',
            indicatorColor: solutecRed,
            accentColor: solutecRed,
            highlightColor: solutecRed,
          ),
          debugShowCheckedModeBanner: false, // TODO : remove on app release
          home: activityToRedirect(context),
          navigatorKey: navigatorKey,
          routes: routes
      );
    }catch(exception){
      Toast.alert(context);
      return null;
    }
  }
}


