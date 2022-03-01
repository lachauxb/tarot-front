// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/model/User.dart';
// **  VIEWS   ** //
// **  OTHERS  ** //

class Project{

  int id;
  String name;
  String description;
  List<User> members;
  DateTime beginningDate;
  DateTime endingDate;
  bool planningPokerEnCours;
  // actuellement recalculé lors de la création du projet
  // à prendre de la bd lorsque les valeurs seront fiables
  int nbUS;
  double effort;
  int businessValue;
  double realEffort;
  int realBusinessValue;
  double effortTermine;
  int businessValueTerminee;
  int nbUSDone;
  bool enSprint;
  double velocity;


  Project({this.id, this.name, this.description, this.beginningDate, this.endingDate, this.effort, this.businessValue, this.realEffort, this.realBusinessValue}){
    this.effortTermine = 0;
    this.members = new List<User>();
    this.velocity = 0;
  }

  Project.fromApi(Map<String, dynamic> projectFromApi){
    this.id = projectFromApi["projectId"];
    this.name = projectFromApi["name"]?.replaceAll("\n", "");
    this.description = projectFromApi["description"]?.replaceAll("\n", "");
    this.beginningDate = DateTime.parse(projectFromApi['beginningDate'].substring(0, 13) + ' -02');
    this.endingDate = DateTime.parse(projectFromApi['endingDate'].substring(0, 13) + ' -02');
    this.planningPokerEnCours = projectFromApi["planningPokerEnCours"];
    this.businessValue = projectFromApi["businessValue"];
    this.effort = projectFromApi["effort"];
    this.realBusinessValue = projectFromApi["realBusinessValue"];
    this.realEffort = projectFromApi["realEffort"];
    this.businessValueTerminee = projectFromApi["businessValueTerminee"] ?? 0;
    this.effortTermine = projectFromApi["effortTermine"] ?? 0;
    this.enSprint = projectFromApi["hasSprintRunning"];
    this.velocity = projectFromApi["velocity"] ?? 0;
    this.nbUS = projectFromApi["nbUS"];
    this.nbUSDone = projectFromApi["nbUSTerminee"] ?? 0;

    // Construction des membres du projet
    this.members = new List<User>();
    for(var member in projectFromApi["userList"]){
      this.members.add(User.fromApi(member));
    }

  }

}