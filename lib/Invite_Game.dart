import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker/WaitArea.dart';
import 'package:recase/recase.dart';
import 'MainMenu.dart';

class MyInvite extends StatefulWidget {
  MyInvite({Key key}) : super(key: key);
  @override
  _MyInviteState createState() => new _MyInviteState();
}

class _MyInviteState extends State<MyInvite> {
  var errtext = "Fetching data";
  var gid;
  var uid;
  var name = "";
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
      uid = data.value["Uid"];
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"]).once().then((snap) {
        if(snap.value["Status"] == "idle"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyRouter()),
          );
          return;
        }
        gid = snap.value["Status"];
        name = snap.value["Name"];
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
            dChips.add(filtered[info[i]]["id"]);
            i = i + 1;
          }
        }
        setState(() {});
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
  List<dynamic> Namesf = [];
  List<dynamic> dChips = [];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Invite Friends'),
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
                      trailing:
                        IconButton(
                          icon: Icon(Icons.group_add),
                          onPressed: () async {
                            FirebaseDatabase.instance.reference().child("Users").child(dChips[index]).child("Request").child("Game").push().set({"rid" : gid, "uid" : uid, "Name" : name});
                          },
                        )
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
            IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyWaitA()),
              );
            },),
          ],
        ),
      ),

    );
  }
}