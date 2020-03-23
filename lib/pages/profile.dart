import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isTitle:true,title: 'profile' ),
      body: Text('profile'),);
  }
}
