

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final userRef = Firestore.instance.collection('users');
class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
List<dynamic> users = [];
  @override
  void initState() {
   
    // getUserById();
    super.initState();
  }
//   getUserById() async {

// final DocumentSnapshot doc = await userRef.document('WRLyxEKXzPL9XarP6Mb5').get();
// print(doc.data);
//   }
 
  @override
  Widget build(context) {
    return Scaffold(appBar:header(context),
    body:StreamBuilder<QuerySnapshot>(
      stream: userRef.snapshots(),
      builder:(context,docs) {
        if(!docs.hasData) {
          circularProgress();
        }
        final List<Text> children = docs.data.documents
        .map((doc)
           => Text(doc['username'])
        ).toList();
        return Container(
          child: ListView(
            children:children,),
        );
      }

    )
    );
  }
}


