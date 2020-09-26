import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_id/device_id.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:poker/MainMenu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'SignIn.dart';
import 'package:flutter/services.dart';


class Mysignup extends StatefulWidget {
  Mysignup({Key key}) : super(key: key);
  @override
  _MysignupState createState() => new _MysignupState();
}

class _MysignupState extends State<Mysignup> {
  bool th1 = true;
  bool th2 = true;
  var uni = Icons.block;
  var unir = Colors.red;
  String _abc = "";
  final _id = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  final _rpass = TextEditingController();

  Future<void> CheckCurrent() async {
    FirebaseDatabase.instance.reference().child("Id").child(await DeviceId.getID).once().then((snapshot){
      var email = snapshot.value["id"] as String;
      if (email.isNotEmpty ){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyRouter()),
          );
      }
    }).catchError((err){
      print("");
    });
  }

  @override
  void initState(){
    CheckCurrent();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _id.dispose();
    _pass.dispose();
    _name.dispose();
    _rpass.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Sign Up'),
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
              controller: _name,

              onChanged: ((value) {
                if(value.length < 7){
                  uni = Icons.block;
                  unir = Colors.red;
                  setState(() {

                  });
                }
                else{
                  FirebaseDatabase.instance.reference().child("Users").orderByChild("Name").equalTo(value.toLowerCase()).once().then((data) {
                    if(data.value == null){
                      uni = Icons.check_circle;
                      unir = Colors.lightBlue;
                      setState(() {

                      });

                    }
                    else{
                      uni = Icons.block;
                      unir = Colors.red;
                      setState(() {

                      });
                    }
                  });
                }
              }),
              style: new TextStyle(
                  color: const Color(0xFFffffff),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
              decoration: new InputDecoration(
                suffixIcon: Icon(uni, color: unir, size: 40,),
                prefixIcon: Icon(Icons.account_circle, color: Colors.green,),
                hintText: "Enter Your Name",
                labelText: "Name",
                helperText: "Username visible to Players",
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
                hintText: "Enter Your Id",
                labelText: "Email",
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
            new TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: new TextStyle(
                  color: const Color(0xFFffffff),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
              controller: _pass,
              obscureText: th1,
              decoration: new InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: (){
                    setState(() {
                      th1 = !th1;
                    });
                  },
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.green,),
                hintText: "Enter Your Password",
                labelText: "Password",
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
            new TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: new TextStyle(
                  color: const Color(0xFFffffff),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
              controller: _rpass,
              obscureText: th2,

              decoration: new InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: (){
                    setState(() {
                      th2 = !th2;
                    });
                  },
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.green,),
                hintText: "Retype Your Password",
                labelText: "Retype Password",
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
            new RaisedButton(key:null, onPressed: () async {

              if(_name.text == "" || _id.text == "" || _pass.text == "" || _rpass.text == ""){
                setState(() {
                  _abc = "Any of feild is left Empty";
                });
              }
              else if (_pass.text != _rpass.text){
                setState(() {
                  _abc = "Password & Retype Password don't match";
                });
              }
              else if(unir == Colors.red){
                setState(() {
                  _abc = "Username is not unique";
                });
              }
              else{
                setState(() {
                  _abc = "";
                });
                CloudFunctions.instance.getHttpsCallable(functionName: "makeUser").call(<String, dynamic>{
                  'name' : _name.text.toLowerCase(),
                  'email': _id.text,
                  'dev_id': await DeviceId.getID,
                  'password': _pass.text,
                }).then((data) {
                  if(data.data == "Successfull"){
                    setState(() {
                      _abc = "Successfully Signed Up";
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyRouter()),
                    );
                  }
                  else{
                    setState(() {
                      _abc = data.data;
                    });
                  }
                }).catchError((e) {
                  String mess = e.message;
                  print(e);
                  setState(() {
                    _abc = mess;
                  });
                });

              }

            },
              child:
              new Text(
                "Sign Up",
                style: new TextStyle(
                    color: const Color(0xFFffffff),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
              ),
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),

            ),

            new RaisedButton(key:null, onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MySignIn()),
              );
            },
              child:
              new Text(
                "Sign In",
                style: new TextStyle(
                    color: const Color(0xFFffffff),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
              ),
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
            )
          ]

      ),

    );
  }

}
