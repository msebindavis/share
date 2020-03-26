import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn= new GoogleSignIn();
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
if(account!=null) {
  setState(() {
    print('user signed in !:$account');
    isAuth=true;
  });
}
else {
  setState(() {
    isAuth=false;
  });
}

    },onError: (err) {
      print('error signing in: $err');
    }
    );
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
        ActivityFeed(),
        Upload(),
        Search(),
        Profile()

      ],
      controller: pageController,
      onPageChanged:onPageChanged,
      physics:NeverScrollableScrollPhysics() ,
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
    // return RaisedButton(
    //   child:Text('logout',
    //   style: TextStyle(color: Colors.deepPurple,
    //  ),),
    //   onPressed:logout,

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
