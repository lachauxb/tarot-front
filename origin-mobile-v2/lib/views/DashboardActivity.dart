// ** AUTO LOADER ** //
import 'package:flutter/cupertino.dart';
import 'package:origin/config/auto_loader.dart';
// ** MODEL ** //
import 'package:origin/model/Sprint.dart';
import 'package:origin/model/Story.dart';
import 'package:origin/model/StoryState.dart';
import 'package:origin/services/SprintService.dart';
import 'package:origin/services/StoryService.dart';
// ** PACKAGES ** //
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as chartsCommon;
import 'package:origin/widgets/UserTrigram.dart';
import 'package:intl/intl.dart';
// ** SERVICES ** //
// ** OTHERS ** //

class DashboardActivity extends StatefulWidget {
  DashboardActivity({Key key}) : super(key: key);

  @override
  _DashboardActivityState createState() => _DashboardActivityState();
}

class _DashboardActivityState extends State<DashboardActivity> {

  Project project;
  bool isLoading = true;

  List<Story> stories = List<Story>();
  Sprint currentSprint;
  List<dynamic> burnDownDatas;

  loadDatas() async {
    ProjectService.getCurrentProject().then((project){
      this.project = project;
      StoryService.getAllFromProjectID(project.id).then((result){ // chargement des stories

        result.forEach((storyFromApi){
          stories.add(Story.fromApi(storyFromApi));
        });

        SprintService.getRunningSprint(project.id).then((sprintFromApi){ // récupération du sprint courant pour les burn down charts
          if(sprintFromApi != null) {
            currentSprint = Sprint.fromApi(sprintFromApi);
            SprintService.getBurnDown(currentSprint.id).then((result) {
              burnDownDatas = result;
              setState(() => isLoading = false);
            });
          }else
            setState(() => isLoading = false);
        });
      });
    });
  }

  @override
  initState(){
    super.initState();
    loadDatas();
  }

  @override
  Widget build(BuildContext context) {
    return OriginScaffold(
      isLoading: isLoading,
      title: project != null ? project.name : "Chargement...",
      currentViewId: OriginConstants.dashboardViewId,
      body: SingleChildScrollView(
        child: project != null ? Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card( /// Infos générales
                    child:
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap( /// dossier + trigrams
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Icon(Icons.folder, color: solutecRed, size: 40),
                              Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Wrap( /// dossier + trigrams
                                      spacing: 5,
                                      runSpacing: 3,
                                      children: _buildTrigrams()
                                  )
                              )
                            ],
                          ),
                          Divider(),
                          Row( /// dates
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${DateFormat('dd MMM yyyy', 'fr_FR').format(project.beginningDate)} - ${DateFormat('dd MMM yyyy', 'fr_FR').format(project.endingDate)}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column( /// description
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(project.description, style: textStyle),
                            ],
                          ),
                          Divider(),
                          Center(
                              child: Row( /// vm+effort+nbUs+vélocité
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text("VM: ${project.businessValueTerminee.toStringAsFixed(0)}/${project.businessValue.toStringAsFixed(0)}", style: miniStyle),
                                  Text("Effort: ${project.effortTermine.toStringAsFixed(0)}/${project.effort.toStringAsFixed(0)}", style: miniStyle),
                                  Text("US: ${project.nbUSDone.toStringAsFixed(0)}/${project.nbUS.toStringAsFixed(0)}", style: miniStyle),
                                  Text("Vélocité: ${project.velocity.round()}", style: miniStyle), // effort réal/nb sprint terminés
                                ],
                              )
                          )
                        ],
                      ),
                    )

                ),
                Card( /// pie chart
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          stories.length > 0 ? DashboardPieChart(stories) :
                          Padding(
                            padding: EdgeInsets.only(top: 30, bottom: 30),
                            child: Center(
                                child: Text("Aucune story disponible", style: inputStyle)
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("Avancement du projet", style: textStyle,),
                        ],
                      ),
                    )
                ),
                Card( /// graphique burn down vm
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            currentSprint != null ? BurnDownVMChart(burnDownDatas, animate: true) :
                            Padding(
                              padding: EdgeInsets.only(top: 30, bottom: 30),
                              child: Center(
                                  child: Text("Aucun sprint en cours", style: inputStyle)
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Burn Down des Valeurs Métiers du Sprint", style: textStyle),
                          ],
                        )
                    )
                ),
                Card( /// graphique burn down effort
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            currentSprint != null ?
                            BurnDownEffortChart(burnDownDatas, animate: true) :
                            Padding(
                              padding: EdgeInsets.only(top: 30, bottom: 30),
                              child: Center(
                                  child: Text("Aucun sprint en cours", style: inputStyle)
                              ),
                            ),
                            SizedBox(height: 10),
                            Text("Burn Down des Efforts du Sprint", style: textStyle),
                          ]
                        )
                    )
                )
              ]
            )
          )
        ) : Container()
      )
    );
  }

  List<Widget> _buildTrigrams(){
    List<Widget> trigrams = List<Widget>();
    project.members.forEach((member) => trigrams.add(UserTrigram(user: member)) );
    return trigrams;
  }

}

class DashboardPieChart extends StatelessWidget {
  final List<Story> stories;
  final bool animate;
  DashboardPieChart(this.stories, {this.animate});

  final List<PieChartData> datas = List<PieChartData>();
  _init(){
    double toPrepare = 0; double toDo = 0; double inProgress = 0; double done = 0;
    stories.forEach((story){
      switch(story.idStoryState){
        case 1:
        case 2:
        case 3:
          toPrepare++;
          break;
        case 4:
        case 5:
          toDo++;
          break;
        case 6:
        case 7:
          inProgress++;
          break;
        case 8:
          done++;
          break;
        default:
      }
    });

    datas.addAll([
      PieChartData(0, "A programmer", (toPrepare/stories.length)*100, charts.Color.fromHex(code: "#e90649")), // rouge solutec
      PieChartData(1, "A faire", (toDo/stories.length)*100, charts.Color.fromHex(code: "#2196F3")), // bleu
      PieChartData(2, "En cours", (inProgress/stories.length)*100, charts.Color.fromHex(code: "#FF9800")), // orange
      PieChartData(3, "Terminée", (done/stories.length)*100, charts.Color.fromHex(code: "#4CAF50")) // vert
    ]);

  }

  @override
  Widget build(BuildContext context) {
    _init();
    charts.Series<PieChartData, String> seriesList = charts.Series<PieChartData, String>(
      id: 'dashboardPieChart',
      data: datas,
      domainFn: (PieChartData state, _) => state.title,
      measureFn: (PieChartData state, _) => state.percentage,
      colorFn: (PieChartData state, _) => state.color,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (PieChartData state, _) => state.percentage > 2 ? '${state.percentage.round()}%' : '',
      insideLabelStyleAccessorFn: (PieChartData  state, _) => charts.TextStyleSpec(color: charts.Color.white, fontSize: 14),
    );
    return SizedBox(
        height: 200,
        child: charts.PieChart([seriesList],
          animate: animate,
          defaultRenderer: charts.ArcRendererConfig(
              arcRendererDecorators: [charts.ArcLabelDecorator()]
          ),

          // onclick behavior
          selectionModels: [
            charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: (charts.SelectionModel model) {
                final PieChartData data = model.selectedDatum.isNotEmpty ? model.selectedDatum[0]?.datum : null;
                if (data != null) {
                  List<StoryState> states = List<StoryState>();

                  switch(data.id){
                    case 0: // to prepare
                      states.addAll([
                        StoryState.getById(1),
                        StoryState.getById(2),
                        StoryState.getById(3),
                      ]);
                      break;
                    case 1: // todo
                      states.addAll([
                        StoryState.getById(4),
                        StoryState.getById(5),
                      ]);
                      break;
                    case 2: // in progress
                      states.addAll([
                        StoryState.getById(6),
                        StoryState.getById(7),
                      ]);
                      break;
                    case 3: // done
                      states.add(StoryState.getById(8));
                      break;
                  }

                  if(states != null)
                    Navigator.pushNamed(context, OriginConstants.routeBacklog, arguments: states);
                }
              },
            )
          ],

          behaviors: [
            // légende
            charts.DatumLegend(
              position: charts.BehaviorPosition.end,
              horizontalFirst: false,
              // This defines the padding around each legend entry.
              cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0),
              showMeasures: true,
            ),
          ],
        )
    );
  }

}

class PieChartData {
  final int id;
  final String title;
  final double percentage;
  final charts.Color color;
  PieChartData(this.id, this.title, this.percentage, this.color);
}


/// BURN DOWN VM ///

class BurnDownVMChart extends StatefulWidget {
  final List<dynamic> burnDownDatas;
  final bool animate;
  BurnDownVMChart(this.burnDownDatas, {this.animate});

  @override
  State<StatefulWidget> createState() => _BurnDownVMChartState();
}

class _BurnDownVMChartState extends State<BurnDownVMChart>{

  List<dynamic> burnDownDays;
  List<dynamic> burnDownLinearVM;
  List<dynamic> burnDownRealVM;

  List<LinearBurnDown> dataLinear = List<LinearBurnDown>();
  List<LinearBurnDown> dataReal = List<LinearBurnDown>();
  List<charts.Series<LinearBurnDown, int>> seriesList;
  List<charts.TickSpec<num>> daysInChart = List<charts.TickSpec<num>>();

  @override
  void initState() {

    burnDownDays = widget.burnDownDatas[0];
    burnDownLinearVM = widget.burnDownDatas[1];
    burnDownRealVM = widget.burnDownDatas[4];

    for(var i = 0; burnDownDays.length > i && burnDownLinearVM.length > i; i++){
      int day = int.parse(burnDownDays[i]);
      dataLinear.add(new LinearBurnDown(day, double.parse(burnDownLinearVM[i])));
      dataReal.add(new LinearBurnDown(day, double.parse(burnDownRealVM[i])));
      daysInChart.add(charts.TickSpec<num>(day));
    }

    seriesList = [
      new charts.Series<LinearBurnDown, int>(
        id: 'BurnDownVM_linear',
        colorFn: (_, __) => charts.Color(r:25,g:118,b:210),
        domainFn: (LinearBurnDown vm, _) => vm.day,
        measureFn: (LinearBurnDown vm, _) => vm.value,
        data: dataLinear,
      ),
      new charts.Series<LinearBurnDown, int>(
        id: 'BurnDownVM_real',
        colorFn: (_, __) => charts.Color(r:255,g:179,b:0),
        domainFn: (LinearBurnDown vm, _) => vm.day,
        measureFn: (LinearBurnDown vm, _) => vm.value,
        data: dataReal,
      )
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: new charts.LineChart(seriesList,
            animate: widget.animate,
            behaviors: [
              new charts.ChartTitle('Jours',
                  behaviorPosition: charts.BehaviorPosition.bottom,
                  titleStyleSpec: chartsCommon.TextStyleSpec(fontSize: 11),
                  titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
              new charts.ChartTitle('Valeurs Métiers',
                  behaviorPosition: charts.BehaviorPosition.start,
                  titleStyleSpec: chartsCommon.TextStyleSpec(fontSize: 11),
                  titleOutsideJustification: charts.OutsideJustification.middleDrawArea)
            ],
            primaryMeasureAxis: new charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredMinTickCount: 5, desiredMaxTickCount: 10),
            ),
            domainAxis: new charts.NumericAxisSpec(
              tickProviderSpec: charts.StaticNumericTickProviderSpec(daysInChart),
            ),
            defaultRenderer: new charts.LineRendererConfig(includePoints: true))
    );
  }

}

/// BURN DOWN EFFORT ///

class BurnDownEffortChart extends StatefulWidget {
  final List<dynamic> burnDownDatas;
  final bool animate;
  BurnDownEffortChart(this.burnDownDatas, {this.animate});
  @override
  State<StatefulWidget> createState() => _BurnDownEffortChartState();
}

class _BurnDownEffortChartState extends State<BurnDownEffortChart>{

  List<dynamic> burnDownDays;
  List<dynamic> burnDownLinearEffort;
  List<dynamic> burnDownRealEffort;

  List<LinearBurnDown> dataLinear = List<LinearBurnDown>();
  List<LinearBurnDown> dataReal = List<LinearBurnDown>();
  List<charts.Series<LinearBurnDown, int>> seriesList;
  List<charts.TickSpec<num>> daysInChart = List<charts.TickSpec<num>>();

  @override
  void initState() {

    burnDownDays = widget.burnDownDatas[0];
    burnDownLinearEffort = widget.burnDownDatas[2];
    burnDownRealEffort = widget.burnDownDatas[3];

    for(var i = 0; burnDownDays.length > i && burnDownLinearEffort.length > i; i++){
      int day = int.parse(burnDownDays[i]);
      dataLinear.add(new LinearBurnDown(day, double.parse(burnDownLinearEffort[i])));
      dataReal.add(new LinearBurnDown(day, double.parse(burnDownRealEffort[i])));
      daysInChart.add(charts.TickSpec<num>(day));
    }

    seriesList = [
      new charts.Series<LinearBurnDown, int>(
        id: 'BurnDownEffort_linear',
        colorFn: (_, __) => charts.Color(r:25,g:118,b:210),
        domainFn: (LinearBurnDown vm, _) => vm.day,
        measureFn: (LinearBurnDown vm, _) => vm.value,
        data: dataLinear,
      ),
      new charts.Series<LinearBurnDown, int>(
        id: 'BurnDownEffort_real',
        colorFn: (_, __) => charts.Color(r:255,g:179,b:0),
        domainFn: (LinearBurnDown vm, _) => vm.day,
        measureFn: (LinearBurnDown vm, _) => vm.value,
        data: dataReal,
      )
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: new charts.LineChart(seriesList,
            animate: widget.animate,
            behaviors: [
              new charts.ChartTitle('Jours',
                  behaviorPosition: charts.BehaviorPosition.bottom,
                  titleStyleSpec: chartsCommon.TextStyleSpec(fontSize: 11),
                  titleOutsideJustification: charts.OutsideJustification.middleDrawArea),
              new charts.ChartTitle('Efforts',
                  behaviorPosition: charts.BehaviorPosition.start,
                  titleStyleSpec: chartsCommon.TextStyleSpec(fontSize: 11),
                  titleOutsideJustification: charts.OutsideJustification.middleDrawArea)
            ],
            primaryMeasureAxis: new charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredMinTickCount: 5, desiredMaxTickCount: 10),
            ),
            domainAxis: new charts.NumericAxisSpec(
              tickProviderSpec: charts.StaticNumericTickProviderSpec(daysInChart),
            ),
            defaultRenderer: new charts.LineRendererConfig(includePoints: true))
    );
  }

}

class LinearBurnDown{
  final int day;
  final double value;
  LinearBurnDown(this.day, this.value);
}