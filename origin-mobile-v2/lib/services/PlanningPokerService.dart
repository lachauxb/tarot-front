// ** AUTO LOADER ** //
import 'dart:convert';

import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** MODEL ** //
import 'package:origin/model/Theme.dart' as t;
import 'package:origin/model/User.dart';
// ** OTHERS ** //

class PlanningPokerService {

  /// Met à jour l'état du test
  static Future<Map<String, dynamic>> getPlanningPoker(int projectId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getPlanningPoker.replaceAll("{projectId}", projectId.toString()));
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }

  /// Met à jour l'état du test
  static Future<Map<String, dynamic>> updateObserver(int projectId, int userId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.POST,
        OriginConstants.updatePlanningPokerObserver.replaceAll("{projectId}", projectId.toString()), requestBody: userId
    );
    if (response['status'] == HttpStatus.OK) {
      result['status'] = response['status'];
      result['result'] = response['result'];
    }
    return result;
  }

  /// Met à jour l'état du test
  static Future<Map<String, dynamic>> updatePlanningPokerParams(int projectId, bool withEffort, List<t.Theme> selectedThemes) async {
    List<int> ids = List(); selectedThemes.forEach((theme) => ids.add(theme.idTheme));

    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.POST,
        OriginConstants.updatePlanningPokerParams.replaceAll("{projectId}", projectId.toString()).replaceAll("{withEffort}", jsonEncode(withEffort)), requestBody: ids
    );
    if (response['status'] == HttpStatus.OK) {
      result['status'] = response['status'];
      result['result'] = response['result'];
    }
    return result;
  }

  /// envoi les valeurs pour démarrer un round ou la valeur choisie à attribuer à l'us
  static Future<Map<String, dynamic>> endRound(List<double> values, int projectId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.POST,
        OriginConstants.endPlanningPokerRound.replaceAll("{projectId}", projectId.toString()), requestBody: values
    );
    if (response['status'] == HttpStatus.OK) {
      result['status'] = response['status'];
      result['result'] = response['result'];
    }
    return result;
  }
}