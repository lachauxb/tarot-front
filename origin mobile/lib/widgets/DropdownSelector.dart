import 'package:flutter/cupertino.dart';
import 'package:origin/config/auto_loader.dart';

/// Permet un rendu uniforme et rapide d'un sélecteur en mode dropdown sur mobile
// ignore: must_be_immutable
class DropdownSelector<T> extends StatefulWidget {

  final List<T> listOfValues; // liste de tous les éléments disponibles dans le dropdown
  List<T> selectedValues; // liste des éléments sélectionnés
  final Function onChanged; // fonction appelé lors du click sur un élément du dropdown
  final bool selectOnlyOne; // true -> un seul élément sélectionné à la fois / false -> le contraire

  DropdownSelector({
    @required this.listOfValues,
    this.selectedValues, // si on veut avoir la vue sur les éléments sélectionnés, il ne faut pas oublier ce paramètre et lui fournir une liste
    this.onChanged,
    this.selectOnlyOne = false,
  }) : assert(listOfValues != null);

  @override
  State<StatefulWidget> createState() => _DropdownSelectorState<T>();
}

class _DropdownSelectorState<T> extends State<DropdownSelector<T>>{

  String displayedText = "Aucun élément sélectionné"; // texte qui apparaît lorsque le dropdown est clos

  @override
  initState() {
    if(widget.selectedValues == null || (widget.selectOnlyOne && widget.selectedValues.length > 1))
      widget.selectedValues = List<T>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                border: Border.all(color: solutecGrey)
            ),
            child: DropdownButton<T>(
              isExpanded: true,
              value: widget.selectedValues.isNotEmpty ? widget.selectedValues.last : null,
              hint: Text("Aucun élément sélectionné"),

              onChanged: (T selectedElement) {
                setState(() {
                  if(widget.selectedValues.contains(selectedElement))
                    widget.selectedValues.remove(selectedElement);
                  else{
                    if(widget.selectOnlyOne)
                      widget.selectedValues.clear();
                    widget.selectedValues.add(selectedElement);
                  }
                  if(widget.onChanged != null) // if setState has been called, we "notify" observer by calling onChange function if there is one provided
                    widget.onChanged();
                });
              },
              items: widget.listOfValues.map<DropdownMenuItem<T>>((T element) { // construction des items (1/élément) au sein du dropdown
                return DropdownMenuItem<T>(
                    value: element,
                    child: Builder(builder: (BuildContext context) {
                      if(context.findAncestorStateOfType<_DropdownSelectorState>() == null) { // Si le selecteur est ouvert (en mode dropdown) alors ...
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            widget.selectedValues.contains(element) ? Icon(Icons.check, color: solutecRed,) : Icon(Icons.check, color: Colors.transparent,),
                            SizedBox(width: 15),
                            Flexible(child: Text(element.toString(), style: TextStyle(color: solutecGrey))),
                          ],
                        );
                      }else{
                        int total = widget.selectedValues.length;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(child: Text(element.toString() + (total > 1 ? " et ${total - 1} autre${total > 2 ? 's' : ''}" : ""))),
                          ],
                        );
                      }
                    },)
                );
              }).toList(),
              icon: Icon(Icons.keyboard_arrow_down),
              iconSize: 26,
              style: TextStyle(color: solutecGrey),
              underline: Container(),
            )
        ),
        !widget.selectOnlyOne && widget.listOfValues.length > 0 ? GestureDetector(
          onTap: (){
            if(widget.selectedValues.length == widget.listOfValues.length){ // unselect all
              setState((){widget.selectedValues.clear();});
            }else{ // select all
              setState((){
                widget.listOfValues.forEach((value){
                  if(!widget.selectedValues.contains(value))
                    widget.selectedValues.add(value);
                });
              });
            }
            if(widget.onChanged != null) // if setState has been called, we "notify" observer by calling onChange function if there is one provided
              widget.onChanged();
          },
          child: Text(widget.selectedValues.length == widget.listOfValues.length ? "Tout désélectionner" : "Tout sélectionner", style: TextStyle(fontSize: 14, color: Colors.grey[600], decoration: TextDecoration.underline))
        ) : Container()
      ],
    );
  }

}