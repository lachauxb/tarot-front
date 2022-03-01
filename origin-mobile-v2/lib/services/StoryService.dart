// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'dart:convert';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

/// permet de gérer de manière centralisée les appels API liés à une Story
class StoryService {

  /// retourne l'ensemble des US d'un projet
  static Future<List<dynamic>> getAllFromProjectID(int id) async{
    List<dynamic> stories = new List<dynamic>();

    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectStories.replaceAll("{idProject}", id.toString()));
    if (response['status'] == HttpStatus.OK) {
      stories = response['result'];
    }
    return stories;
  }

  /// retourne l'ensemble des tâches de suivi d'un projet
  static Future<List<dynamic>> getFollowTasks(int id) async{
    List<dynamic> followTasks = new List<dynamic>();

    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectFollowTasks.replaceAll("{projectId}", id.toString()));
    if (response['status'] == HttpStatus.OK) {
      followTasks = response['result'];
    }
    return followTasks;
  }

  /// retourne l'ensemble des exigences d'un projet
  static Future<List<dynamic>> getExigences(int id) async{
    List<dynamic> exigences = new List<dynamic>();

    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectExigences.replaceAll("{projectId}", id.toString()));
    if (response['status'] == HttpStatus.OK) {
      exigences = response['result'];
    }
    return exigences;
  }

  /// retourne l'US de l'id spécifié
  static Future<Map<String, dynamic>> getStoryById(int storyId) async{
    Map<String, dynamic> story = new Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getStoryById.replaceAll("{storyId}", storyId.toString()));
    if (response['status'] == HttpStatus.OK) {
      story = response['result'];
    }
    return story;
  }

  /// change l'état d'une story
  static Future<Map<String, dynamic>> changeStoryState(int storyId, int storyStateId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.PUT, OriginConstants.updateStory.replaceAll("{storyId}", storyId.toString()), requestBody: jsonEncode({"state": "$storyStateId"}));
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }

  /// change la valeur d'effort d'une story
  static Future<Map<String, dynamic>> changeStoryEffort(int storyId, double effort) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.PUT, OriginConstants.updateStory.replaceAll("{storyId}", storyId.toString()), requestBody: jsonEncode({"effort": "$effort"}));
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }
}