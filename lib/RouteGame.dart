import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker/GameSelect.dart';
import 'package:poker/MainMenu.dart';
import 'package:poker/Room-Join.dart';



class MyRouteGame extends StatefulWidget {
  MyRouteGame({Key key}) : super(key: key);
  @override
  _MyRouteGameState createState() => new _MyRouteGameState();
}

class _MyRouteGameState extends State<MyRouteGame> {
  @override
  void initState(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(key:null, onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyGameBuild()),
              );
            },
                child:
                new Text(
                  "Make Room",
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize:30.0,
                      fontWeight: FontWeight.w200,
                      fontFamily: "Roboto"),
                )
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),

            new RaisedButton(key:null, onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRoomIn()),
              );
            },
                child:
                new Text(
                  "Join Room",
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize:30.0,
                      fontWeight: FontWeight.w200,
                      fontFamily: "Roboto"),
                )
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),

            new RaisedButton(onPressed:(){
              
            },
                child:
                new Text(
                  "Play with Random People",
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize:30.0,

                      fontWeight: FontWeight.w200,
                      fontFamily: "Roboto"),
                )
            ),

          ]

      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRouter()),
              );
            },),
          ],
        ),
      ),

    );
  }
  void buttonPressed(){}

}