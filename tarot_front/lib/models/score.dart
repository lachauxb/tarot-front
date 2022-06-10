import 'package:tarot_front/models/user.dart';

class Score {
  int id;
  User player;
  int points;
  String announcement;

  Score(this.id, this.player, this.points, this.announcement);
}