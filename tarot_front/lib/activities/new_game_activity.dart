import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:tarot_front/models/user.dart';
import 'package:tarot_front/services/user_service.dart';


/// Créer une nouvelle partie
class NewGameActivity extends StatefulWidget {
  const NewGameActivity({Key? key}) : super(key: key);

  @override
  _NewGameActivityState createState() => _NewGameActivityState();
}


class _NewGameActivityState extends State<NewGameActivity> {

  static const List<String> _kOptions = <String>[
    'aymeric',
    'bastien',
    'clément',
    'romain',
    'quentin'
  ];

  List<String> players = ["", "", "", "", ""];

  @override
  void initState() {
    super.initState();
  }

  void loadData() async {
    List<User> users = await UserService.getAllUsers();
    // _kOptions = users.map((element) => element.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarot"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: getInputPlayers()
            )
          )
        )
      )
    );
  }

  List<Widget> getInputPlayers(){
    List<Widget> res = [];
    for(int i = 0; i < 5 ; i++){
      res.add(
        SizedBox(
          height: 100,
          width: 350,
          child: SimpleAutoCompleteTextField(
            suggestions: _kOptions,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_rounded, color: Colors.black,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              filled: true,
              fillColor: Colors.black12,
              hintText: "Joueur ${i+1}"
            ),
            key: null,
            textSubmitted: (value) => {
              players[i] = value
            },
          )
        )
      );
    }
    res.add(
      Container(
        decoration: const BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: SizedBox(
          width: 100,
          height: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => {
                  if(isFullPlayers()){

                  }
                },
                child: const Text('Valider', style: TextStyle(color: Colors.black))
              )
            ]
          )
        )
      )
    );
    return res;
  }

  /// Retourne vrai si les 5 joueurs sont renseignés
  bool isFullPlayers(){

    return true;
  }

}