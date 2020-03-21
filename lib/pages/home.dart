import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn= new GoogleSignIn();
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth=false;
  @override
  void initState() { 
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((account) {
if(account!=null) {
  setState(() {
    isAuth=true;
  });
}
else {
  setState(() {
    isAuth=false;
  });
}
    });
  }
  login() {
googleSignIn.signIn();
  }
  Widget authenticated() {
    return Text('AUTH');
  }
  Scaffold unauthenticated() {
    return Scaffold(
      body: Container(
        decoration:BoxDecoration(
          gradient:LinearGradient(
            begin:Alignment.topRight,
            end:Alignment.bottomLeft,
            colors: [
              Colors.teal,
              Colors.purpleAccent
            ]
          ) ),
     child:Center(  
child: Column(
  
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    Text('Share',
    style: TextStyle(
      fontFamily: 'Signatra',
      fontSize: 90.0,
      color: Colors.white,
    ),
    ),
   GestureDetector(
     child:Container(
       width:260,
       height:60 ,
       decoration: BoxDecoration(
         image:DecorationImage(image:  AssetImage('assets/images/google_signin_button.png')
         )
       )
     ),
     onTap:login())
  ],
  ),
     ) 
      ),
    );
  }
  @override
 Widget build(BuildContext context) {
    return isAuth ? authenticated() : unauthenticated();
  
  }
}
