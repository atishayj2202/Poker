import 'dart:convert';

import 'package:device_id/device_id.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker/CFriends.dart';
import 'package:recase/recase.dart';
import 'MainMenu.dart';

class MySearchF extends StatefulWidget {
  MySearchF({Key key}) : super(key: key);
  @override
  _MySearchFState createState() => new _MySearchFState();
}

class _MySearchFState extends State<MySearchF> {
  @override
  var mdata;

  Future<void> makeData() async {
    var id = await DeviceId.getID;
    FirebaseDatabase.instance.reference().child("Id").child(id).once().then((data) {
      FirebaseDatabase.instance.reference().child("Users").child(data.value["Uid"].toString()).once().then((snap) {
        mdata = snap.value;
        print(mdata);
      });
    });
  }
  void initState(){
    makeData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }

  var info = [];
  void returnbw(jsonString){
    info = [];
    var encode = jsonEncode(jsonString);
    var decoded = json.decode(encode);
    for (var colour in decoded.keys) {
      info.add(colour);
    }
  }

  List<dynamic> Namesf = [];
  List<dynamic> dChips = [];
  List<dynamic> Duid = [];
  var errtext = "";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Find Friends'),
        automaticallyImplyLeading: false,
      ),
      body:
        new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 5.0)),
            new TextFormField(
              onChanged: (value){
                if (value.isNotEmpty){
                  FirebaseDatabase.instance.reference().child("Users").orderByChild("Name").startAt(value).endAt(value+"\uf8ff").once().then((data) {
                    if(data.value != null){
                      info = [];
                      Namesf = [];
                      Duid = [];
                      dChips = [];
                      returnbw(data.value);
                      print(info);
                      var i = 0;
                      while(i < info.length){
                        Namesf.add(data.value[info[i]]["Name"]);
                        Duid.add(info[i]);
                        dChips.add(data.value[info[i]]["Chips"]);
                        i = i + 1;
                      }
                      setState(() {

                      });
                    }
                    else{
                      errtext = "No Result Found";
                      Namesf = [];
                      dChips = [];
                      Duid = [];
                      setState(() {
                        
                      });
                    }
                  });
                }
                else{
                  Namesf = [];
                  dChips = [];
                  Duid = [];
                  errtext ="No Result Found";
                  setState(() {});
                }
              },
              style: new TextStyle(
                  color: const Color(0xFFffffff),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto"),
              decoration: new InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.green,),
                hintText: "Enter Username of Person",
                labelText: "Search Person",
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
            new Text(errtext.toString()),
            new Expanded(
                child: new ListView.builder(
                  itemCount: Namesf.length,

                  itemBuilder: (BuildContext context, index) {
                    return ListTile(
                      title: Text(ReCase(Namesf[index].toString()).titleCase),
                      subtitle: Text("Chips : " + dChips[index].toString()),
                      trailing: IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: ()  {
                          if(Duid[index] == mdata["Uid"]){
                            errtext = "You cannot make yourself friend.";
                            setState(() {});
                            return;
                          }
                          var i = 0;
                          @JsonKey(required: null)
                          var tempf =  mdata["Friends"];
                          if(tempf != null){
                            returnbw(tempf);
                            while (i < info.length){
                              if(mdata["Friends"][info[i]]["Name"] == Namesf[index]){
                                errtext = "You are already friends";
                                setState(() {});
                                return;
                              }
                              i = i + 1;
                            }
                          }
                          FirebaseDatabase.instance.reference().child("Users").child(Duid[index].toString()).child("Request").child("Friend").push().set({"uid" : mdata["Uid"], "name" : mdata["Name"]}).then((d) {
                            errtext = "Request Sent";
                            setState(() {});
                          });
                        },
                      ),
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
            IconButton(icon: Icon(Icons.people), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyCurrentF()),
              );
            },),
            IconButton(icon: Icon(Icons.search), disabledColor: Colors.green, onPressed: null,),
          ],
        ),
      ),

    );
  }
}