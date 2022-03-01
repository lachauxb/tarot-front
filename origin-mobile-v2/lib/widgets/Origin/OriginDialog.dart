import "package:origin/config/auto_loader.dart";

/// Popup (dialog) générique d'Origin
// ignore: must_be_immutable
class OriginDialog extends StatelessWidget {

  final String title;
  List<Widget> content;
  Widget bottom;
  OriginDialog({@required this.title, @required this.content, this.bottom}) : assert(title != null && content != null);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 20),
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(this.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: solutecRed), textAlign: TextAlign.center),
                Divider(),
                SizedBox(height: 15),
                Flexible(
                  child: ListView(
                      shrinkWrap: true,
                      children: this.content
                  ),
                ),
                SizedBox(height: 15),
                this.bottom
              ]
          );
        }),
      )
    );
  }

}