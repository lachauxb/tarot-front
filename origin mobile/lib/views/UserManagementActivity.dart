// ** AUTO LOADER ** //
import 'package:origin/config/auto_loader.dart';
import 'package:origin/model/Role.dart';
import 'package:origin/model/User.dart';
import 'package:origin/services/AuthenticationService.dart';
import 'package:origin/services/UserService.dart';
// ** PACKAGES ** //
// ** SERVICES ** //
// ** MODEL ** //
// ** OTHERS ** //



class UserManagementActivity extends StatefulWidget {
  UserManagementActivity({Key key}) : super(key: key);

  @override
  _UserManagementActivityState createState() => _UserManagementActivityState();
}

class _UserManagementActivityState extends State<UserManagementActivity> {

  User currentUser;

  bool _isLoading = true;
  List<User> users = List<User>();
  List<User> usersToShow = List<User>();
  List<User> _selectedCards = List<User>();

  @override
  void initState(){
    loadDatas();
    super.initState();
  }

  loadDatas() async{
    currentUser = await AuthenticationService.getUser();
    UserService.getAllUsers().then((result){
      result.forEach((user) => users.add(User.fromApi(user)));
      usersToShow = _sortUsers(users);
      setState(() {_isLoading = false;});
    });
  }

  _sortUsers(List<User> users){
    List<User> admins = List<User>();
    List<User> others = List<User>();

    users.forEach((User user){
      user.getRole().abbr == "Admin" ? admins.add(user) : others.add(user);
    });

    admins.sort((User first, User second){
      return first.compareTo(second);
    });
    others.sort((User first, User second){
      return first.compareTo(second);
    });

    List<User> sortedUsers = List<User>();
    sortedUsers.addAll(admins);
    sortedUsers.addAll(others);
    return sortedUsers;
  }



  Future<void> _refreshUsers() async{
    users.clear(); usersToShow.clear(); _selectedCards.clear();
    var result = await UserService.getAllUsers();
    result.forEach((user) => users.add(User.fromApi(user)));
    usersToShow = _sortUsers(users);
    setState((){});
    StateProvider().notify(ObserverState.LIST_REFRESHED);
  }



  @override
  Widget build(BuildContext context) {
    return OriginScaffold(
      isLoading: _isLoading,
        title: "Gestion des utilisateurs",
        currentViewId: OriginConstants.userManagementViewId,
        body: Padding(
          padding: EdgeInsets.only(top: 12),
          child: Column(
            children: <Widget>[
              SearchBar<User>(
                label: "Rechercher",
                hint: "Michel...",
                listOfValues: users,
                onChanged: (String query, List<User> filteredList){
                  setState((){
                    usersToShow = filteredList;
                    users.forEach((user){
                      if(_selectedCards.contains(user) && !usersToShow.contains(user))
                        _selectedCards.remove(user);
                    });
                  });
                },
              ),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Text("NOM", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text("Prénom", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: Text("Rôle", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                      ),
                    ],
                  )
              ),
              Expanded(
                child:
                RefreshIndicator(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: usersToShow.length,
                      itemBuilder: listBuilder,
                    ),
                  ),
                  onRefresh: _refreshUsers,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _isLoading ? null : _getFloatingActionButton()
    );
  }

  FloatingActionButton _getFloatingActionButton(){
    if(currentUser.hasRight(Right.UPDATE_USER_ROLE)){
      if(currentUser.hasRight(Right.UPDATE_ROLE_RIGHTS)){
        return _selectedCards.length > 0 ? FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
              builder: (_) => RoleDialog(_selectedCards, onClosed: (Role role){
              usersToShow.forEach((user){
                if(_selectedCards.contains(user))
                  user.role = role;
              });
              usersToShow = _sortUsers(usersToShow);
              if(_selectedCards.contains(currentUser))
                currentUser.role = role;
              setState((){_selectedCards.clear();});
            }),
          ),
          child: Icon(Icons.check),
          backgroundColor: Colors.green,
        ) : FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => RightsDialog(
              onClosed: (Role updatedRole){
                setState(() => currentUser.role.idRole == updatedRole.idRole ? currentUser.role = updatedRole : "");
              },
            ),
          ),
          child: Icon(Icons.settings),
        );
      }else{
        return _selectedCards.length > 0 ? FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => RoleDialog(_selectedCards, onClosed: (Role role){
              usersToShow.forEach((user){
                if(_selectedCards.contains(user))
                  user.role = role;
              });
              usersToShow = _sortUsers(usersToShow);
              if(_selectedCards.contains(currentUser))
                currentUser.role = role;
              setState((){_selectedCards.clear();});
            }),
          ),
          child: Icon(Icons.check),
          backgroundColor: Colors.green,
        ) : null;
      }
    }else if(currentUser.hasRight(Right.UPDATE_ROLE_RIGHTS)){
      return FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => RightsDialog(
            onClosed: (Role updatedRole){
              if(currentUser.role.idRole == updatedRole.idRole)
                currentUser.role = updatedRole;
              setState((){});
            },
          ),
        ),
        child: Icon(Icons.settings),
      );
    }
    return null;
  }


  /// EXTRA FUNCTIONS TO BUILD ACTIVITY

  Widget listBuilder(BuildContext context, int index) {
    User user = usersToShow[index];
    return GestureDetector(
        onTap: (){
          if(_selectedCards.length > 0)
            setState(() {!_selectedCards.contains(user) ? _selectedCards.add(user) : _selectedCards.remove(user);});
        },
        onLongPress: (){
          if(currentUser.hasRight(Right.UPDATE_USER_ROLE))
            setState(() {!_selectedCards.contains(user) ? _selectedCards.add(user) : _selectedCards.remove(user);});
        },
        child: Card(
            elevation: 3,
            margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: index == usersToShow.length-1 ? 10 : 0),
            color: _selectedCards.contains(user) ? Colors.grey[300] : Colors.white,
            child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(user.nom.toUpperCase(), style: textStyle, overflow: TextOverflow.ellipsis,),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(user.prenom, style: textStyle, overflow: TextOverflow.ellipsis,),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(child: Text(user.getRole().abbr, style: user.getRole().abbr == "Admin" ? TextStyle(fontSize: 16, fontStyle: FontStyle.italic) : textStyle)),
                    ),
                  ],
                )
            )
        )
    );
  }

}


/// RIGHTS DIALOG
class RightsDialog extends StatefulWidget {

  final Function onClosed;
  RightsDialog({this.onClosed});

  @override
  _RightsDialogState createState() => new _RightsDialogState();
}
class _RightsDialogState extends State<RightsDialog> {

  List<Role> roles = List<Role>();
  List<Right> rights = List<Right>();

  List<Role> selectedRole = List<Role>();
  bool showRights = false;
  bool updateInProgress = false;

  @override
  void initState() {
    Role.list.values.forEach((role) => roles.add(role));
    Right.values.forEach((right) => rights.add(right));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OriginDialog(
      title: "Modifier les droits d'un rôle",
      content: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Sélectionner un rôle", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          DropdownSelector(
            listOfValues: roles,
            selectedValues: selectedRole,
            selectOnlyOne: true,
            onChanged: (){
              setState(() => showRights = selectedRole.length > 0);
            },
          ),
          SizedBox(height: 15),
          selectedRole.length > 0 ? ListView.builder(
              shrinkWrap: true,
              itemCount: rights.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(OriginConstants.rightsMobileName[rights[index]], style: textStyle,),
                    ),
                    Checkbox(
                      value: selectedRole.last.rights[selectedRole.last.rights.keys.elementAt(index)],
                      onChanged: rights[index] == Right.UPDATE_ROLE_RIGHTS ? null : (value){setState(() => selectedRole.last.rights[selectedRole.last.rights.keys.elementAt(index)] = value);},
                    ),
                  ],
                );
              },
            ) : Container()
        ],
      bottom: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        disabledColor: Color(0xFFC8E6C9),
        elevation: 5.0,
        color: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        child: updateInProgress ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ) : Text("Valider", style: TextStyle(color: Colors.white)),
        onPressed: selectedRole.length > 0 && !updateInProgress ? (){
          setState((){updateInProgress = true;});

          var apiCalls = <Future>[];
          selectedRole.last.rights.forEach((right, hasRight) => apiCalls.add(UserService.updateRoleRight(selectedRole.last, right.toString().replaceFirst("Right.", ""), hasRight)));

          Future.wait(apiCalls).then((List<dynamic> results){
            Navigator.of(context).pop();
            if(widget.onClosed != null)
              widget.onClosed(results.last);
          });

        } : null,
      )
    );
  }

}



/// DIALOG ROLE
class RoleDialog extends StatefulWidget {

  final List<User> selectedUsers;
  final Function onClosed;
  RoleDialog(this.selectedUsers, {this.onClosed}) : assert(selectedUsers != null);

  @override
  _RoleDialogState createState() => new _RoleDialogState();
}
class _RoleDialogState extends State<RoleDialog> {

  int newRole = -1; // not selected yet
  bool updateInProgress = false;

  _buildTiles(int groupValue){
    List<RadioListTile<int>> rolesTiles = List<RadioListTile<int>>();
    Role.list.values.forEach((Role role) => rolesTiles.add(
        RadioListTile<int>(
          key: UniqueKey(),
          title: Text(role.nom),
          value: role.idRole,
          groupValue: groupValue,
          onChanged: (int value) => setState(() => newRole = value)
        )
    ));
    return rolesTiles;
  }

  @override
  Widget build(BuildContext context) {
    return OriginDialog(
      title: "Nouveau rôle",
      content: _buildTiles(newRole),//rolesTiles.isEmpty ? _buildTiles() : rolesTiles,
      bottom: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: updateInProgress ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ) : Text("Confirmer", style: TextStyle(color: Colors.white)),
        elevation: 5.0,
        color: Colors.green,
        disabledColor: Colors.green[100],
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        onPressed: newRole != -1 && !updateInProgress ? (){
          setState((){updateInProgress = true;});

          var apiCalls = <Future>[];
          widget.selectedUsers.forEach((user){
            apiCalls.add(UserService.updateUserRole(user, Role.getById(newRole)));
          });

          Future.wait(apiCalls).then((List<dynamic> results){
            if(widget.onClosed != null)
              widget.onClosed(Role.getById(newRole));
            Navigator.of(context, rootNavigator: true).pop(true);
          });

        } : null,
      ),
    );
  }

}