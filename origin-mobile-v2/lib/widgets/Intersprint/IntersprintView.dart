// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/Intersprint.dart';
import 'package:origin/services/IntersprintService.dart';
import 'package:origin/widgets/Backlog/StoryViewInBacklog.dart';
// ** PACKAGES ** //

// ignore: must_be_immutable
class IntersprintView extends StatefulWidget {
  final Intersprint intersprint;
  final Function refreshExigences;
  final Function refreshStories;
  List<Map<String, dynamic>> selectedExigences;
  final Function onSelection;
  IntersprintView(this.intersprint, {this.refreshExigences, this.selectedExigences, this.refreshStories, this.onSelection});

  @override
  _IntersprintViewState createState() => _IntersprintViewState();
}

class _IntersprintViewState extends State<IntersprintView>{

  TextEditingController _inputController = TextEditingController();
  TextEditingController _editingController = TextEditingController();

  Map<String, dynamic> _editingExigence;

  @override
  void initState() {
    super.initState();
    if(widget.selectedExigences == null)
      widget.selectedExigences = List<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext mainContext, BoxConstraints mainConstraints){
      return Container(
          padding: EdgeInsets.all(20),
          child: IntrinsicHeight(
              child: Column(
                  children: <Widget>[
                    Row(
                        children: <Widget>[
                          Expanded(
                              child: TextField(
                                  controller: _inputController,
                                  onChanged: _inputController.text.length <= 1 ? (_) => setState((){}) : null,
                                  decoration: InputDecoration(
                                    labelText: "Ajouter une tâche",
                                    hintText: "Nouvelle tâche...",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  )
                              )
                          ),
                          SizedBox(
                              width: 60,
                              child: MaterialButton(
                                padding: EdgeInsets.all(10),
                                shape: CircleBorder(),
                                color: solutecRed,
                                textColor: Colors.white,
                                disabledColor: Colors.red[200],
                                disabledTextColor: Colors.white,
                                disabledElevation: 2,
                                child: Icon(Icons.add),
                                onPressed: _inputController.text.isNotEmpty ? (){
                                  widget.intersprint.exigences.insert(0, {"name": _inputController.text, "done": false});
                                  setState(() => _inputController.text = "");
                                  _updateExigences();
                                } : null,
                              )
                          )
                        ]
                    ),
                    Expanded(
                        child: Stack(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(bottom: widget.intersprint.uncompletedStories.length > 0 ? 50 : 0),
                                child: ListView(children: _buildExigences())
                            ),
                            widget.intersprint.uncompletedStories.length > 0 ? DraggableScrollableSheet(
                                initialChildSize: 0.1,
                                minChildSize: 0.1,
                                maxChildSize: 0.9,
                                builder: (BuildContext draggableContext, ScrollController scrollController){
                                  return Container(
                                      color: OriginScaffold.backgroundColor,
                                      child: ListView(
                                          controller: scrollController,
                                          children: _buildUncompletedStories()
                                      )
                                  );
                                }
                            ) : Text(""),
                          ],
                        )
                    )
                  ]
              )
          )
      );
    });
  }

  /* ------------------------------------------------------------------------ */

  List<Widget> _buildExigences(){
    List<Widget> exigences = List<Widget>();
    widget.intersprint.exigences.forEach((Map<String, dynamic> exigence) => exigences.add(
        GestureDetector(
            onTap: () => setState((){
              if(widget.selectedExigences.length > 0){ // sélection d'exigences en cours...
                widget.selectedExigences.contains(exigence) ? widget.selectedExigences.remove(exigence) : widget.selectedExigences.add(exigence);
                if(widget.onSelection != null)
                  widget.onSelection();
              }else{ // comportement classique
                exigence["done"] = !exigence["done"];
                _updateExigences();
              }
            }),
            onLongPress: () => setState((){
              widget.selectedExigences.add(exigence);
              if(widget.onSelection != null)
                widget.onSelection();
            }),
            onDoubleTap: (){
              if(_editingExigence == null){
                setState(() {
                  _editingExigence = exigence;
                  _editingController.text = exigence["name"];
                });
              }
            },
            child: Card(
                color: widget.selectedExigences.contains(exigence) ? Colors.grey[300] : Colors.white,
                child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Wrap(
                              children: <Widget>[
                                _editingExigence == exigence ? TextField(
                                  controller: _editingController,
                                  autofocus: true,
                                  onSubmitted: (newName){
                                    setState(() {
                                      exigence["name"] = newName;
                                      _editingExigence = null;
                                      _editingController.text = "";
                                    });
                                    _updateExigences();
                                  },
                                ) : Text(exigence["name"], style: textStyle)
                              ],
                            )
                        ),
                        SizedBox(
                            width: 50,
                            child: Row(
                              children: <Widget>[
                                Checkbox(
                                  value: exigence["done"],
                                  onChanged: (value){ setState(() => exigence["done"] = !exigence["done"]); _updateExigences(); },
                                )
                              ],
                            )
                        )
                      ],
                    )
                )
            )
        )
    ));
    return exigences;
  }

  void _updateExigences(){
    IntersprintService.updateExigences(widget.intersprint).then((result){
      if(result == null)
        Toast.alert(context);
    });
  }

  List<Widget> _buildUncompletedStories(){
    List<Widget> stories = List<Widget>();
    stories.add(Align(alignment: Alignment.center, child: Icon(Icons.keyboard_arrow_up)));
    if(widget.intersprint.uncompletedStories.length > 0){
      int vmMax = widget.intersprint.uncompletedStories.length >= 2 ? widget.intersprint.uncompletedStories.reduce((Map<String, dynamic> s1, Map<String, dynamic> s2) => s1["story"].vm > s2["story"].vm ? s1 : s2)["story"].vm : widget.intersprint.uncompletedStories.first["story"].vm;
      widget.intersprint.uncompletedStories.forEach((Map<String, dynamic> intersprintStory) => stories.add(Wrap(
        children: <Widget>[
          StoryViewInBacklog(story: intersprintStory["story"], width: MediaQuery.of(context).size.width, vmMax: vmMax),
          intersprintStory["state"] == 0 ? GestureDetector(
              onTap: () => _updateIntersprintStoryState(intersprintStory, 1),
              child: Card(
                  child: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.blue),
                          Text("Ré-embarquer", style: TextStyle(color: Colors.blue))
                        ],
                      )
                  )
              )
          ) : Text(""),
          intersprintStory["state"] == 1 ? Card(
              child: Container(
                  padding: EdgeInsets.only(left: 3, right: 3),
                  child: Text("Ré-embarquée", style: TextStyle(color: Colors.blue))
              )
          ) : Text(""),
          intersprintStory["state"] == 0 ? GestureDetector(
              onTap: () => _updateIntersprintStoryState(intersprintStory, 2),
              child: Card(
                  child: Container(
                      padding: EdgeInsets.only(right: 5),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(Icons.close, color: Colors.red),
                          Text("Abandonner", style: TextStyle(color: Colors.red))
                        ],
                      )
                  )
              )
          ) : Text(""),
          intersprintStory["state"] == 2 ? Card(
              child: Container(
                  padding: EdgeInsets.only(left: 3, right: 3),
                  child: Text("Abandonnée", style: TextStyle(color: Colors.red))
              )
          ) : Text("")
        ],
      )));
    }
    return stories;
  }

  _updateIntersprintStoryState(Map<String, dynamic> intersprintStory, int newState){
    setState(() => intersprintStory["state"] = newState);
    IntersprintService.updateIntersprintStoryState(intersprintStory).then((intersprintStoryFromApi){
      if(intersprintStoryFromApi == null){
        setState(() => intersprintStory["state"] = 0);
        Toast(
            context: context,
            message: "Aucun sprint trouvé pour ré-embarquer la Story !",
            type: ToastType.WARNING,
            duration: Duration(seconds: 3)
        ).show();
      }else if(intersprintStoryFromApi["state"] != newState){
        setState(() => intersprintStory["state"] = 0);
        Toast.alert(context);
      }
    });
  }

}


