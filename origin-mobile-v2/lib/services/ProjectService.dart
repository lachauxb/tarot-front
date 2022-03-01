// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Actor.dart';
import 'package:origin/model/Epic.dart';
import 'package:origin/model/Theme.dart' as  t;
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

class ProjectService {

  static Project _currentProject;
  static bool hasPlanningPokerRunning = false;

  static void setCurrentProject(Project project){
    _currentProject = project;
    if(_currentProject != null){
      t.Theme.loadProjectThemesList(_currentProject.id);
      Epic.loadProjectEpicsList(_currentProject.id);
      Actor.loadProjectActorsList(_currentProject.id);
    }
  }

  static Future<Project> getCurrentProject({bool force = false, int projectId}) async{ // on peut demander à recharger le projet principal ou un projet précis avec force & projectId
    if(_currentProject == null || force){
      if(_currentProject != null && projectId == null)
        projectId = _currentProject.id;
      // on demande à récupérer le projet principal de l'utilisateur (projet en cours / en sprint / ...)
      var response = projectId != null ? await HTTPRequestHandler.request(HttpRequest.GET, "projects/{$projectId}") : await HTTPRequestHandler.request(HttpRequest.GET, "users/getMainProject");
      if(response['status'] == HttpStatus.OK && response['result'] != null && response['result']['projectId'] != null) // si un projet principal trouvé, alors...
        ProjectService.setCurrentProject(Project.fromApi(response['result']));
    }
    return _currentProject;
  }

  static Future<String> getRoute({String defaultRoute = OriginConstants.routeDashboard}) async{ // possibilitée de redéfinir la route par défaut avec defaultRoute
    User user = await AuthenticationService.getUser();
    if(_currentProject == null && !user.hasRight(Right.SEE_ALL_PROJECTS))
        await getCurrentProject();
    return _currentProject != null ? (_currentProject.enSprint ? OriginConstants.routeSprint : OriginConstants.routeIntersprint) : OriginConstants.routeProjectsList;
  }

  // ** -------------------------------------------------------------------------------------------------------- ** //

  /// Retourne tous les projets de la BDD
  static Future<List<dynamic>> getProjects() async {
    List<dynamic> projects = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjects);
    if (response['status'] == HttpStatus.OK) {
      projects = response['result'];
    }
    return projects;
  }

  /// Retourne les projets d'un utilisateur
  static Future<List<dynamic>> getUserProjects() async{
    List<dynamic> projects = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getUserProjects);
    if (response['status'] == HttpStatus.OK) {
      projects = response['result'];
    }
    return projects;
  }

  /// Retourne les membres d'un projet
  static Future<List<dynamic>> getProjectMembers(int projectId) async{
    List<dynamic> members = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectMembers.replaceAll('{projectId}', projectId.toString()));
    if (response['status'] == HttpStatus.OK) {
      members = response['result'];
    }
    return members;
  }

  /// Retourne tous les sprints d'un projet
  static Future<List<dynamic>> getProjectSprints(int projectId) async{
    List<dynamic> sprints = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectSprints.replaceAll('{projectId}', projectId.toString()));
    if (response['status'] == HttpStatus.OK) {
      sprints = response['result'];
    }
    return sprints;
  }

  /// retourne le projet de l'id spécifié
  static Future<Map<String, dynamic>> getProjectById(int projectId) async{
    Map<String, dynamic> project = new Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectById.replaceAll("{id}", projectId.toString()));
    if (response['status'] == HttpStatus.OK) {
      project = response['result'];
    }
    return project;
  }

}