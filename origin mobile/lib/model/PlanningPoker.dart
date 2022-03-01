// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'Player.dart';
import 'Story.dart';
import 'User.dart';
import 'Round.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** OTHERS ** //

class PlanningPoker {

  User host;
  List<Player> players;
  List<User> expectedPlayers;
  List<Story> stories;
  Round round;
  PlanningPokerState state = PlanningPokerState.PARAMETRAGE;
  int usDone = 0;
  int initialStoryCount;

  PlanningPoker();

  PlanningPoker.fromApi(Map<String, dynamic> planningPokerFromApi){
    this.host = User.fromApi(planningPokerFromApi["host"]);
    this.initialStoryCount = planningPokerFromApi["initialStoriesCount"];
    this.usDone = planningPokerFromApi["doneStoriesCount"];

    this.players = List();
    if(planningPokerFromApi["players"] != null)
      planningPokerFromApi["players"].forEach((userId, playerFromApi) => this.players.add(Player.fromApi(playerFromApi)));

    this.expectedPlayers = List();
    if(planningPokerFromApi["expectedPlayers"] != null)
      planningPokerFromApi["expectedPlayers"].forEach((playerFromApi) => this.expectedPlayers.add(User.fromApi(playerFromApi)));

    this.stories = List();
    if(planningPokerFromApi["stories"] != null)
      planningPokerFromApi["stories"].forEach((storyFromApi) => this.stories.add(Story.fromApi(storyFromApi)));
    if(planningPokerFromApi["currentRound"] != null)
      this.round = Round.fromApi(planningPokerFromApi["currentRound"]);

    if(planningPokerFromApi["state"] != null)
      this.state = PlanningPokerState.values.firstWhere((pkState) => pkState.toString().contains(planningPokerFromApi["state"]), orElse: () => PlanningPokerState.PARAMETRAGE);
    else this.state = PlanningPokerState.PARAMETRAGE;
  }

}