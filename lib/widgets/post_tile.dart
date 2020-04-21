import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('showing post'),
      child: CachedNetworkImage(
        imageUrl: post.mediaUrl,
        placeholder: (context, url) => circularProgress(),
        errorWidget: (context, url, error) => Icon(Icons.error),
     ),
    );
  }
}
