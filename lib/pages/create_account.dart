import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
final formKey = GlobalKey<FormState>();
final scaffoldKey = GlobalKey<ScaffoldState>();

  onTap() {
    final form =formKey.currentState;
    if(form.validate()){
      form.save();
      SnackBar snackBar = SnackBar(content: Text('Welcome $username!'),);

      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2),() {
      Navigator.pop(context,username);
      });
  }
    }

    
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: scaffoldKey,
      appBar:header(context,isTitle:true,title:'Set up you profile',removeBackButton: true),
      body:Column(
        children: <Widget>[
          Padding(
            padding:EdgeInsets.only(top:10.0),
            child:Center(
              child:Text("Create a username",
              style: TextStyle(
                
                fontSize: 25,
              ),
              )
               ,)
            ),
          Form(
            key:formKey ,
            child:Padding(padding:EdgeInsets.all(16) ,
              child:TextFormField(
                validator: (val) {
                  if(val.trim().length>12){
                    return "Username too long";
                  } else if(val.trim().length<4 ||val.isEmpty){
                    return "Username too short";
                  } else {
                    return null;
                  }
                },
                onSaved: (val)=>username=val ,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
                labelStyle: TextStyle(fontSize:15),
                hintText: "Must be atleast 3 characters"
              ),
            ) 
            ),
          ),
          GestureDetector(
            child:Container(
              height: 50,
              width: 325,
              decoration: BoxDecoration(
                color:Colors.blue ),
              alignment:Alignment.center ,
              child: Text('Next',
              style:TextStyle(
                fontSize: 25,
                color: Colors.white
              ) ,),),
              onTap: onTap,
              )
        ],
        ),
        );
  }
}
