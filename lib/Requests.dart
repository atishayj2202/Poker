import 'dart:convert';

import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker/CFriends.dart';
import 'package:poker/WaitArea.dart';
import 'package:recase/recase.dart';
import 'GamePage.dart';
import 'MainMenu.dart';
import 'RouteGame.dart';
import 'SignIn.dart';
import 'Vote.dart';

class MyReqPage extends StatefulWidget {
  MyReqPage({Key key}) : super(key: key);
  @override
  _MyReqPageState createState() => new _MyReqPageState();
}

class _MyReqPageState extends State<MyReqPage> {
  var errtextG = "Fetching Data";
  var errtextF = "Fetching Data";
  List<dynamic> titlesF = [];
  List<dynamic> idsF = [];
  List<dynamic> titlesG = [];
  List<dynamic> idsG = [];
  var mid = "";



  var info = [];
  var mData;
  void returnbw(jsonString){
    var encode = jsonEncode(jsonString);
    var decoded = json.decode(encode);
    info = [];
    for (var colour in decoded.keys) {
      info.add(colour);
    }
  }

  void delG(aid){
    FirebaseDatabase.instance.reference().child("Users").child(mid).child("Request").child("Game").child(aid).set(null).then((abc) {
      makeData();
    });
  }

  void delF(aid){
    FirebaseDatabase.instance.reference().child("Users").child(mid).child("Request").child("Friend").child(aid).set(null).then((abc) {
      makeData();
    });

  }

  Future<void> makeData() async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      mid = data.value["Uid"];
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).once().then((snap) {
        mData= snap.value;
        idsF =[];
        idsG = [];
        titlesF = [];
        titlesG = [];
        @JsonKey(required: null)
        var temp = snap.value["Request"]["Friend"];
        if(temp != null){
          errtextF = "";
          returnbw(snap.value["Request"]["Friend"]);
          var i = 0;
          while(i < info.length){
            titlesF.add(snap.value["Request"]["Friend"][info[i]]["name"]);
            idsF.add(info[i]);
            i = i + 1;
          }
        }
        else{
          errtextF = "No result found";
        }
        @JsonKey(required: null)
        var tempg = snap.value["Request"]["Game"];
        if(tempg != null){
          errtextG = "";
          returnbw(snap.value["Request"]["Game"]);
          var i = 0;
          while(i < info.length){
            titlesG.add(snap.value["Request"]["Game"][info[i]]["Name"]);
            idsG.add(info[i]);
            i = i + 1;
          }
        }
        else{
          errtextG = "No result found";
        }
        setState(() {

        });
      }).catchError((err) {
        errtextG = "No result found";
        errtextF = "No result found";
        setState(() {

        });
      });
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('Requests'),
          automaticallyImplyLeading: false,
          bottom: new TabBar(tabs: <Tab>[
            new Tab(child: new Text("Room Join Requests"),),
            new Tab(child: new Text("Friend Request"), ),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text("Game Request",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto"),
                  ),
                  new Text(errtextG),
                  new Expanded(
                      child: new ListView.builder(
                        itemCount: titlesG.length,
                        itemBuilder: (BuildContext context, index) {
                          return ListTile(
                            title: Text(ReCase(titlesG[index].toString()).titleCase),
                            subtitle: Text("wants you to join his room."),
                            trailing: new Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(icon: Icon(Icons.block), onPressed: () async {
                                  delG(idsG[index]);
                                },),
                                IconButton(icon: Icon(Icons.check_circle), onPressed: () async {
                                  var gid = mData["Request"]["Game"][idsG[index]]["rid"];
                                  FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).once().then((data) {
                                    if(data.value["Status"] == "Wait Users"){
                                      var max = int.parse(data.value["MaxP"].toString());
                                      var temp = 0;
                                      var space = false;
                                      var path = "";
                                      var tempD = data.value;
                                      while(temp < max){
                                        temp = temp + 1;
                                        path = "User" + temp.toString();
                                        @JsonKey(required: null)
                                        var check = data.value[path];
                                        if(null == check){
                                          space = true;
                                          break;
                                        }
                                      }
                                      if(space){
                                        FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).child(path).set({"id" : mData["Uid"], "name" : mData["Name"]}).then((abc) {
                                          FirebaseDatabase.instance.reference().child("Users").child(mData["Uid"].toString()).update({"Status" : gid}).then((abd) {
                                            delG(idsG[index]);
                                            tempD[path] = {"id" : mData["Uid"], "name" : mData["Name"]};

                                            temp = 0;
                                            space = true;
                                            path = "";
                                            while(temp < max){
                                              temp = temp + 1;
                                              path = "User" + temp.toString();
                                              @JsonKey(required: null)
                                              var check = tempD[path];
                                              if(null == check){
                                                space = false;
                                                break;
                                              }
                                            }
                                            if(space){
                                              CloudFunctions.instance.getHttpsCallable(functionName: "Maintenence").call(<String, dynamic>{
                                                "gid" : gid,
                                                "max" : max,
                                              }).then((result) {
                                                print(result.data.toString());
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => MyWaitA()),
                                                );
                                              });
                                            }
                                            else{
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => MyWaitA()),
                                              );
                                            }
                                          });
                                        });
                                      }
                                      else{
                                        errtextG = "No Space left";
                                        setState(() {});
                                        delG(idsG[index]);
                                      }
                                    }
                                    else{
                                      errtextG = "This Room Is Already Started";
                                      setState(() {});
                                      delG(idsG[index]);
                                    }

                                  });
                                },),
                              ],
                            ),
                          );
                        },
                      )
                  ),
                ]
            ),
            new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text("Friend Request",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto"),
                  ),
                  new Text(errtextF),
                  new Expanded(
                      child: new ListView.builder(
                        itemCount: titlesF.length,
                        itemBuilder: (BuildContext context, index) {
                          return ListTile(
                            title: Text(ReCase(titlesF[index].toString()).titleCase),
                            subtitle: Text("sent you friend request."),
                            trailing: new Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(icon: Icon(Icons.block), onPressed: () async {
                                  delF(idsF[index]);
                                },),
                                IconButton(icon: Icon(Icons.check_circle), onPressed: () async {
                                  var i = 0;
                                  var Duid = mData["Request"]["Friend"][idsF[index]]["uid"];
                                  @JsonKey(required: null)
                                  var tempf =  mData["Friends"];
                                  if(tempf != null){
                                    returnbw(tempf);
                                    while (i < info.length){
                                      if(mData["Friends"][info[i]]["id"] == Duid){
                                        errtextF = "You are already friends";
                                        delF(idsF[index]);
                                        setState(() {});
                                        return;
                                      }
                                      i = i + 1;
                                    }
                                  }
                                  FirebaseDatabase.instance.reference().child("Users").child(Duid).child("Friends").push().set({"Name" : mData["Name"], "id" : mData["Uid"]}).then((abc) {
                                    FirebaseDatabase.instance.reference().child("Users").child(mData["Uid"]).child("Friends").push().set({"Name" : titlesF[index], "id" : Duid}).then((abc) {
                                      delF(idsF[index]);

                                    }).catchError((err) {
                                      print(err);
                                    });
                                  }).catchError((err) {
                                    print(err);
                                  });

                                },),
                              ],
                            ),
                          );
                        },
                      )
                  ),
                ]
            ),
          ],
        ),


        bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(icon: Icon(Icons.home), onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyRouter()),
                );
              },),
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
              IconButton(icon: Icon(Icons.public), disabledColor: Colors.green, onPressed: null,),
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

      ),
    );
  }
}