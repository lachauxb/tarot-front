// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class Priority{

  int idPriority;
  String title;
  int number;
  Widget icon;

  Priority(int id, String title, int number){
    this.idPriority = id;
    this.title = title;
    this.number = number;
    this.icon = OriginConstants.priorityToIcon[number];
  }

  // * --------------------------------------------------------------------------------------------- * //

  static Map<int, Priority> list = Map<int, Priority>();
  static List<Priority> getAll() {
    return list.values.toList();
  }

  static Priority getById(int id){
    return list[id] ?? null;
  }

  // chargement des priorités disponibles dans la bdd
  static Future<void> loadPriorityList() async{
    list.clear();
    var response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.loadPriorities);
    if(response['status'] == HttpStatus.OK && response['result'] != null){
      response['result'].forEach((priority){
        list[priority['priorityId']] = Priority(priority['priorityId'], priority['title'], priority['priorityNumber']);
      });
    }
  }

}