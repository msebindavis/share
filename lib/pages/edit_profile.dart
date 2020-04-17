import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';


class EditProfile extends StatefulWidget {
  
  final String currentUserId ;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayValidate=true;
  bool _bioValidate=true;
  @override
  void initState() {
   
    super.initState();
    getUser();
  }
  getUser()async{
    setState(() {
      isLoading=true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
   user = User.fromDocument(doc);
   displayNameController.text =user.displayName;
   bioController.text = user.bio;
   setState(() {
     isLoading = false;
   });
  
  }
  buildDisplayField (){
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Display Name',style:TextStyle(color: Colors.grey)),
       
    TextFormField(
      controller:displayNameController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(20),
      hintText: 'Update Display Name',
       errorText: _displayValidate ? null :'Display Name is either short or empty',
      border: InputBorder.none
      ),
      
    )
      ],
      )
    );
  }
  buildBioField(){
     return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Bio',style:TextStyle(color: Colors.grey)),
    TextFormField(
      controller:bioController,
      decoration: InputDecoration(
      contentPadding: EdgeInsets.all(20),
      hintText: 'Update Bio',
      errorText: _bioValidate ? null :'Bio is too long',
      border: InputBorder.none
      ),
      
    )
      ],
      )
    );
  }
  updateProfile()async{
    setState(() {
      displayNameController.text.trim().length < 3 ||
      displayNameController.text.isEmpty ? _displayValidate =false :_displayValidate =true;
      bioController.text.trim().length > 100 ? _bioValidate=false:_bioValidate=true;
    });
    if(_bioValidate&&_displayValidate){
   
    await userRef.document(user.id).updateData({
      "displayName":displayNameController.text,
     "bio":bioController.text
    });
SnackBar snackBar = SnackBar(content: Text('Profile Updated!'),);
_scaffoldKey.currentState.showSnackBar(snackBar);

    }
  
  }
  logOut() async {
    await googleSignIn.signOut();
    Navigator.push(context,MaterialPageRoute(builder: (context)=>Home()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: <Widget>[
          IconButton(icon:Icon(Icons.check,color: Colors.blue,),
          onPressed: ()=>Navigator.pop(context),
          )
        ],
      ),
      body:Container(
        alignment: Alignment.center,
        color: Colors.white,
        child:ListView(
          children:<Widget>[ Column(
            
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: CircleAvatar(
                 backgroundColor: Colors.black,
                 backgroundImage: CachedNetworkImageProvider(user.photourl),
                 radius: 50,
                ),
              ),

            buildDisplayField(),
            buildBioField(),
       RaisedButton(
          
    onPressed: updateProfile,
    child:Text(
      'Update Profile',
      style:TextStyle(color: Theme.of(context).primaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold
      )
    )
  ),
  Padding(
    padding: EdgeInsets.all(16),
    child:FlatButton.icon(
      onPressed:logOut,
      icon: Icon(Icons.cancel,color: Colors.red,),
      label:Text('logout',
      style: TextStyle(
          color:Colors.red,
          fontSize: 20
      ),)
    )
  )
            ],
          ),
          ]
        ),

      
      ) ,
    );
  }
}
