// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

class SprintService {

  /// retourne le sprint correspondant à l'ID fourni
  static Future<dynamic> getByID(int id) async{
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getSprintById.replaceAll("{sprintId}", id.toString()));
    if (response['status'] == HttpStatus.OK) {
      return response['result'];
    }
    return null;
  }

  /// retourne le dernier sprint du projet courant
  static Future<dynamic> getLastSprint() async{
    Project project = await ProjectService.getCurrentProject();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectLastSprint.replaceAll("{projectId}", project.id.toString()));
    if (response['status'] == HttpStatus.OK) {
      return response['result'];
    }
    return null;
  }

  /// Retourne le sprint courant d'un projet
  static Future<Map<String, dynamic>> getRunningSprint(int id) async {
    Map<String, dynamic> runningSprintData = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getRunningSprint.replaceAll('{id}', id.toString()));
    if (response['status'] == HttpStatus.OK) {
      runningSprintData = response['result'];
    }
    return runningSprintData;
  }

  /// Retourne les US d'un sprint
  static Future<List<dynamic>> getSprintStories(int id) async{
    List<dynamic> sprintStoriesData = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getSprintStories.replaceAll('{sprintId}', id.toString()));
    if (response['status'] == HttpStatus.OK) {
      sprintStoriesData = response['result'];
    }
    return sprintStoriesData;
  }

  /// Retourne les tâches d'un sprint
  static Future<List<dynamic>> getSprintFollowTasks(int id) async{
    List<dynamic> followTasks = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getSprintFollowTasks.replaceAll('{id}', id.toString()));
    if (response['status'] == HttpStatus.OK) {
      followTasks = response['result'];
    }
    return followTasks;
  }

  /// Retourne l'effort des tâches d'un sprint
  static Future<double> getSprintFollowTasksEffort(int id) async{
    double tasksEffort = 0.0;
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getSprintFollowTasksEffort.replaceAll('{id}', id.toString()));
    if (response['status'] == HttpStatus.OK) {
      tasksEffort = response['result'];
    }
    return tasksEffort;
  }

  /// Retourne sous forme d'une liste de points le graphique burn down vm & effort pour le dashboard
  static Future<List<dynamic>> getBurnDown(int id) async{
    List<dynamic> burnDown = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getBurnDown.replaceAll('{sprintId}', id.toString()));
    if (response['status'] == HttpStatus.OK) {
      burnDown = response['result'];
    }
    return burnDown;
  }

}