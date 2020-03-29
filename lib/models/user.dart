import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
 final String id;
 final String email;
 final String photoUrl;
 final String displayName;
 final String bio;

 User({
   this.bio,this.displayName,this.photoUrl,this.email,this.id,this.username
 });
factory User.fromDocument(DocumentSnapshot doc){
  return User(
id:doc['id'],
email:doc['email'],
username:doc['username'],
photoUrl:doc['photoUrl'],
displayName:doc['displayName'],
bio:doc[''],

);


}
}
