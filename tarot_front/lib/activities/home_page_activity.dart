import 'package:flutter/material.dart';
import 'package:tarot_front/configurations/constants.dart';

///
class HomePageActivity extends StatefulWidget {
  const HomePageActivity({Key? key}) : super(key: key);

  @override
  _HomePageActivityState createState() => _HomePageActivityState();
}


class _HomePageActivityState extends State<HomePageActivity> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarot"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, top: 20),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.black),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed(newGamePage),
                            child: const Text('Créer une partie', style: TextStyle(color: Colors.black),),
                          )
                        ],
                      )
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, color: Colors.black),
                          TextButton(
                            onPressed: () => {},
                            child: const Text('Rejoindre une partie', style: TextStyle(color: Colors.black),)
                          )
                        ]
                      )
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bar_chart, color: Colors.black),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed(statisticsPage),
                            child: const Text('Statistiques', style: TextStyle(color: Colors.black))
                          )
                        ]
                      )
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.settings, color: Colors.black),
                          TextButton(
                            onPressed: () => {},
                            child: const Text('Paramètres', style: TextStyle(color: Colors.black))
                          )
                        ]
                      )
                    )
                  )
                )
              ],
            ),
          )
        )
      )
    );
  }

}