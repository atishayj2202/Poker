import 'dart:async';

import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker/MainMenu.dart';
import 'package:recase/recase.dart';
import 'GamePage.dart';
import 'Vote.dart';

class MyWaitA extends StatefulWidget {
  MyWaitA({Key key}) : super(key: key);
  @override
  _MyWaitAState createState() => new _MyWaitAState();
}

class _MyWaitAState extends State<MyWaitA> {
  var gid = null;
  var ChangerX = null;
  var ChangerY = null;
  var ChangerZ = null;

  var uid = "";
  var mid = null;
  var disable = true;



  Future<void> makeData() async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      uid = data.value["Uid"];
      FirebaseDatabase.instance.reference().child("Users").child(uid).once().then((snap) {
        if(snap.value["Status"] != "idle"){
          gid = snap.value["Status"];
          setState(() {});
          ChangerX = FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).onChildAdded.listen((Data) {
            setData();
          });
          ChangerY = FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).onChildChanged.listen((Data) {
            setData();
          });
          ChangerZ = FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).onChildRemoved.listen((Data) {
            setData();
          });
        }
        else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyRouter()),
          );
        }
      });
    });
  }

  
  Future<void> setData () {
    //print("Changed");
    FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).once().then((snap) {
      var tempD = snap.value;
      if(tempD["Status"] == "Wait Users"){
        var temp = 0;
        var path = "";
        disable = false;
        Namesf = [];
        while(temp < tempD["MaxP"]){
          temp = temp + 1;
          path = "User" + temp.toString();
          @JsonKey(required: null)
          var xyz = tempD[path];
          if(xyz != null){
            if(uid == xyz["id"]){
              mid = path;
              path = ReCase(path).titleCase + " : " + xyz["name"] + " (Me)";
            }
            else{
              path = ReCase(path).titleCase + " : " + xyz["name"];
            }
          }
          else {
            path = "";
          }
          Namesf.add(path);
        }
        setState(() {});
        print(mid.toString() +'\n' + uid.toString() + '\n'+ gid.toString());
      }
      else if(tempD["Status"] == "END"){
        ChangerX?.cancel();
        ChangerY?.cancel();
        ChangerZ?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRouter()),
        );
      }
      else if (tempD["Status"] == "Playing" && tempD["Round"] == "Voting"){
        ChangerX?.cancel();
        ChangerY?.cancel();
        ChangerZ?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyVotePage()),
        );
      }
      else if (tempD["Status"] == "Playing" && tempD["Round"] != "Voting"){
        ChangerX?.cancel();
        ChangerY?.cancel();
        ChangerZ?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyGamePage()),
        );
      }
      else {
        ChangerX?.cancel();
        ChangerY?.cancel();
        ChangerZ?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRouter()),
        );
      }
    }).catchError((err) {
      print(err.message);
    });
  }
  @override
  void initState(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    makeData();
    super.initState();
  }

  @override
  void dispose(){
    ChangerX?.cancel();
    ChangerY?.cancel();
    ChangerZ?.cancel();
    super.dispose();
  }

  List<dynamic> Namesf = [];
  List<dynamic> lead = [Icons.filter_1, Icons.filter_2, Icons.filter_3, Icons.filter_4, Icons.filter_5, Icons.filter_6, Icons.filter_7, Icons.filter_8];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Waiting For Players'),
        automaticallyImplyLeading: false,
      ),
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text(
              "Room Id : " + gid.toString(),
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Roboto"),
            ),
            new Expanded(
                child: new ListView.builder(
                  itemCount: Namesf.length,
                  itemBuilder: (BuildContext context, index) {
                    return ListTile(
                      leading: Icon(lead[index]),
                      title: Text(ReCase(Namesf[index].toString()).titleCase),
                    );
                  },
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
            new RaisedButton(key:null, onPressed: disable ? null : () {
              print(mid);
              FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).child(mid).set(null).then((abc) {
                FirebaseDatabase.instance.reference().child("Users").child(uid.toString()).update({"Status" : "idle"}).then((abd) {
                  ChangerX?.cancel();
                  ChangerY?.cancel();
                  ChangerZ?.cancel();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyRouter()),
                  );
                }).catchError((err) {
                  print(err.message);
                });
              }).catchError((err) {
                print(err.message);
              });
            },
              child:
              new Text(
                "Leave Room",
                style: new TextStyle(
                    color: const Color(0xFFffffff),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto"),
              ),
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
            )
          ],
        ),
      ),

    );
  }
}