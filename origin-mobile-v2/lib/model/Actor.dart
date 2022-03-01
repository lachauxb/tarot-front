// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Actor{

  int idActor;
  String name;
  String description;

  Actor(int id, String name, String description){
    this.idActor = id;
    this.name = name;
    this.description = description;
  }

  static Actor getById(int id){
    return list[id] ?? null;
  }

  // * --------------------------------------------------------------------------------------------- * //

  static Map<int, Actor> list = Map<int, Actor>();
  static List<Actor> getAll(){
    List<Actor> actors = List<Actor>();
    list.forEach((index, actor) => actors.add(actor));
    return actors;
  }

  // chargement des acteurs d'un projet donné disponibles dans la bdd
  static Future<void> loadProjectActorsList(int projectId){
    list.clear();
    return HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.loadProjectActors.replaceAll("{projectId}", projectId.toString())).then((response){
      if(response['status'] == HttpStatus.OK && response['result'] != null){
        response['result'].forEach((actor){
          list[actor['actorId']] = Actor(actor['actorId'], actor['name'], actor['description']);
        });
      }
    });
  }

  @override
  String toString(){ return this.name; }
}