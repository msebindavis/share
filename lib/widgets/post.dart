import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final bool isPage;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.isPage
  });

  factory Post.fromDocument({DocumentSnapshot doc,bool isPage=false}) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      isPage:isPage
    );
  }

  int getLikeCount(likes) {

    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        isPage:this.isPage
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart=false;
  bool isPage;
 

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
    this.isPage
  });
showProfile(context){
Navigator.push(context, MaterialPageRoute(builder: (context)=>
  Profile(profileId: ownerId)
  ));
}
  buildPostHeader() { 
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        bool isPostOwner = currentUserId == ownerId;
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photourl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner ? IconButton(
            onPressed: () => handleDeletePost(context),
            icon: Icon(Icons.more_vert),
          ): Text(''),
        );
      },
    );
  }
handleDeletePost(parentContext){
 return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Remove this Post?"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Delete",style: TextStyle(color: Colors.red), ),
                onPressed:() {
                  Navigator.pop(context);
                  deletePost();
      }
                   ),

            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
}
deletePost(){
 
 postRef
 .document(currentUserId)
 .collection('userPosts')
 .document(postId)
 .get()
 .then((doc){
 if(doc.exists){
   doc.reference.delete();
 }
 });
storageRef.child('post_$postId.jpg').delete();

activityFeedRef
.document(currentUserId)
.collection('feedItems')
.where('postId',isEqualTo:postId)
.getDocuments()
.then((docs){
  docs.documents.forEach((doc){
    if(doc.exists){
      doc.reference.delete();
    }
  });
});
commentsRef
.document(postId)
.collection('comments')
.getDocuments()
.then((docs){
  docs.documents.forEach((doc){
     if(doc.exists){
    doc.reference.delete();
     }
  });
});

}

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: postLike,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
         CachedNetworkImage(
        imageUrl: mediaUrl,
        placeholder: (context, url) => circularProgress(),
        errorWidget: (context, url, error) => Icon(Icons.error),
     ),
      showHeart ? Animator(
        duration: Duration(milliseconds: 1000),
        tween: Tween(begin: 0.8,end: 1.4),
        curve: Curves.elasticOut,
        cycles: 0,
        builder: (anim)=>Transform.scale(scale: anim.value,
        child:Icon(Icons.favorite,
        size:80.0,
        color:Colors.red
        )
        )
      ):Text(''),
        ],
      ),
    );
  }
postLike(){
 bool _isLiked = likes[currentUserId] == true;
 if(_isLiked) {
   postRef
   .document(ownerId)
   .collection('userPosts')
   .document(postId)
   .updateData({
     'likes.$currentUserId':false
   });
   removeLikeFromActivityFeed();
   setState(() {
     likeCount-=1;
     isLiked=false;
     likes[currentUserId] = false;
   });
   
 }
  else if(!isLiked) {
    postRef
   .document(ownerId)
   .collection('userPosts')
   .document(postId)
   .updateData({
     'likes.$currentUserId':true
   });
   addLikeToActivityFeed();
   setState(() {
     likeCount+=1;
     isLiked=true;
     likes[currentUserId] = true;
     showHeart=true;
   });
  }  

  Timer(Duration(milliseconds: 500),(){
     setState(() {
       showHeart=false;
     });
   });      
}

addLikeToActivityFeed(){
  if(currentUserId!=ownerId){
 activityFeedRef
  .document(ownerId)
  .collection('feedItems')
  .document(postId)
  .setData({
    "type":"like",
    "username":currentUser.username,
    'userId':currentUser.id,
    'userProfileImg':currentUser.photourl,
    'postId':postId,
    'mediaUrl':mediaUrl,
    'timestamp':timestamp
  });
  }
 
}
removeLikeFromActivityFeed(){
  if(currentUserId!=ownerId){
     activityFeedRef
  .document(ownerId)
  .collection('feedItems')
  .document(postId)
  .get().then((onValue){
    if(onValue.exists){
      onValue.reference.delete();
    }
  });

  }
  }
  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: postLike,
              child: Icon(
                isLiked ? Icons.favorite:Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId:postId,
                ownerId:ownerId,
                mediaUrl:mediaUrl
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description))
          ],
        ),
      ],
    );
  }
pageSelector(){
  if(isPage){
    return Scaffold(
      appBar: header(context,isTitle:true,title:'Post'),
      body:ListView(
      shrinkWrap: true,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    ));
  }
  else{
 return 
        Column(
        children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
  @override
  Widget build(BuildContext context) {
      isLiked = likes[currentUserId]==true;
     return pageSelector();
    
  }
}

showComments(BuildContext context,{String postId,String ownerId,String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context){
    return Comments(
      postId:postId,
      postOwnerId:ownerId,
      postMediaUrl:mediaUrl,
    );
  }));
}