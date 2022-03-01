// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/services/CommentService.dart';
// ** OTHERS ** //
import 'package:origin/model/Comment.dart';

import 'Story.dart';

class Intersprint {

  int id;
  String nom;
  String description;
  int projectId;
  DateTime beginningDate;
  DateTime endingDate;
  List<Map<String, dynamic>> uncompletedStories = List<Map<String, dynamic>>();
  List<Map<String, dynamic>> exigences;
  List<Comment> comments = List<Comment>();

  Intersprint(int id){
    this.id = id;
  }

  Intersprint.fromApi(Map<String, dynamic> intersprintFromApi){
    this.id = intersprintFromApi["intersprintId"];
    this.nom = intersprintFromApi["nom"];
    this.description = intersprintFromApi["description"];
    this.projectId = intersprintFromApi["project"] != null ? intersprintFromApi["project"]["projectId"] : null;
    this.beginningDate = intersprintFromApi['beginningDate'] != null ? DateTime.parse(intersprintFromApi['beginningDate'].substring(0, 13) + ' -02') : null;
    this.endingDate = intersprintFromApi['endingDate'] != null ? DateTime.parse(intersprintFromApi['endingDate'].substring(0, 13) + ' -02') : null;
    this.exigences = _decodeExigences(intersprintFromApi["exigences"]);
    if(intersprintFromApi['uncompletedStories'] != null)
      intersprintFromApi['uncompletedStories'].forEach((storyFromApi){
        if(storyFromApi["story"] != null){
          this.uncompletedStories.add({
            "id": storyFromApi["intersprintStoryId"],
            "story": Story.fromApi(storyFromApi["story"]),
            "state": storyFromApi["state"] ?? -1
          });
        }
      });
    if(intersprintFromApi['noteList'] != null)
      intersprintFromApi['noteList'].forEach((comment){
        this.comments.add(Comment.fromApi(comment));
      });
  }

  Future<void> reloadComments() async{
    this.comments.clear();
    var commentsFomApi = await CommentService.getAllComments(this);
    commentsFomApi.forEach((comment){
      this.comments.add(Comment.fromApi(comment));
    });
  }

  /* ------------------------------------------------------------------------ */

  static List<Map<String, dynamic>> _decodeExigences(List<dynamic> exigencesFromApi){
    List<Map<String, dynamic>> decodedExigences = List<Map<String, dynamic>>();
    exigencesFromApi.forEach((exigence) => decodedExigences.add(exigence));
    return decodedExigences;
  }

}
