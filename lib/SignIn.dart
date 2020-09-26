import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_id/device_id.dart';
import 'MainMenu.dart';
import 'SignUp.dart';
import 'package:flutter/services.dart';

class MySignIn extends StatefulWidget {
  MySignIn({Key key}) : super(key: key);
  @override
  _MySignInState createState() => new _MySignInState();
}

class _MySignInState extends State<MySignIn> {
  bool th1 = true;
  final _id = TextEditingController();
  final _pass = TextEditingController();
  var _abc = "";

  // ignore: non_constant_identifier_names
  Future<void> checkCurrent() async {
    FirebaseDatabase.instance.reference().child("Id").child(await DeviceId.getID).once().then((snapshot){
      var email = snapshot.value["id"] as String;
      if (email.isNotEmpty){
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
    checkCurrent();
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
        title: new Text('Sign In',),
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
              obscureText: th1,
              controller: _pass,
              style: new TextStyle(
                  color: const Color(0xFFffffff),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
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
            new RaisedButton(key:null, onPressed:(){
              var aid = _id.text;
              var apass = _pass.text;
              FirebaseAuth.instance.signInWithEmailAndPassword(email: aid, password: apass).then((user) async {
                FirebaseDatabase.instance.reference().child("Id").child(await DeviceId.getID).update({
                  "id": aid,
                  "Uid" : user.user.uid,
                }).then((snap) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyRouter()),
                  );
                }).catchError((err){
                  setState(() {
                    _abc = err.message;
                  });
                });
              }).catchError((err){
                setState(() {
                  _abc = err.message;
                });
              });
            },
              child:
              new Text(
                "Log In",
                style: new TextStyle(
                    color: const Color(0xFFffffff),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
              ),
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
            ),

            new RaisedButton(key:null, onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Mysignup()),
              );
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
            )
          ]

      ),

    );
  }

}
