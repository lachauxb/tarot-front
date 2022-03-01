// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
import 'package:origin/services/CommentService.dart';
// ** MODEL ** //
import 'package:origin/model/Comment.dart';
import 'package:origin/widgets/Comment/CommentTile.dart';
// ** OTHERS ** //

/// Dialogue de validation des tests
// ignore: must_be_immutable
class CommentDialog extends StatefulWidget {
  final item;
  BuildContext buttonContext;
  CommentDialog({@required this.item, this.buttonContext});

  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog>{
  ScrollController scrollController;
  TextEditingController textEditingController;

  @override
  void initState(){
    super.initState();
    scrollController = ScrollController();
    textEditingController = TextEditingController();
  }

  @override
  void dispose(){
    scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void onSend(){
    if(textEditingController.text.isNotEmpty){
      CommentService.createComment(widget.item, textEditingController.text).then((_) {
        widget.item.reloadComments().then((_){setState(() {});});
      });
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback( (_) => textEditingController.clear());
      });
    }
  }
  
  void onDelete(int commentId){
    setState(() {
      widget.item.comments.removeWhere((Comment comment) => comment.id == commentId);
    });
    CommentService.deleteComment(widget.item, commentId).then((_) {
      widget.item.reloadComments().then((_){setState(() {});});
    });
  }

  void onLike(int commentId){
    setState(() {
      widget.item.comments.firstWhere((comment) => comment.id == commentId).likedByYou = !widget.item.comments.firstWhere((comment) => comment.id == commentId).likedByYou;
    });
    CommentService.likeComment(commentId, widget.item.comments.firstWhere((comment) => comment.id == commentId).likedByYou).then((_){
      widget.item.reloadComments().then((_){setState(() {});});
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.item.comments.sort((Comment a, Comment b) => b.date.compareTo(a.date));
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Commentaires",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: solutecRed,
                ),
              ),
              Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.43,
                ),
                child: widget.item.comments.length > 0 ? ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: widget.item.comments.length,
                  itemBuilder: (BuildContext context, int index){
                    return Align(
                      alignment: widget.item.comments[index].madeByYou ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: constraints.maxWidth * 0.85,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: CommentTile(
                          comment: widget.item.comments[index],
                          onDelete: () => onDelete(widget.item.comments[index].id),
                          onLike: () => onLike(widget.item.comments[index].id),
                        ),
                      ),
                    );
                  },
                ): Text("Aucun commentaire à afficher", style: TextStyle(color: solutecGrey),),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Divider.createBorderSide(context).color, width: Divider.createBorderSide(context).width),),
                ),
                child: TextField(
                  cursorColor: solutecRed,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 2,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    hintText: "Ajouter un commentaire",
                    suffixIcon: GestureDetector(
                      child: Icon(Icons.send),
                      onTap: onSend,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      gapPadding: 0,
                    ),
                  ),
                  onEditingComplete: onSend,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}