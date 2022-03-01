import 'dart:async';

import 'package:diacritic/diacritic.dart';
import 'package:origin/config/auto_loader.dart';

/// Permet un rendu uniforme et rapide d'une barre de recherche sur mobile (effectue la recherche)
/// Ne pas oublier que l'objet subissant la recherche doit posséder une méthode toString() pour pouvoir être filtré par la recherche
class SearchBar<T> extends StatefulWidget {

  final List<T> listOfValues; // liste de tous les éléments disponibles dans le dropdown
  final Function onChanged; // fonction appelée lors du déclenchement d'une nouvelle recherche
  final String label; // s'affiche au dessus de la barre
  final String hint; // s'affiche au sein de la barre
  final String initialSearch; // permet d'indiquer une saisie au premier affichage du composant

  SearchBar({
    @required this.listOfValues,
    @required this.onChanged, // sera notifié avec le résultat de la recherche
    this.label,
    this.hint,
    this.initialSearch
  }) : assert(listOfValues != null);

  @override
  State<StatefulWidget> createState() => _SearchBarState<T>();
}

class _SearchBarState<T> extends State<SearchBar<T>> implements StateListener{

  bool _searchInProgress = false;
  String _lastQuery = "";
  TextEditingController controller = TextEditingController();

  // init
  @override
  initState() {
    StateProvider().subscribe(this);
    controller.text = widget.initialSearch != null ? widget.initialSearch : "";
    super.initState();
  }

  @override
  void dispose() {
    StateProvider().dispose(this);
    if(timer != null && timer.isActive)
      timer.cancel();
    super.dispose();
  }

  @override
  void onStateChanged(ObserverState state) {
    if(state == ObserverState.LIST_REFRESHED && _lastQuery != "")
      _onQueryUpdate(_lastQuery);
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: TextField(
            onChanged: _onQueryUpdate,
            controller: controller,
            decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                prefixIcon: Icon(Icons.search),
                suffix: _searchInProgress ? Container(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(solutecRed)
                    )
                ) : null,
                border: OutlineInputBorder(),
                isDense: true
            )
        )
    );
  }

  // Fonction de filtrage
  Timer timer;
  Duration timerDuration = Duration(milliseconds: 1200);
  void _onQueryUpdate(String query){
    _lastQuery = query;

    // show spinner in searchBar
    if(!_searchInProgress)
      setState((){_searchInProgress = true;});

    // manage timer to cancel an old process not done yet
    if(timer != null && timer.isActive)
      timer.cancel();

    // filter list
    List<T> filteredList = List<T>();
    timer = Timer(timerDuration, (){
      List<String> _words = query.split(" "); // split on white spaces
      widget.listOfValues.forEach((T value){
        if(value.toString != null){

          int _foundWords = 0;
          _words.forEach((String word){ // counting how many words are found (ex: 'léa collin' OR 'collin lea' should return the value item "Léa collin")
            if(removeDiacritics(value.toString().toLowerCase()).contains(removeDiacritics(word.toLowerCase())))
              _foundWords++;
          });

          if(_foundWords == _words.length) // if we found all words
            filteredList.add(value);
        }
      });

      // call onChanged function if it exists with filtered list
      if(widget.onChanged != null)
        widget.onChanged(query, filteredList);

      setState((){_searchInProgress = false;});
    });
  }

}