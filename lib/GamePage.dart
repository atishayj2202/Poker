import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:poker/MainMenu.dart';
import 'package:poker/Vote.dart';
import 'package:poker/WaitArea.dart';
import 'package:recase/recase.dart';
import 'package:firebase_database/firebase_database.dart';

class MyDialog extends StatefulWidget {
  var gid;
  var mid;
  MyDialog(@required this.mid, @required this.gid);
  @override
  _MyDialogState createState() => new _MyDialogState(this.mid, this.gid);
}

class _MyDialogState extends State<MyDialog> {
  int slidevalue = 10;
  var disable = false;
  var leftC = 100;
  var Rerr = "";
  var gid;
  var mid;
  _MyDialogState(@required this.mid, @required this.gid);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.lightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(Rerr),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new IconButton(icon: Icon(Icons.keyboard_arrow_down), onPressed: (){
                if(10 <= slidevalue - 5){
                  setState(() {
                    slidevalue = slidevalue - 5;
                    Rerr = "";
                  });
                }
                else{
                  setState(() {
                    Rerr = "Total Chips can't be less than 10";
                  });
                }
              }),
              new Text(
                "Total : " + slidevalue.toString(),
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Roboto"),
              ),
              new IconButton(icon: Icon(Icons.keyboard_arrow_up), onPressed: (){
                setState(() {
                  slidevalue = slidevalue + 5;
                  Rerr = "";
                });
              }),
            ],
          ),
          new RaisedButton(onPressed: disable ? null : (){
            disable = true;
            setState(() {
            });
            CloudFunctions.instance.getHttpsCallable(functionName: "allBid").call(<String, dynamic>{
              'gid' : gid,
              "uid" : mid,
            }).then((result) {
              Navigator.of(context).pop();
            })/*.catchError((err) {
              print(err.message);
            })*/;
          },
            color: Colors.amber,
          child: Text("All-In"),),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new RaisedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: new Row(
                  children: <Widget>[
                    new Icon((Icons.arrow_back_ios)),
                    new Text("BACK")
                  ],
                ),
              ),
              new RaisedButton(
                onPressed: disable ? null : (){
                  disable = true;
                  setState(() {
                  });
                  CloudFunctions.instance.getHttpsCallable(functionName: "raiseBid").call(<String, dynamic>{
                    'gid' : gid,
                    "id" : mid,
                    "amount" : slidevalue,
                  }).then((result) {
                    if(result.data["Status"] != "Successfull"){
                      Rerr = result.data["Status"];
                      disable = false;
                      setState(() {});
                    }
                    else{
                      Navigator.of(context).pop();
                    }
                  }).catchError((err) {
                    print(err.message);
                  });
                },
                child: new Row(
                  children: <Widget>[
                    new Text("RAISE"),
                    new Icon((Icons.arrow_forward_ios))
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class MyGamePage extends StatefulWidget {
  MyGamePage({Key key}) : super(key: key);
  @override
  _MyGamePageState createState() => new _MyGamePageState();
}

class _MyGamePageState extends State<MyGamePage> {
  var disable = true;
  var Changer = null;
  var A1 = "yellow_back.png";
  var A2 = "yellow_back.png";
  var A3 = "yellow_back.png";
  var A4 = "yellow_back.png";
  var A5 = "yellow_back.png";
  var C1 = "yellow_back.png";
  var C2 = "yellow_back.png";
  var gid = "";
  var mid = "";
  var muid = "";
  var errtext = "";
  var Pot = 0;
  var TimerS = 3;
  var Chips = 0;
  List<dynamic> Users = [];
  List<dynamic> Pchips = [];
  var Checker = null;
  List<String> xf = ["High Card", "Pair", "Two Pair", "Three of a Kind", "Straight", "Flush", "Full House", "Four of a Kind", "Straight Flush", "Royal Flush"];

  @override
  void dispose(){
    gid = null;
    mid = null;
    Changer.cancel();
    super.dispose();
  }

  String setCard(Card){
    Card = Card - 1;
    var Rank = (Card%13) + 1;
    var Color = "";
    if(Card > 38){
      Color = "D.png";
    }
    else if(Card > 25){
      Color = "C.png";
    }
    else if(Card > 12){
      Color = "S.png";
    }
    else{
      Color = "H.png";
    }
    if(Rank == 1){
      Rank  = "A";
    }
    else if(Rank == 13){
      Rank  = "K";
    }
    else if(Rank == 12){
      Rank  = "Q";
    }
    else if(Rank == 11){
      Rank  = "J";
    }
    return (Rank.toString() + Color.toString());
  }

  Future<void> setData() async {
    FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).once().then((value) {
      var Data = value.value;
      if(Data["Status"] == "Playing"){
        if(Data["Round"] == "Voting"){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyVotePage()),
          );
        }
        else{
          if(Data["Round"] == 3){
            A4 = setCard(Data["C4"]);
            A5 = setCard(Data["C5"]);
          }
          else if(Data["Round"] == 2){
            A4 = setCard(Data["C4"]);
          }
          if(mid == Data["Chance"]){
            disable = false;
          }
          else{
            disable = true;
          }
          Pchips = [];
          var cnt = Data[mid]["Data"]["E"]["Result"] - 1;
          var path = "";
          Pot = Data["Pot"];
          errtext = xf[cnt];
          setState(() {});
          cnt = 1;
          var r = Data["Round"].toString();
          while(cnt-1 < Data["MaxP"]){
            path = "User" + cnt.toString();
            cnt = cnt + 1;
            @JsonKey(required: null)
            var temp = Data[path][r];
            if(temp != null){
              if(!(temp is int || temp is String)){
                temp = "All-In (" + Data[path][r]["Amount"].toString() + ")";
              }
            }
            Pchips.add(temp);
          }
          cnt = 0;
          while(cnt < Pchips.length){
            if(Pchips[cnt] == null){
              Pchips[cnt] = "";
            }
            else {
              Pchips[cnt] = "Put : " + Pchips[cnt].toString();
            }
            cnt = cnt + 1;
          }
          FirebaseDatabase.instance.reference().child("Users").child(value.value[mid]["id"]).once().then((snapshotU) {
            Chips = int.parse(snapshotU.value["Chips"].toString());
          });
          setState(() {});
        }
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRouter()),
        );
      }
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> maker () async {
    var id = await DeviceId.getID;
    CloudFunctions.instance.getHttpsCallable(functionName: "returnData").call(<String, dynamic>{
      'id' : id,
    }).then((result) {
      print(result.data);
      if(result.data["Status"] == "Game"){
        if(result.data["GameStatus"] == "Playing"){
          print(result.data);
          Pot = result.data["Pot"];
          //Chips = int.parse(result.data["Chips"].toString());
          errtext = xf[result.data["Evaluate"]["Result"] - 1];
          if(result.data["Round"] != "Voting"){
            Users = [];
            Pchips = [];
            A1 = setCard(result.data["Cards"][0]);
            A2 = setCard(result.data["Cards"][1]);
            A3 = setCard(result.data["Cards"][2]);
            C1 = setCard(result.data["Cards"][5]);
            C2 = setCard(result.data["Cards"][6]);
            gid = result.data["GameId"].toString();
            mid = result.data["Mid"];
            if(mid == result.data["Chance"]){
              disable = false;
            }
            else{
              disable = true;
            }
            if(result.data["Round"] == 3){
              A4 = setCard(result.data["Cards"][3]);
              A5 = setCard(result.data["Cards"][4]);
            }
            else if(result.data["Round"] == 2){
              A4 = setCard(result.data["Cards"][3]);
            }
            var cnt = 1;
            var path = "";
            while((cnt-1) < result.data["Max"]){
              path = "User" + cnt.toString();
              Users.add("User" + cnt.toString() + " : " + result.data["Udata"][path]["Name"]);
              if(result.data["Udata"][path]["Play"] == null){
                Pchips.add("");
              }
              else{
                Pchips.add("Put : " + result.data["Udata"][path]["Play"].toString());
              }
              cnt = cnt+ 1;
            }
            setState(() {
            });
            Changer = FirebaseDatabase.instance.reference().child("Game").child(gid.toString()).onChildChanged.listen((onData) {
              if((onData.snapshot.value).toString().contains("User") || (onData.snapshot.value).toString().contains("Voting")) {
                setData();
              }
            });
          }
          else{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyVotePage()),
            );
          }
        }
        else{
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWaitA()),
          );
        }
      }
      else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyRouter()),
        );
      }
    }).catchError((err){
      TimerS = 3;
       Timer.periodic(Duration(seconds: 1), (timer){
        if(TimerS < 1){
          timer.cancel();
          maker();
        }
        else{
          TimerS = TimerS - 1;
          errtext = "Your match will Start after " + TimerS.toString() + " Secs";
          setState(() {});
        }
      });
    });
  }

  void initState(){
    maker();
    //setData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:
      new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 5,
              child:
              Container(color: Colors.green,
              child: new ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: Users.length,
                  itemBuilder: (BuildContext context, index){
                    return ListTile(
                      title: Text(ReCase(Users[index].toString()).titleCase),
                      subtitle: Text(ReCase(Pchips[index].toString()).titleCase),
                    );
                  }
              ),),

            ),
            Expanded(
              flex: 15,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        errtext,
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w200,
                            fontFamily: "Roboto"
                        ),
                      ),
                      new Text(
                        "Pot : " + Pot.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w200,
                            fontFamily: "Roboto"),
                      ),
                      new Text(
                        "Chips Left : " + Chips.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w200,
                            fontFamily: "Roboto"),)
                    ],

                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.deepOrange,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+A1, height: 100,),
                      ),
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.deepOrange,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+A2, height: 100,),
                      ),
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.deepOrange,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+A3, height: 100,),
                      ),
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.deepOrange,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+A4, height: 100,),
                      ),
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.deepOrange,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+A5, height: 100,),
                      ),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.greenAccent,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+C1, height: 100,),
                      ),
                      new Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color : Colors.greenAccent,
                                width: 4
                            ),
                            borderRadius: BorderRadius.circular(9)
                        ),
                        child: Image.asset("assets/images/"+C2, height: 100,),
                      ),
                      new RaisedButton(
                        onPressed: disable ? null : () {
                          disable = true;
                          setState(() {});
                          CloudFunctions.instance.getHttpsCallable(functionName: "foldBid").call(<String, dynamic>{
                            'gid' : gid,
                            "uid" : mid,
                          }).catchError((err) {
                            print(err.message);
                          });
                        },
                        child: new Text("Fold"),
                        color: Colors.red,
                      ),
                      new RaisedButton(
                        onPressed: disable ? null : () {
                          disable = true;
                          setState(() {});
                          CloudFunctions.instance.getHttpsCallable(functionName: "callBid").call(<String, dynamic>{
                            'gid' : gid,
                            "uid" : mid,
                          }).catchError((err) {
                            print(err.message);
                          });
                        },
                        child: new Text("Call/\nCheck"),
                        color: Colors.green,
                      ),
                      new RaisedButton(
                        onPressed: disable ? null : () async {
                          await showDialog(
                            context: context,
                            builder: (_) {
                              return MyDialog(mid, gid);
                            }
                          ).then((g) {
                            setData();
                          });
                        },
                        child: new Text("Raise"),
                        color: Colors.blue,
                      )
                    ],
                  )
                ],

              )

            ),
          ]
      ),

    );
  }
}