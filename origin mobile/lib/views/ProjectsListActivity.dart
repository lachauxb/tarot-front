// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
// ** PACKAGES ** //
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// ** SERVICES ** //
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/model/Project.dart';
import 'package:origin/model/User.dart';
// **  VIEWS   ** //
// **  OTHERS  ** //
import 'package:origin/widgets/ProjectsList/ProjectTile.dart';

class ProjectsListActivity extends StatefulWidget {
  @override
  _ProjectsListActivityState createState() => _ProjectsListActivityState();
}

class _ProjectsListActivityState extends State<ProjectsListActivity> {

  List<Project> projects = List<Project>();
  bool isLoading = true;

  /// RÉCUPÉRATION DES DONNÉES ///

  @override
  initState() {
    super.initState();
    AuthenticationService.getUser().then((User user){
      if(user != null){
        ProjectService.getProjects().then((List<dynamic> projectsMap) {
          projectsMap.forEach((projectFromApi){
            Project pj = Project.fromApi(projectFromApi);
            if(user.hasRight(Right.SEE_ALL_PROJECTS) || (!user.hasRight(Right.SEE_ALL_PROJECTS) && pj.members.firstWhere(((member) => member.id == user.id), orElse: () => null) != null))
              projects.add(pj);
          });
          setState(() {isLoading = false;});
        });

      } else
        setState(() {isLoading = false;});
    });
  }

  /// ACTUALISATION DES DONNÉES ///

  Future<void> _refreshProjects() async{
    projects.clear();
    // Contrairement à l'initState qui utilise .then() pour ne pas bloquer l'application,
    // le refresh utilise await pour le bon fonctionnement du Widget RefreshIndicator
    User user = await AuthenticationService.getUser();
    if(user != null) {
      List<dynamic> projectsMap = await ProjectService.getProjects();
      projectsMap.forEach((projectFromApi){
        Project pj = Project.fromApi(projectFromApi);
        if(user.hasRight(Right.SEE_ALL_PROJECTS) || (!user.hasRight(Right.SEE_ALL_PROJECTS) && pj.members.firstWhere(((member) => member.id == user.id), orElse: () => null) != null))
          projects.add(pj);
      });

    }
    setState((){});
  }

  /// CONSTRUCTION DE LA PAGE ///

  @override
  Widget build(BuildContext context) {
    bool singleTile = projects.length == 1;
    if(projects.isNotEmpty){    // cas principal
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) => OriginScaffold(
        isLoading: isLoading,
        title: "Projets",
        currentViewId: OriginConstants.projectsListViewId,
        body: RefreshIndicator(
          onRefresh: _refreshProjects,
          child: StaggeredGridView.countBuilder(
            // Un projet seul prend toute la largeur de l'écran
            // S'ils sont plus nombreux, ils sont deux par ligne
            crossAxisCount: projects.length > 1 ? 2 : 1,
            shrinkWrap: true,
            padding: EdgeInsets.all(10.0),
            itemCount: projects.length,
            itemBuilder: (context, index){ // retourne la liste des tiles (1 tile = 1 projet)
              return ProjectTile(
                project: projects[index],
                singleTile: singleTile,
              );
            },
            staggeredTileBuilder: (index){
              return StaggeredTile.fit(1);
            },
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
        ),
      ));
    }else{    // Aucun projet à afficher
      return OriginScaffold(
        isLoading: isLoading,
        title: "Projets",
        currentViewId: OriginConstants.projectsListViewId,
        body: RefreshIndicator(
          onRefresh: _refreshProjects,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
                height: MediaQuery.of(context).size.height - Size.fromHeight(kToolbarHeight).height,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text('Aucun projet à afficher', style: TextStyle(color: solutecGrey),),
                        ),
                      ),
                    ]
                )
            ),
          ),
        ),
      );
    }
  }
}
