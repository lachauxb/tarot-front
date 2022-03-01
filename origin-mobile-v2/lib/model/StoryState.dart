// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class StoryState{

  int id;
  String title;
  int number;

  StoryState(int idStoryState, String title, int colorNumber){
    this.id = idStoryState;
    this.title = title;
    this.number = colorNumber;
  }

  static StoryState getById(int id){
    return list[id] ?? null;
  }

  // * --------------------------------------------------------------------------------------------- * //

  static Map<int, StoryState> list = Map<int, StoryState>();
  static List<StoryState> getAll(){
    List<StoryState> states = List<StoryState>();
    list.forEach((index, state) => states.add(state));
    return states;
  }

  // chargement des états d'US disponibles dans la bdd
  static Future<void> loadStateList() async{
    list.clear();
    var response = await HTTPRequestHandler.request(HttpRequest.GET, OriginConstants.loadStoryStates);
    if(response['status'] == HttpStatus.OK && response['result'] != null){
      response['result'].forEach((state){
        list[state['userStoryStateNumber']] = StoryState(state['userStoryStateId'], state['title'], state['userStoryStateNumber']);
      });
    }
  }

  @override
  String toString(){ return this.title; }
}