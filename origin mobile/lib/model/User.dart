// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Role.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class User {

  int id;
  String username;
  String password; // sous forme d'un hash
  String nom;
  String prenom;
  Role role;
  String trigram;
  String pushNotificationToken;

  User(int userId, String username, String password, String nom, String prenom, Role role, String pushNotificationToken){
    this.id = userId;
    this.username = username;
    this.password = password;
    this.nom = nom;
    this.prenom = prenom;
    this.role = role;
    this.trigram = prenom.substring(0,1).toUpperCase() + nom.substring(0,2).toUpperCase();
    this.pushNotificationToken = pushNotificationToken;
  }

  User.fromApi(Map<String, dynamic> userFromApi){
    this.id = userFromApi["userId"];
    this.username = userFromApi["uid"];
    this.password = userFromApi["password"];
    this.nom = userFromApi["lastName"];
    this.prenom = userFromApi["firstName"];
    this.role = Role.fromApi(userFromApi["role"]);
    this.trigram = prenom.substring(0,1).toUpperCase() + nom.substring(0,2).toUpperCase();
    this.pushNotificationToken = userFromApi["pushNotificationToken"];
    // existent également: "nbReservations", "nickname" et "email"
  }

  Role getRole(){
    return role;
  }

  bool hasRight(Right right){
    return this.role != null ? this.role.hasRight(right) : false;
  }

  int compareTo(User toCompare){
    return this.nom.compareTo(toCompare.nom);
  }

  @override
  String toString(){
    return "${this.nom} ${this.prenom}";
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) => identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id;

}