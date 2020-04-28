

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/pages/home.dart';


class Timeline extends StatefulWidget {
 
  
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
List<Post> timelinePost = [];
  @override
  void initState() {
    super.initState();
     getTimeline();
  }
  getTimeline() async {
   QuerySnapshot docs = await  timelineRef
  .document(currentUser.id)
  .collection('timelinePosts')
  .orderBy('timestamp',descending: true)
  .getDocuments();

  List<Post> timelinePost=[]; 
  docs.documents.forEach((doc){
    Post postTile = Post.fromDocument(doc:doc,isPage:false);
      timelinePost.add(postTile);
      
      
  });
  setState(() {
    this.timelinePost = timelinePost;
  });
  }
 buildTimeline(){
   if(timelinePost==null){
     return circularProgress();
   } else if(timelinePost.isEmpty){return Text('No Posts'); }
   else {
     return ListView(children:timelinePost);
   }
 }
  @override
  Widget build(context) {
    return Scaffold(appBar:header(context),
    body:RefreshIndicator(onRefresh: ()=>getTimeline(),
    child: buildTimeline(),
    )
    );
  }
}


