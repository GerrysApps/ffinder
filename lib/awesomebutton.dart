import 'package:flutter/material.dart';

void mainTest() {
  runApp(const MaterialApp(
    home: AwesomeButton()
  ));
}

// https://kodestat.gitbook.io/flutter/flutter-buttons-and-stateful-widgets
class AwesomeButton extends StatefulWidget {
  const AwesomeButton({super.key});

  @override
  AwesomeButtonState createState() => AwesomeButtonState();
}

class AwesomeButtonState extends State<AwesomeButton> {

  int counter = 0;
  List<String> poopers = ["Flutter", "Is", "Awesome"];
  String wtf = "wtf";

  void onPressed(){
    setState(() {
      wtf = poopers[counter];
      counter = counter < 2 ? counter+1 : 0;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Stateful Widget!"), 
                     backgroundColor: Colors.deepOrange),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(wtf, style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
              const Padding(padding: EdgeInsets.all(15.0)),

/*
              Button(
                child: Text("Press me!", style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 20.0)),
                color: Colors.red,
                onPressed: onPressed
              )
*/
            ]
          )
        )
      )
    );
  }
}
