import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:recase/recase.dart';

import 'MainMenu.dart';
import 'SFriends.dart';

class MyCurrentF extends StatefulWidget {
  MyCurrentF({Key key}) : super(key: key);
  @override
  _MyCurrentFState createState() => new _MyCurrentFState();
}

class _MyCurrentFState extends State<MyCurrentF> {
  var errtext = "Fetching Data";

  var info = [];
  void returnbw(jsonString){
    var encode = jsonEncode(jsonString);
    var decoded = json.decode(encode);
    info = [];
    for (var colour in decoded.keys) {
      info.add(colour);
    }
  }

  Future<void> makeData() async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).once().then((snap) {
        @JsonKey(required: null)
        var filtered = snap.value["Friends"];
        if(filtered == null){
          errtext= "You don't have any friend";
          setState(() {});
          return;
        }
        else{
          errtext= "";
          returnbw(filtered);
          var i = 0;
          while(i < info.length){
            Namesf.add(filtered[info[i]]["Name"]);
            i = i + 1;
          }
        }
        setState(() {});
      });
    });

    /*CloudFunctions.instance.getHttpsCallable(functionName: "returnFriends").call(<String, dynamic>{
      "id": await DeviceId.getID,
    }).then((result) {
      print(result.data);
      if(result.data["Status"] == "Successfull"){
        Namesf = result.data["Ndata"];
        dChips = result.data["Cdata"];
        errtext ="";
        setState(() {});
      }
      else{
        Namesf = [];
        dChips = [];
        errtext ="You Have No Friends";
        setState(() {});
      }
    });*/
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
  List<dynamic> Namesf = [];
  List<dynamic> dChips = [];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Current Friends'),
        automaticallyImplyLeading: false,
      ),
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text(errtext),
            new Expanded(
                child: new ListView.builder(
                  itemCount: Namesf.length,
                  itemBuilder: (BuildContext context, index) {
                    return ListTile(
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
            IconButton(icon: Icon(Icons.home), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyRouter()),
              );
            },),
            IconButton(icon: Icon(Icons.people), disabledColor: Colors.green, onPressed: null,),
            IconButton(icon: Icon(Icons.search), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MySearchF()),
              );
            },),
          ],
        ),
      ),

    );
  }
}