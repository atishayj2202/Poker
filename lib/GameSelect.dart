import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:poker/Invite_Game.dart';
import 'package:poker/RouteGame.dart';
import 'package:poker/WaitArea.dart';
import 'package:firebase_core/firebase_core.dart';

class MyGameBuild extends StatefulWidget {
  MyGameBuild({Key key}) : super(key: key);
  @override
  _MyGameBuildState createState() => new _MyGameBuildState();
}

class _MyGameBuildState extends State<MyGameBuild> {
  @override
  void initState(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }
  var errtext = "";
  var disable = false;
  double slidevalue = 0.5;
  bool random = true;
  bool friends = false;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(errtext.toString()),
            new Text(
              "Build Your\nOwn Room",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize:50.0,
                  fontWeight: FontWeight.w900,
                  fontFamily: "Roboto"),
            ),
            Padding(padding: EdgeInsets.only(top: 70.0)),
            new Text(
              "No. of Players",
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize:15.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto"),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) => Text((index+4).toString())),
              ),
            ),
            new Slider(
              value: slidevalue,
              divisions: 4,
              onChanged: disable ? null : (value){
                setState(() {
                  slidevalue = value;
                });
              },
            ),

            new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Checkbox(
                      key:null,
                      onChanged: disable ? null : (val){
                        setState(() {
                          random = val;
                        });
                      },
                      value: random),
                  new Text(
                    "Allow Random People",
                    style: new TextStyle(fontSize:15.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto"),
                  )
                ]

            ),
            new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Checkbox(
                      key:null,
                      onChanged: disable ? null : (val) {
                        setState(() {
                          friends = val;
                        });
                      },
                      value: friends,
                  ),

                  new Text(
                    "Invite Friends",
                    style: new TextStyle(fontSize:15.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto"),
                  )
                ]

            )
          ]

      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRouteGame()),
              );
            },),
            IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () async {
              var disable = true;
              setState(() { });
              var x = slidevalue;
              if (slidevalue == 0){
                x =4;
              }
              else if(slidevalue == 0.25){
                x = 5;
              }
              else if(slidevalue == 0.5){
                x = 6;
              }
              else if(slidevalue == 0.75){
                x = 7;
              }
              else if(slidevalue == 1){
                x = 8;
              }
              else{
                x = 6;
              }
              FirebaseDatabase.instance.reference().child("Id").child(await DeviceId.getID).once().then((abc) {
                var uid = abc.value["Uid"];
                FirebaseDatabase.instance.reference().child("Users").child(uid).once().then((abd) {
                  var name = abd.value["Name"];
                  FirebaseDatabase.instance.reference().child("Game").child("Index").once().then((data) {
                    var temp = int.parse(data.value.toString());
                    temp = temp + 1;
                    print(temp);
                    FirebaseDatabase.instance.reference().child("Game").update({"Index" : temp, temp.toString() : {"MaxP" : x, "Status" : "Wait Users", "User1" : {"id" : uid, "name" : name}}}).then((abc) {
                      FirebaseDatabase.instance.reference().child("Users").child(uid).update({"Status" : temp}).then((abc) {
                        if(random){
                          FirebaseDatabase.instance.reference().child("Game").child("RandomG").push().set(temp);
                        }
                        if(friends){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyInvite()),
                          );
                        }
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyWaitA()),
                          );
                        }
                      });
                    });
                  });
                });
              });
            },),
          ],
        ),
      ),

    );
  }

}