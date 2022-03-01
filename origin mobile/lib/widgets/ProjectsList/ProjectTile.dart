import 'package:origin/config/auto_loader.dart';
// Extra imports
import 'package:intl/intl.dart';
import 'package:origin/widgets/ProjectsList/TimeProgressBar.dart';
import 'package:origin/widgets/ProjectsList/EffortProgressBar.dart';

// ignore: must_be_immutable
class ProjectTile extends StatefulWidget {

  final Project project; // projet utilisé pour build la tile associé
  bool singleTile = false;

  ProjectTile({
    @required this.project,
    this.singleTile
  }) : assert(project != null);

  @override
  State<StatefulWidget> createState() => _ProjectTileState();
}

class _ProjectTileState extends State<ProjectTile>{

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: <Widget>[
            // Bandeau rouge en haut des tiles de projet
            Container(
              height: 7,
              decoration: BoxDecoration(
                color: solutecRed,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0)),
              ),
            ),
            GestureDetector(
              onTap: () async {
                ProjectService.setCurrentProject(widget.project);
                Navigator.pushNamed(context, await ProjectService.getRoute());
              },
              child: Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 3, spreadRadius: 1)], // Élévation
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Titre
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: widget.singleTile ? 5 : 2),
                      child: Text(widget.project.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.singleTile ? 20 : 16, color: solutecGrey,),
                      ),
                    ),
                    // Date
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: widget.singleTile ? 3 : 0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown, // Force la police à une taille qui fait tenir la date sur une ligne
                        child: Text('${DateFormat('dd MMM yyyy', 'fr_FR').format(widget.project.beginningDate)} - ${DateFormat('dd MMM yyyy', 'fr_FR').format(widget.project.endingDate)}',
                          style: TextStyle(color: Colors.grey,),
                        ),
                      ),
                    ),
                    // Barre de de progression temporelle du projet
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: widget.singleTile ? 8 : 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.watch_later, color: solutecGrey,),
                          TimeProgressBar(now: DateTime.now(), beginningDate: widget.project.beginningDate, endingDate: widget.project.endingDate),
                        ],
                      ),
                    ),
                    // Barre de progression des tâches du projet
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: widget.singleTile ? 8 : 5),
                      child: Row(
                        children: <Widget>[
                          widget.project.enSprint ? Icon(Icons.flash_on, color: Colors.amber,) : Icon(Icons.hotel, color: solutecGrey,),
                          EffortProgressBar(effortTermine: widget.project.effortTermine, sumEffort: widget.project.effort),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );},
      ),
    );
  }

}