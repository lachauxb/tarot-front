import 'package:flutter/material.dart';
import 'package:origin/widgets/PriorityChip.dart';

// Liste des constantes du projet Origin utilisables dans toute l'application (comme c'est un widget, hot reload actif + performances optimales)
class OriginConstants extends InheritedWidget {

  static OriginConstants of(BuildContext context) => context. dependOnInheritedWidgetOfExactType<OriginConstants>();
  const OriginConstants({Widget child, Key key}): super(key: key, child: child);
  @override
  bool updateShouldNotify(OriginConstants oldWidget) => false;

  // * --------------------------------------------------------------------------------------------------------------------------------------------- * //

  // ** LISTE DES CONSTANTES DE CONFIGURATION ** //
  static const String _root = "package:origin"; // root folder
  static const String configRoot = "$_root/config/"; // regroupe les paramètres de configuration de l'application
  static const String coreRoot = "$_root/core/"; // regroupe les outils nécessaires au bon fonctionnement de l'application
  static const String servicesRoot = "$_root/services/"; // regroupe les différents services de l'application
  static const String viewsRoot = "$_root/views/"; // regroupe l'ensemble des interfaces d'origin

  static const String routeLogin = "/login";
  static const String routeProjectsList = "/projects";
  static const String routeDashboard = "/dashboard";
  static const String routeBacklog = "/backlog";
  static const String routeSprint = "/sprint";
  static const String routeIntersprint = "/intersprint";
  static const String routeUserManagement = "/userManagement";
  static const String routeStory = "/story";
  static const String routePlanningPoker = "/planningPoker";

  static final String loginViewId = "Login";
  static final String projectsListViewId = "Mes Projets";
  static final String dashboardViewId = "Dashboard";
  static final String backlogViewId = "Backlog";
  static final String sprintViewId = "Sprint";
  static final String intersprintViewId = "Intersprint";
  static final String userManagementViewId = "Gestion Utilisateurs";
  static final String storyViewId = "Story";
  static final String planningPokerViewId = "Planning Poker";

  // ** LISTE DES CONSTANTES FONCTIONNELLES ** //
  //static const String urlApi_backEnd = "origin.api.lab.solutec"; //#prod
  //static const String urlApi_backEnd = "origin.api.preprod.lab.solutec"; //#préprod
  static const String urlApi_backEnd = "10.1.48.133:8080"; // url de l'api du back end d'origin #vm
  //static const String urlApi_backEnd = "10.1.68.86:8080"; // #Docker
  static const String tokenId = "storedToken";

  // ** LISTE DES CONSTANTES D'ACTIONS API ** //
  /// GET
  static const String ping = "ping";
  static const String login = "login";
  static const String getUser = "findUser";
  static const String getAllUsers = "users";
  static const String getProjects = "projects";
  static const String getProjectById = "projects/{id}";
  static const String getProjectStories = "projects/{idProject}/stories";
  static const String getProjectFollowTasks = "projects/{projectId}/followTasks";
  static const String getProjectExigences = "projects/{projectId}/specifications";
  static const String getRunningSprint = "projects/{id}/sprintRunning";
  static const String getStoryTasks = "stories/{storyId}/tasks";
  static const String getUserProjects = "myProjects";
  static const String getProjectMembers = "projects/{projectId}/users";
  static const String getProjectLastSprint = "projects/{projectId}/lastSprint";
  static const String getProjectsWithDetails = "projectsWithDetails";
  static const String getProjectSprints = "projects/{projectId}/sprints";
  static const String getSprintStories = "sprints/{sprintId}/stories";
  static const String getSprintFollowTasks = "sprints/{id}/followTasks";
  static const String getSprintFollowTasksEffort = "sprints/{id}/followTasksEffort";
  static const String getBurnDown = "sprints/{sprintId}/burnDown";
  static const String getAllRoles = "roles";
  static const String getAllRights = "rights";
  static const String loadStoryStates = "userStoryStates";
  static const String loadPriorities = "priorities";
  static const String loadProjectThemes = "projects/{projectId}/themes";
  static const String loadProjectEpics = "projects/{projectId}/themes/epics";
  static const String loadProjectActors = "projects/{projectId}/actors";
  static const String getStoryById = "stories/{storyId}";
  static const String getStoryUsers = "stories/{storyId}/users";
  static const String getStoryComments = "stories/{storyId}/comments";
  static const String getSprintComments = "sprints/{sprintId}/comments";
  static const String getIntersprintComments = "intersprints/{intersprintId}/comments";
  static const String getTaskComments = "tasks/{taskId}/comments";
  static const String getProjectIntersprints = "projects/{projectId}/intersprints";
  static const String getUserNotifications = "notifications/{userId}/getUserNotifications";
  static const String getSprintById = "sprints/{sprintId}";
  static const String getTaskById = "tasks/{taskId}";
  static const String getPlanningPoker = "planning_poker/{projectId}";
  /// POST
  static const String updateIntersprintExigences = "intersprints/{intersprintId}/setExigences";
  static const String updateUserRole = "users/role";
  static const String updateRoleRights = "roles/{roleId}/updateRight/{rightId}";
  static const String pingTest = "test";
  static const String createStoryComment = "stories/{storyId}/comments";
  static const String createSprintComment = "sprints/{sprintId}/comments";
  static const String createIntersprintComment = "intersprints/{intersprintId}/comments";
  static const String createTaskComment = "tasks/{taskId}/comments";
  static const String likeComment = "notes/{noteId}/likes";
  static const String updateIntersprintStoryState = "intersprints/{intersprintStoryId}/setIntersprintStoryState";
  static const String updatePushNotificationToken = "users/pushNotificationToken";
  static const String updatePlanningPokerParams = "planning_poker/{projectId}/params/{withEffort}";
  static const String updatePlanningPokerObserver = "planning_poker/{projectId}/observer/";
  static const String endPlanningPokerRound = "planning_poker/{projectId}/endRound";
  static const String dismissNotification = "notifications/{notificationId}";
  /// PUT
  static const String changeTaskState = "tasks/{taskId}/taskStates";
  static const String changeTestState = "tests/{testId}/checked";
  static const String updateStoryUsers = "stories/{storyId}/users";
  static const String updateStory = "stories/{storyId}";
  static const String updateFollowTask = "followTasks/{followTaskId}";
  /// DELETE
  static const String deleteStoryComment = "stories/{storyId}/note/{noteId}";
  static const String deleteSprintComment = "sprints/{sprintId}/note/{noteId}";
  static const String deleteIntersprintComment = "intersprints/{intersprintId}/note/{noteId}";
  static const String deleteTaskComment = "tasks/{taskId}/note/{noteId}";


  // ** CONSTANTE DES COULEURS D'ÉTATS DES STORIES ** //
  static const Map<int, Color> sprintStateToColor = {1: Colors.orange, 2: Colors.orange, 3: Colors.lightBlue, 4: Colors.lightBlue, 5: Colors.lightGreen};
  static const Map<int, Color> storyStateToColor = {1: Colors.grey, 2: Colors.grey, 3: Colors.grey, 4: Colors.blue, 5: Colors.blue, 6: Colors.orange, 7: Colors.amber, 8: Colors.green};
  static const Map<int, Color> taskStateToColor = {2: Color(0xFF90A4E1), 3: Color(0xFFFFB74D), 4: Color(0xFFFFD54F), 5: Color(0xFF81C784)};
  static const Map<int, String> sprintStateToText = {1: "A remplir", 2: "A lancer", 3: "En cours", 4: "En revue", 5: "Clôturé"};
  static const Map<int, String> storyStateToText = {1: "A programmer", 2: "A programmer", 3: "A programmer", 4: "A faire", 5: "A faire", 6: "En cours", 7: "A tester", 8: "Terminée"};
  static const Map<int, String> storyStateToShortText = {1: "A prog.", 2: "A prog.", 3: "A prog.", 4: "A faire", 5: "A faire", 6: "En cours", 7: "A tester", 8: "Terminée"};
  static const Map<int, String> taskStateToText = {2: "A faire", 3: "En cours", 4: "A tester", 5: "Terminée"};
  // ** CONSTANTE DES ICÔNES DE PRIORITÉ DES STORIES ** //
  static const Widget basicPriorityWidget = const PriorityChip(content: "bas.", backgroundColor: Color(0xFF646e7a),horizontalPadding: 17,);
  static const Widget linearPriorityWidget = const PriorityChip(content: "lin.", backgroundColor: Color(0xFF929ca8),horizontalPadding: 13,);
  static const Widget enthusiasticPriorityWidget = const PriorityChip(content: "ent.", backgroundColor: Color(0xFFbfc8d4),horizontalPadding: 5,);
  static const Map<int, Widget> priorityToIcon = {1: basicPriorityWidget, 2: linearPriorityWidget, 3: enthusiasticPriorityWidget};
  // ** CONSTANTE DE DROITS **//
  static const Map<Right, String> rightsMobileName = {Right.SEE_ALL_PROJECTS: "Consulter tous les projets", Right.UPDATE_USER_ROLE: "Modifier le rôle d'un utilisateur", Right.UPDATE_ROLE_RIGHTS: "Modifier les rôles"};
  // ** CONSTANTES DE TAILLE ** //
  static const Size userTrigramSize = Size(55, 33);
  static const Size userTrigramWithIconSize = Size(75, 33);
  static const double storyStateChipWidth = 80;
  static const double storyStateChipHeight = 35;
  static const double sprintStateChipWidth = 80;
  static const double sprintStateChipHeight = 35;
  // ** CONSTANTES DU PLANNING POKER ** //
  static const List<double> planningPokerValues = [0.5, 1, 2, 3, 5, 8, 13, 20, 40, 100];

}

// ** LISTE DES ÉNUMÉRATIONS ** //
enum GroupByID {
  NONE,
  THEME,
  EPIC,
  STATE,
  PRIORITY,
  SPRINT
}

enum Right {
  SEE_ALL_PROJECTS,
  UPDATE_USER_ROLE,
  UPDATE_ROLE_RIGHTS
}

enum PlanningPokerState {
  NULL,
  PARAMETRAGE,
  EN_COURS,
  TERMINE
}