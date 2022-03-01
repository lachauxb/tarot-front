// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Epic{

  int idEpic;
  String name;
  String description;
  int vm;

  int idTheme; // thème associé

  Epic(int id, String name, String description, int vm, int idTheme){
    this.idEpic = id;
    this.name = name;
    this.description = description;
    this.vm = vm;
    this.idTheme = idTheme;
  }

  // * --------------------------------------------------------------------------------------------- * //

  static Map<int, Epic> list = Map<int, Epic>();
  static List<Epic> getAll(){
    List<Epic> epics = List<Epic>();
    list.forEach((index, epic) => epics.add(epic));
    return epics;
  }

  static Epic getById(int id){
    return list[id] ?? null;
  }

  // chargement des épics d'un projet donné disponibles dans la bdd
  static Future<void> loadProjectEpicsList(int projectId){
    list.clear();
    return HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.loadProjectEpics.replaceAll("{projectId}", projectId.toString())).then((response){
      if(response['status'] == HttpStatus.OK && response['result'] != null){
        response['result'].forEach((themeEpic){
          if(themeEpic['theme'] != null && themeEpic['epicList'] != null){
            int themeId = themeEpic['theme']['themeId'] ?? null;
            themeEpic['epicList'].forEach((epic){
              list[epic['epicStoryId']] = Epic(epic['epicStoryId'], epic['name'], epic['description'], epic['businessValue'], themeId);
            });
          }
        });
      }
    });
  }

  @override
  String toString(){ return this.name; }
}