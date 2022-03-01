// ** AUTO LOADER ** //
// ** PACKAGES ** //
// ** SERVICES ** //
// ** MODEL ** //
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
// ** OTHERS ** //

class Comment {
  int id;
  String content;
  DateTime date;
  User author;
  List<User> likes = List<User>();
  bool likedByYou = false;
  bool madeByYou = false;

  Comment({this.content, this.date, this.madeByYou = true});

  Comment.fromApi(Map<String, dynamic> commentFromApi){
    this.id = commentFromApi["noteId"];
    this.content = commentFromApi["comment"];
    this.date = commentFromApi["date"] != null ? DateTime.parse(commentFromApi["date"].substring(0,19)).add(Duration(hours: 2)) : null;
    this.author = User.fromApi(commentFromApi["user"]);
    if(commentFromApi["likeList"] != null) {
      commentFromApi["likeList"].forEach((user) {
        likes.add(User.fromApi(user));
      });
    }
    _isMadeByYou();
    _isLikedByYou();
  }
  void _isMadeByYou() async => this.madeByYou = this.author == await AuthenticationService.getUser();
  void _isLikedByYou() async => this.likedByYou = this.likes.contains(await AuthenticationService.getUser());
}
