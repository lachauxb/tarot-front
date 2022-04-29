import 'package:flutter/material.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarot"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return _kOptions;
                }
                return _kOptions.where((String option) {
                  return option.contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: null,
            ),
          ]
        ),
      )
    );
  }


}