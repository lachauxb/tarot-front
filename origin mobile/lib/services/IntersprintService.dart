// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Intersprint.dart';
// ** PACKAGES ** //
// ** MODEL ** //
// ** OTHERS ** //

class IntersprintService {

  /// Retourne les intersprints d'un projet
  static Future<List<dynamic>> getIntersprints(int idProject) async{
    List<dynamic> intersprints = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getProjectIntersprints.replaceAll('{projectId}', idProject.toString()));
    if (response['status'] == HttpStatus.OK) {
      intersprints = response['result'];
    }
    return intersprints;
  }

  /// Met à jour les exigences d'un projet
  static Future<dynamic> updateExigences(Intersprint intersprint) async{
    final response = await HTTPRequestHandler.request(HttpRequest.POST, OriginConstants.updateIntersprintExigences.replaceAll('{intersprintId}', intersprint.id.toString()), requestBody: intersprint.exigences);
    if (response['status'] == HttpStatus.OK) {
      return response['result'];
    } else {
      return null;
    }
  }

  /// Met à jour les exigences d'un projet
  static Future<dynamic> updateIntersprintStoryState(Map<String, dynamic> intersprintStory) async{
    final response = await HTTPRequestHandler.request(HttpRequest.POST, OriginConstants.updateIntersprintStoryState.replaceAll('{intersprintStoryId}', intersprintStory["id"].toString()), requestBody: intersprintStory["state"]);
    if (response['status'] == HttpStatus.OK) {
      return response['result'];
    } else {
      return null;
    }
  }


}