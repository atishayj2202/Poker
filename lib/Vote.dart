import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker/GamePage.dart';
import 'package:poker/MainMenu.dart';
import 'package:poker/WaitArea.dart';
import 'package:recase/recase.dart';

class MyVotePage extends StatefulWidget {
  MyVotePage({Key key}) : super(key: key);
  @override
  _MyVotePageState createState() => new _MyVotePageState();
}

class _MyVotePageState extends State<MyVotePage> {
  var gid = null;
  var Changer = null;
  Future<void> setData () async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).once().then((snap) {
        if(snap.value["Status"] == "idle"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyRouter()),
          );
        }
        else {
          gid = snap.value["Status"];
          FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).once().then((snapshot){
            if(snapshot.value["Status"] == "Playing"){
              if(snapshot.value["Round"] == "Voting"){
                Winners = snapshot.value["Winner"].toString();
                setState(() {

                });
                print(Winners);
                Changer = FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).onChildChanged.listen((Datax) {
                  FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).once().then((Data) {
                    if(Data.value["Round"] == "END"){
                      Changer.cancel();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyRouter()),
                      );
                    }
                    else if(Data.value["Round"] != "Voting"){
                      Changer.cancel();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyGamePage()),
                      );
                    }
                  }).catchError((err){
                    print(err.message);
                  });
                });
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyGamePage()),
                );
              }
            }
            else{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRouter()),
              );
            }
          });
        }
      });
    });
    /*CloudFunctions.instance.getHttpsCallable(functionName: "returnData").call(<String, dynamic>{
      'id' : id,
    }).then((result){
      print(result.data);
      if("Game" == result.data["Status"] && result.data["GameStatus"] == "Voting"){
        gid = result.data["GameId"];
        Winners = result.data["Winner"][0];
        setState(() {});
        Changer = FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).onChildChanged.listen((Datax) {
          FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).once().then((Data) {
            if(Data.value["Round"] == "END"){
            Changer.cancel();
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyRouter()),
            );
            }
            else if(Data.value["Round"] != "Voting"){
              Changer.cancel();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyGamePage()),
              );
            }
          }).catchError((err){
            print(err.message);
          });
        });
      }
      else if("Game" == result.data["Status"] && result.data["GameStatus"] == "Playing"){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyGamePage()),
        );
      }
      else if("Game" == result.data["Status"] && result.data["GameStatus"] == "Wait Users"){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyWaitA()),
        );
      }
      else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRouter()),
        );
      }
    }).catchError((err) {
      print(err.message);
    });*/
  }

  @override
  void initState(){
    setData();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  void dispose(){
    Changer.cancel();
    super.dispose();
  }

  var Winners = "";
  var disable = false;
  var head = "Do You Want To Play Another Match?";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:
      new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            head,
            style: new TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                fontFamily: "Roboto"
            ),
          ),
          Text(
            "Winner : " +  ReCase(Winners.toString().replaceFirst("[", "").replaceFirst("]", "")).titleCase,
            style: new TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto"
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("No"),
                onPressed: disable? null : (){
                  disable = true;
                  setState(() {});
                  FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).set({"Status" : "END", "Round" : "END"}).then((abc) {
                    head = "Rejected Request";
                    setState(() {});
                  });
                },
                color: Colors.red,
              ),
              RaisedButton(
                child: Text("Yes"),
                onPressed: disable? null : (){
                  disable = true;
                  setState(() {});
                  CloudFunctions.instance.getHttpsCallable(functionName: "voteGame").call(<String, dynamic>{
                    'gid' : gid,
                  }).then((result){
                    head = "Waiting For Other Users";
                    setState(() {});
                  }).catchError((err) {
                    print(err.message);
                  });
                },
                color: Colors.green,
              ),

            ],
          )
        ],
      ),

    );
  }
}