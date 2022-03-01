// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'dart:convert';
// ** MODEL ** //
import 'package:origin/model/Role.dart';
import 'package:origin/model/User.dart';
// ** OTHERS ** //

class UserService {

  /// Retourne tous les utilisateurs d'origin
  static Future<List<dynamic>> getAllUsers() async {
    List<dynamic> users = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getAllUsers);
    if (response['status'] == HttpStatus.OK) {
      users = response['result'];
    }
    return users;
  }

  /// Retourne les utilisateurs d'une Story
  static Future<List<dynamic>> getStoryUsers(int storyId) async {
    List<dynamic> users = List<dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getStoryUsers.replaceAll("{storyId}", storyId.toString()));
    if (response['status'] == HttpStatus.OK) {
      users = response['result'];
    }
    return users;
  }

  /// Change les utilisateurs d'une Story
  static Future<Map<String, dynamic>> updateStoryUsers(int storyId, List<Map<String, dynamic>> users) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    final response = await HTTPRequestHandler.request(HttpRequest.PUT, OriginConstants.updateStoryUsers.replaceAll("{storyId}", storyId.toString()), requestBody: "${jsonEncode(users)}");
    if (response['status'] == HttpStatus.OK) {
      result = response['result'];
    }
    return result;
  }

  // todo generify for all users editables values
  static Future<Role> updateUserRole(User user, Role newRole) async {
    final response = await HTTPRequestHandler.postWithParams(OriginConstants.updateUserRole, {'userId': user.username, 'roleId': newRole.idRole.toString()});
    if (response['status'] == 200) {
      return Role.getById(response['result']['isAdmin'] == 1 ? 1 : 2);
    }
    return null;
  }


  static Future<Role> updateRoleRight(Role role, String right, bool hasRight) async {
    final response = await HTTPRequestHandler.postWithParams(
        OriginConstants.updateRoleRights.replaceAll("{roleId}", role.idRole.toString()).replaceAll("{rightId}", right), // todo replace once back is using roles too
        {'hasRight': jsonEncode(hasRight)}
    );
    if (response['status'] == 200) {
      return Role.fromApi(response['result']);
    }
    return null;
  }

  static Future<User> updatePushNotificationToken(String token) async {
    final response = await HTTPRequestHandler.postWithParams(
        OriginConstants.updatePushNotificationToken,
        {'pushNotificationToken': token}
    );
    if (response['status'] == 200) {
      return User.fromApi(response['result']);
    }
    return null;
  }

}