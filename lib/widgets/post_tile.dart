import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);
showPost(context)async{
 DocumentSnapshot doc = await postRef
        .document(post.ownerId)
        .collection('userPosts')
        .document(post.postId)
        .get();
  Navigator.push(context, MaterialPageRoute(builder: (context)=>
  Post.fromDocument(doc:doc,isPage:true)));
}
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: CachedNetworkImage(
        imageUrl: post.mediaUrl,
        placeholder: (context, url) => circularProgress(),
        errorWidget: (context, url, error) => Icon(Icons.error),
     ),
    );
  }
}
