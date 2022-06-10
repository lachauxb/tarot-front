import 'package:tarot_front/models/user.dart';
import 'package:tarot_front/services/http_service.dart';


class UserService {

  /// Request GET /users
  /// Get all users from the app
  static Future<List<User>> getAllUsers() async {
    List<User> users = [];
    final response = await HTTPService.request(HttpRequest.GET, "users");
    if(response['status'] == 200){
      users = ConvertUser.fromApi(response['result']);
    }
    return users;
  }

}