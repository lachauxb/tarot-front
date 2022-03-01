// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:intl/intl.dart';
// ** SERVICES ** //
// ** MODEL ** //
import 'package:origin/model/Comment.dart';
import 'package:origin/widgets/UserTrigram.dart';
// ** OTHERS ** //

class CommentTile extends StatefulWidget{
  final Comment comment;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  CommentTile({this.comment, this.onDelete, this.onLike});

  @override
  _CommentTileState createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile>{

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 3, spreadRadius: 1)], // Élévation
      ),
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      padding: EdgeInsets.all(5.0),
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                UserTrigram(user: widget.comment.author),
                Container(
                  padding: EdgeInsets.only(left: 5.0,),
                  width: constraints.maxWidth - OriginConstants.userTrigramSize.width,
                  child: Text(widget.comment.content),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 24,
                        width: 24,
                        margin: EdgeInsets.only(right: 2),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: widget.comment.likedByYou ? Icon(Icons.favorite, color: solutecRed,): Icon(Icons.favorite_border, color: solutecGrey,),
                          onPressed: (){
                            widget.onLike();
                          },
                        ),
                      ),
                      Text(widget.comment.likes.length.toString()),
                      widget.comment.madeByYou ?
                      Container(
                        height: 24,
                        width: 24,
                        margin: EdgeInsets.only(left: 10),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          icon: Icon(Icons.delete_outline, color: solutecGrey,),
                          onPressed: widget.onDelete,
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                Container(
                  child: Text(DateFormat('dd/MM/yyyy | HH:mm', 'fr_FR').format(widget.comment.date),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13,),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}