// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Exigence{

  int id;
  String description;
  int priority;
  String type;

  Exigence({int id, String description, int priority, String type}){
    this.id = id;
    this.description = description;
    this.priority = priority;
    this.type = type;
  }

  Exigence.fromApi(Map<String, dynamic> exigenceFromApi){
    this.id = exigenceFromApi['specificationId'];
    this.description = exigenceFromApi['description']?.replaceAll("\n", "");
    this.priority = exigenceFromApi['priority'];
    this.type = exigenceFromApi['type'];
  }
}