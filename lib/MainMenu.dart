import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_id/device_id.dart';
import 'package:poker/CFriends.dart';
import 'package:poker/GamePage.dart';
import 'package:poker/Requests.dart';
import 'package:poker/RouteGame.dart';
import 'package:poker/SignIn.dart';
import 'package:poker/Vote.dart';
import 'package:poker/WaitArea.dart';
import 'package:recase/recase.dart';

class MyRouter extends StatefulWidget {
  MyRouter({Key key}) : super(key: key);
  @override
  _MyRouter createState() => new _MyRouter();
}

class _MyRouter extends State<MyRouter> {
  var _name;
  var _chip ;
  var _won;
  var _played;
  int index = 0;
  
  
  void make(var data){
    _name = data["Name"];
    _chip = data["Chips"];
    _played = data["Data"]["Played"];
    _won = data["Data"]["Won"];
  }
  Future<void> Datac() async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).once().then((snap) {
        if(snap.value["Status"] == "idle"){
          make(snap.value);
        }
        else {
          FirebaseDatabase.instance.reference().child("Game").child(snap.value["Status"].toString()).once().then((mydata) {
            if (mydata.value["Status"] == "Wait Users"){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyWaitA()),
              );
            }
            else if (mydata.value["Status"] == "Playing" && mydata.value["Status"] == "Voting"){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyVotePage()),
              );
            }
            else if (mydata.value["Status"] == "Playing"){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyGamePage()),
              );
            }
            else {
              FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).update({"Status" : "idle"}).then((syz) {
                make(snap.value);
                setState(() {

                });
              });
            }
          });
        }
        setState(() {});
      }).catchError((err) {
        Datac();
      });
    }).catchError((err) {
      Datac();
    });
    /*CloudFunctions.instance.getHttpsCallable(functionName: "returnData").call(<String, dynamic>{
      'id' : id,
    }).then((result) {
      print(result.data);
      if (result.data["Status"] == "Successfull"){
        setState(() {
          _name = result.data["name"];
          _won = result.data["won"];
          _played = result.data["played"];
          _chip = result.data["chips"];
        });
      }
      else if (result.data["Status"] == "Game"){
        if(result.data["GameStatus"] == "Voting"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyVotePage()),
          );
        }
        else if(result.data["GameStatus"] == "Playing"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyGamePage()),
          );
        }
        else if(result.data["GameStatus"] == "Wait Users"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWaitA()),
          );
        }
        else{
          Datac();
        }
      }
      else{
        Datac();
      }
    });*/
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    Datac();
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
            new Text(
              "Hello,\n" + ReCase(_name.toString()).titleCase,
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),
            Padding(padding: EdgeInsets.only(top: 70.0)),

            new Text(
              "Chips : " + _chip.toString(),
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),

            new Text(
              "You Played " + _played.toString() + " match(s)",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),

            new Text(
              "You Won "+ _won.toString() +" match(s)",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            )
          ]

      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home), disabledColor: Colors.green, onPressed: null,),
            IconButton(icon: Icon(Icons.people), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyCurrentF()),
              );
            },),
            IconButton(icon: Icon(Icons.play_arrow), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRouteGame()),
              );
            },),
            IconButton(icon: Icon(Icons.public), onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyReqPage()),
              );
            },),
            IconButton(icon: Icon(Icons.exit_to_app), onPressed: () async {
              FirebaseDatabase.instance.reference().child("Id").update({await DeviceId.getID :  null}).then((val) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MySignIn()),
                );
              });
            },),
          ],
        ),
      ),

    );
  }
}