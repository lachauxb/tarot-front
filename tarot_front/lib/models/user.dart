import 'package:tarot_front/models/role.dart';


class User {
  int id;
  String username;
  String email;
  List<Role> roles;

  User(this.id, this.username, this.email, this.roles);
}


class ConvertUser {

  /// API
  /// convert into User type
  static List<User> fromApi(List<dynamic> userList){
    List<User> users = [];
    for(var userMap in userList) {
      int id = userMap['id'];
      String username = userMap['id'];
      String email = userMap['id'];
      List<Role> roles = [];
      for(var roleMap in userMap['role']){
        roles.add(Role(roleMap['id'], roleMap['name']));
      }
      users.add(User(id, username, email, roles));
    }
    return users;
  }
}