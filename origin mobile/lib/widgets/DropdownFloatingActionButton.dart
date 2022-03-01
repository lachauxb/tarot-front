import 'package:flutter/material.dart';
import 'package:origin/config/auto_loader.dart';
import 'dart:math' as math;

class DropdownFloatingActionButton extends StatefulWidget {
  final String tooltip;
  final Icon icon;
  final List<FloatingActionButton> horizontalButtons;
  final List<FloatingActionButton> verticalButtons;
  DropdownFloatingActionButton({this.tooltip, this.icon, this.horizontalButtons, this.verticalButtons});

  @override
  _DropdownFloatingActionButtonState createState() => _DropdownFloatingActionButtonState();
}

class _DropdownFloatingActionButtonState extends State<DropdownFloatingActionButton> with SingleTickerProviderStateMixin {

  bool isOpened = false;
  bool isActive = false;

  List<Widget> horizontalButtons = List<Widget>();
  List<Widget> verticalButtons = List<Widget>();

  AnimationController _controller;
  Animation<double> _iconAnimation; // gère les transition de l'icône de menu
  Animation<Color> _colorAnimation; // gère la transition de couleur
  Animation<double> _translateHorizontalButtonAnimation; // gère l'apparition / disparition des icônes au sein du menu [horizontal]
  Animation<double> _translateVerticalButtonAnimation; // gère l'apparition / disparition des icônes au sein du menu [vertical]
  Animation<double> _opacityButtonAnimation; // gère l'opacité des icônes au sein du menu

  @override
  initState() {
    _controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _colorAnimation = ColorTween(begin: solutecRed, end: solutecGrey).animate(_controller);
    _translateHorizontalButtonAnimation = Tween<double>(begin: 56, end: -14).animate(_controller);
    _translateVerticalButtonAnimation = Tween<double>(begin: 33, end: -14).animate(_controller);
    _opacityButtonAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _iconAnimation = Tween<double>(begin: 1, end: 50).animate(_controller)..addListener((){ // inutile de setState sur chaque animation, elles se déroulent en même temps
      setState((){});
    })..addStatusListener((state){
      if(state == AnimationStatus.completed)
        isOpened = true;

      else if(state == AnimationStatus.dismissed) {
        isOpened = false;
        isActive = false;
      }
    });

    fillButtonLists();

    super.initState();
  }

  void fillButtonLists(){
    horizontalButtons.clear();
    verticalButtons.clear();
    if(widget.horizontalButtons != null) {
      horizontalButtons.add(Opacity(opacity: 0, child: FloatingActionButton(heroTag: "dumpBtn", onPressed: null)));
      for (int i = 0; i < widget.horizontalButtons.length; i++) {
        horizontalButtons.add(Transform(transform: Matrix4.translationValues(_translateHorizontalButtonAnimation.value+i, 0, 0),
            child: Opacity(
                opacity: _opacityButtonAnimation.value,
                child: widget.horizontalButtons.elementAt(i)
            )
        ));
      }
    }
    if(widget.verticalButtons != null)
      for(int y = 0; y < widget.verticalButtons.length; y++){
        verticalButtons.add(Transform(transform: Matrix4.translationValues(0, _translateVerticalButtonAnimation.value+y, 0),
            child: Opacity(
                opacity: _opacityButtonAnimation.value,
                child: widget.verticalButtons.elementAt(y)
            )
        ));
      }
    verticalButtons.add(FloatingActionButton(
        heroTag: "mainDropdownFloatingActionButton",
        backgroundColor: _colorAnimation.value,
        onPressed:   isOpened ?
            () => _controller.reverse() :
            () {
          setState(() {isActive = true;});
          _controller.forward();
          },
        tooltip: widget.tooltip,
        child: Transform.rotate(
            angle: - math.pi / (_iconAnimation.value/25),
            child: _iconAnimation.value <= 25 ? widget.icon : Icon(Icons.close)
        )
    ));
  }



  @override
  Widget build(BuildContext context) {
    fillButtonLists();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
            children: isActive ? horizontalButtons : [],
        ),
        Column(mainAxisAlignment: MainAxisAlignment.end,
          children: isActive ? verticalButtons : [verticalButtons.last]
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}




