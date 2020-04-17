import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final StorageReference storageRef = FirebaseStorage.instance.ref();
final  userRef = Firestore.instance.collection('users'); 
final  postRef = Firestore.instance.collection('posts'); 
final GoogleSignIn googleSignIn= new GoogleSignIn();
final DateTime timestamp =DateTime.now();
 User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth=false;
  PageController pageController;
  int pageIndex=0;
  @override
  void initState() { 
    super.initState(); 
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
     handleSignIn(account);
    }  ,onError: (err) {
      print('error signing in: $err');
    }
    );
    googleSignIn.signInSilently(suppressErrors: false)
    .then((account){
      handleSignIn(account);
    }).catchError((err){
       print('error signing in: $err');
    });
  }
  
  handleSignIn(GoogleSignInAccount account)  {
    if(account!=null) {
      createUserInFirestore();
  setState(() {
    print('user signed in !:$account');
    isAuth=true;
  });
}
else {
  setState(() {
    print('failed');
    isAuth=false;
  }

  );
}

  
  }
  createUserInFirestore() async {
  final GoogleSignInAccount user = googleSignIn.currentUser;
  DocumentSnapshot doc = await userRef.document(user.id).get();
 if(!doc.exists) {
final username= await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccount()));


userRef.document(user.id).setData({
  "id":user.id,
  "username":username,
  "photourl":user.photoUrl,
  "email":user.email,
  "displayName":user.displayName,
  "bio":"",
  "timestamp":timestamp
});
doc = await userRef.document(user.id).get();
 }
 currentUser = User.fromDocument(doc);
  }


@override
void dispose() { 
  pageController.dispose();
  super.dispose();
}  
  login() {
googleSignIn.signIn();
  }
  logout() {
googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
setState(() {
  this.pageIndex=pageIndex;
});
  }
  onTap(int pIndex) {
   return pageController.animateToPage(pIndex,
   duration: Duration(milliseconds: 300),
   curve: Curves.bounceInOut
   );
  }
  Widget authenticated() {
    return Scaffold(body: PageView(
      children: <Widget>[
        Timeline(),
    //     RaisedButton(
          
    //   child:Text('logout',
    //   style: TextStyle(
    //     color: Colors.deepPurple,
    //  ),
    //  ),
    //   onPressed:logout,),
        ActivityFeed(),
        Upload(currentUser:currentUser),
        Search(),
        Profile(profileId:currentUser?.id)

      ],
      controller: pageController,
      onPageChanged:onPageChanged,
     
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex:pageIndex,
        onTap:onTap,
        activeColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 40,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          
          ],
          ),
          );
     

  }
  Scaffold unauthenticated() {
    return Scaffold(
      body: Container(
        decoration:BoxDecoration(
          gradient:LinearGradient(
            begin:Alignment.topRight,
            end:Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ]
          ) ),
     child:Center(  
child: Column(
  
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    Text('Share',
    style: TextStyle(
      fontFamily: 'Signatra',
      fontSize: 90.0,
      color: Colors.white,
    ),
    ),
   GestureDetector(
     child:Container(
       width:260,
       height:60 ,
       decoration: BoxDecoration(
         image:DecorationImage(image:  AssetImage('assets/images/google_signin_button.png'),
         fit: BoxFit.cover
         )
       )
     ),
     onTap:(){login();})
  ],
  ),
     ) 
      ),
    );
  }
  
  @override
 Widget build(BuildContext context) {
  
    return isAuth ? authenticated() : unauthenticated();
  
  }
}
