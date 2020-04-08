import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  
  buildCountColumn(String label,int count){

  }
  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          circularProgress();
        }
      User user = User.fromDocument(snapshot.data);
      return Padding(
        padding:EdgeInsets.all(16),
        child:Column(children: <Widget>[
          Row(children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(user.photourl),
              ),
              Expanded(
                flex: 1,
                child:Column(children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buildCountColumn('posts',0),
                      buildCountColumn('followers',0),
                      buildCountColumn('following',0),
                  ],)
                ],)

              )
          ],)
        ],)
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isTitle:true,title: 'profile' ),
      body:ListView(children: <Widget>[
        buildProfileHeader(),
      ],),
      );
  }
}
