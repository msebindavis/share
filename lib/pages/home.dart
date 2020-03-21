import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth=false;
  Widget authenticated() {
    return Text('AUTH')
  }
  Scaffold unauthenticated() {
    return Scaffold(
      body: Container(
child: Column(
  children: <Widget>[
    Text('Share',
    style: TextStyle(
      
    ),)
  ],),
      ),
    );
  }
  @override
 Widget build(BuildContext context) {
    return isAuth ? authenticated() : unauthenticated();
  
  }
}
