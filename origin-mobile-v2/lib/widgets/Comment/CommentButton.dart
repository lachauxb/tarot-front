import 'package:origin/config/auto_loader.dart';
import "package:flutter/material.dart";
import "package:origin/widgets/Comment/CommentDialog.dart";

class CommentButton extends StatefulWidget {
  final item;
  CommentButton({this.item});

  @override
  State<StatefulWidget> createState() => CommentButtonState();
}

class CommentButtonState extends State<CommentButton>{

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => CommentDialog(item: widget.item,),
      ).then((_) => setState((){})),
      child: Container(
        width: 30,
        height: 24,
        alignment: Alignment.topCenter,
        child: Stack(
          children: <Widget>[
            IconButton(
              icon: Icon(widget.item.comments.length > 0 ? Icons.chat_bubble: Icons.chat_bubble_outline, color: solutecGrey,),
              onPressed: null,
              disabledColor: solutecGrey,
              padding: EdgeInsets.all(0.0),
              alignment: Alignment.topCenter,
            ),
            widget.item.comments.length > 0 ? Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 15,
                width: 15,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: solutecRed,
                ),
                child: Text(widget.item.comments.length < 10 ? widget.item.comments.length.toString() : "9+",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold,),
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}