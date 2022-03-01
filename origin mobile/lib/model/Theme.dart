// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Theme{

  int idTheme;
  String name;
  String description;
  int vm;

  Theme(int id, String name, String description, int vm){
    this.idTheme = id;
    this.name = name;
    this.description = description;
    this.vm = vm;
  }

  // * --------------------------------------------------------------------------------------------- * //

  static Map<int, Theme> list = Map<int, Theme>();
  static List<Theme> getAll(){
    List<Theme> themes = List<Theme>();
    list.forEach((index, theme) => themes.add(theme));
    return themes;
  }

  static Theme getById(int id){
    return list[id] ?? null;
  }

  // chargement des thèmes d'un projet donné disponibles dans la bdd
  static Future<void> loadProjectThemesList(int projectId){
    list.clear();
    return HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.loadProjectThemes.replaceAll("{projectId}", projectId.toString())).then((response){
      if(response['status'] == HttpStatus.OK && response['result'] != null){
        response['result'].forEach((theme){
          list[theme['themeId']] = Theme(theme['themeId'], theme['themeName'], theme['themeDescription'], theme['themeBusinessValue']);
        });
      }
    });
  }

  @override
  String toString(){ return this.name; }
}