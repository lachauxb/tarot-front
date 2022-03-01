// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Role{

  int idRole;
  String nom;
  String abbr;
  Map<Right, bool> rights = Map<Right, bool>();

  Role.fromApi(Map<String, dynamic> roleFromApi){
    this.idRole = roleFromApi['roleId'];
    this.nom = roleFromApi['nom'];
    this.abbr = roleFromApi['abbr'];
    roleFromApi['rights']?.forEach((nom, hasRight){
      this.rights[Right.values.firstWhere((right) => right.toString().contains(nom))] = hasRight;
    });
  }

  bool hasRight(Right right) {
    return this.rights[right] ?? false;
  }

  // * --------------------------------------------------------------------------------------------- * //

  static Map<int, Role> list = Map<int, Role>();

  static Role getById(int id){
    return list[id] ?? null;
  }

  // chargement des droits disponibles dans la bdd
  static Future<void> loadRolesList() async{
    list.clear();
    var response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.getAllRoles);
    if(response['status'] == HttpStatus.OK && response['result'] != null){
      response['result'].forEach((roleFromApi){
        list[roleFromApi['roleId']] = Role.fromApi(roleFromApi);
      });
    }
  }

  @override
  String toString(){
    return this.nom;
  }

}