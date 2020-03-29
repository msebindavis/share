import 'package:flutter/material.dart';

AppBar header(context,{bool isTitle=false,String title,removeBackButton=false}) {
  return AppBar(centerTitle:true,
  automaticallyImplyLeading: removeBackButton ? false:true,
  title:Text(isTitle ? title : 'share',
  style:TextStyle(
  fontFamily:isTitle ? "" :'Signatra',
  fontSize:isTitle ? 25 : 50.0 ),
    
    ),
  backgroundColor:Theme.of(context).accentColor,
    );
}
