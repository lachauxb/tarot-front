// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'dart:convert';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

class TaskService{

  /// retourne la tâche correspondant à l'ID fourni
  static Future<dynamic> getByID(int id) async{
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getTaskById.replaceAll("{taskId}", id.toString()));
    if (response['status'] == HttpStatus.OK) {
      return response['result'];
    }
    return null;
  }

  /// Change l'état d'une tâche
  static Future<Map<String, dynamic>> changeTaskState(int taskId, int taskStateId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.PUT, OriginConstants.changeTaskState.replaceAll("{taskId}", taskId.toString()), requestBody: jsonEncode({"value":"$taskStateId"}));
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }

  /// Change l'état d'une tâche de suivi
  static Future<Map<String, dynamic>> changeFollowTaskState(int followTaskId, int followTaskStateId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.PUT, OriginConstants.updateFollowTask.replaceAll("{followTaskId}", followTaskId.toString()), requestBody: jsonEncode({"taskState": "$followTaskStateId"}));
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }

}