// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Intersprint.dart';
import 'package:origin/services/IntersprintService.dart';
import 'package:origin/widgets/Intersprint/IntersprintView.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** MODEL ** //
// ** OTHERS ** //

/// Activité représentant la liste des intersprints d'un projet avec la liste des différentes tâches
class IntersprintActivity extends StatefulWidget {
  @override
  _IntersprintActivityState createState() => _IntersprintActivityState();
}

class _IntersprintActivityState extends State<IntersprintActivity> with TickerProviderStateMixin{

  Project _project;
  List<Intersprint> intersprints = List<Intersprint>();
  Intersprint visibleIntersprint;
  Map<int, List<Map<String, dynamic>>> selectedExigencesPerTab = Map<int, List<Map<String, dynamic>>>();
  Map<int, int> _indexToId = Map<int, int>();

  TabController _tabController;
  bool _isLoading = true;

  loadDatas({int oldIndex = 0}) async{
    int counter = 0;
    ProjectService.getCurrentProject().then((project){
      this._project = project;

      IntersprintService.getIntersprints(_project.id).then((List<dynamic> intersprintsFromApi){
        intersprintsFromApi.forEach((intersprintFromApi) => intersprints.add(Intersprint.fromApi(intersprintFromApi)));
        intersprints.sort((a, b) => b.beginningDate.compareTo(a.beginningDate));

        if(intersprints.length > 0) {
          visibleIntersprint = intersprints.first;
          intersprints.forEach((intersprint) {
            selectedExigencesPerTab[intersprint.id] = List<Map<String, dynamic>>();
            _indexToId[counter++] = intersprint.id;
          });
          _tabController = TabController(length: intersprints.length, vsync: this, initialIndex: oldIndex)..addListener(() => setState(() => visibleIntersprint = intersprints.elementAt(_tabController.index)));
        }

        setState(() => _isLoading = false );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadDatas();
  }

  @override
  Widget build(BuildContext context) {
    if(intersprints.isNotEmpty) {
      return OriginScaffold(
        isLoading: _isLoading,
        title: _project != null ? _project.name : "Chargement...",
        currentViewId: OriginConstants.intersprintViewId,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: views(),
        ),
        bottomTabBar: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs(),
        ),
        floatingActionButton: selectedExigencesPerTab[_indexToId[_tabController.index]].length > 0 ? FloatingActionButton(
            child: Icon(Icons.delete_outline),
            onPressed: (){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: Text("Êtes-vous sûr de vouloir supprimer ces tâches ?", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),),
                    titlePadding: EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 12.0),
                    contentPadding: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                    children: <Widget>[
                      ButtonBar(
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Annuler", style: TextStyle(color: solutecRed, fontSize: 14),),
                          ),
                          SizedBox(
                            width: 120,
                            height: 35,
                            child: RaisedButton(
                              color: solutecRed,
                              onPressed: () {
                                selectedExigencesPerTab[_indexToId[_tabController.index]].forEach((exigence) => visibleIntersprint.exigences.remove(exigence));
                                IntersprintService.updateExigences(visibleIntersprint).then((result){
                                  Navigator.of(context).pop();
                                  setState((){
                                    if(result == null) {
                                      Toast.alert(context);
                                      visibleIntersprint.exigences.addAll(selectedExigencesPerTab[_indexToId[_tabController.index]]);
                                    }else{
                                      selectedExigencesPerTab[_indexToId[_tabController.index]].clear();
                                    }
                                  });
                                });
                              },
                              child: Text("Supprimer", style: TextStyle(fontSize: 15),),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
        ) : null,
      );
    } else {
      return OriginScaffold(
          isLoading: _isLoading,
          title: _project != null ? _project.name : "Chargement...",
          currentViewId: OriginConstants.intersprintViewId,
          body: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text('Aucun intersprint à afficher', style: TextStyle(color: solutecGrey))
                  )
              )
          )
      );
    }
  }

  /* ------------------------------------------------------------------------ */

  Future<void> _refresh() async {
    intersprints.clear();
    await loadDatas(oldIndex: _tabController.index);
  }

  /// construction des visuels des onglets
  List<Widget> tabs(){
    List<Widget> tabs = List<Widget>();
    intersprints.forEach((Intersprint intersprint) => tabs.add(
        Tab(
            child: Text(intersprint.nom)
        )
    ));
    return tabs;
  }

  /// liste des contenus des onglets
  List<Widget> views(){
    List<Widget> views = List<Widget>();
    intersprints.forEach((intersprint) => views.add(IntersprintView(intersprint, refreshExigences: _refresh, selectedExigences: selectedExigencesPerTab[intersprint.id], onSelection: () => setState((){}))));
    return views;
  }

}