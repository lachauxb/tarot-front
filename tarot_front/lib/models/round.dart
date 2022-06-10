import 'package:tarot_front/models/score.dart';
import 'package:tarot_front/models/user.dart';

class Round {
  int id;
  List<Score> scoreList;
  User taker;
  User called;

  Round(this.id, this.scoreList, this.taker, this.called);
}