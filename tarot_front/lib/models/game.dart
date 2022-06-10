import 'package:tarot_front/models/round.dart';


class Game {
  int id;
  DateTime date;
  List<Round> roundList;

  Game(this.id, this.date, this.roundList);
}