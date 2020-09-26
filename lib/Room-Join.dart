import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:device_id/device_id.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker/RouteGame.dart';
import 'package:flutter/services.dart';

import 'WaitArea.dart';

class MyRoomIn extends StatefulWidget {
  MyRoomIn({Key key}) : super(key: key);
  @override
  _MyRoomInState createState() => new _MyRoomInState();
}

class _MyRoomInState extends State<MyRoomIn> {
  bool th1 = true;
  final _id = TextEditingController();
  final _pass = TextEditingController();
  var _abc = "";
  var disable = false;
  var mData;
  Future<void> control() async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).once().then((DBM) {
        mData = DBM.value;
      });
    });
  }

  @override
  void initState(){
    control();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }

  @override
  void dispose(){
    _id.dispose();
    _pass.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Join Room',),
        automaticallyImplyLeading: false,
      ),
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              "$_abc",
              style: new TextStyle(color: Colors.red,),
              textAlign: TextAlign.center,
            ),
            new TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              controller: _id,
              style: new TextStyle(
                  color: const Color(0xFFffffff),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
              decoration: new InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.green,),
                hintText: "Enter Your Room Id",
                labelText: "Room Id",
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(width: 4,color: Colors.green)
                ),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(width: 4,color: Colors.red)
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(width: 4, color: Colors.white)
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 5.0)),
            new RaisedButton(key:null, onPressed: disable ? null : () async {
              disable = true;
              setState(() {

              });
              var id = await DeviceId.getID;
              if (_id.text.isNotEmpty){
                var gid = _id.text;
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
                      print(mData);
                      FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).child(path).set({"id" : mData["Uid"], "name" : mData["Name"]}).then((abc) {
                        FirebaseDatabase.instance.reference().child("Users").child(mData["Uid"].toString()).update({"Status" : gid}).then((abd) {
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
                      _abc = "No Space left";
                      disable = false;
                      setState(() {});
                    }
                  }
                  else{
                    _abc = "This Room Is Already Started";
                    disable = false;
                    setState(() {});
                  }

                }).catchError((err) {
                  _abc = "Room Not Found";
                  disable = false;
                  print(err);
                  setState(() {

                  });
                });
              }
            },
              child:
              new Text(
                "Join Room",
                style: new TextStyle(
                    color: const Color(0xFFffffff),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
              ),
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
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
                MaterialPageRoute(builder: (context) => MyRouteGame()),
              );
            },),
          ],
        ),
      ),

    );
  }

}
