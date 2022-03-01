import 'package:origin/model/Story.dart';

class Round{

  Story story;
  Map<int, double> selectedEffortsByPlayer = new Map<int, double>();
  List<double> effortsList;

  Round(Story story){
    this.story = story;

  }

  Round.fromApi(Map<String, dynamic> roundFromApi){
    this.story = Story.fromApi(roundFromApi['story']);
    Map<String, dynamic> effortFromApi = roundFromApi['selectedEffortsByPlayer'];
    effortFromApi.forEach((key, value) {
      this.selectedEffortsByPlayer.putIfAbsent(int.parse(key), () => value);
    });

    this.effortsList = List<double>.from(roundFromApi['effortsList']);
  }

}