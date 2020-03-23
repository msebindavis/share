import 'package:flutter/material.dart';

AppBar header(context,{bool isTitle=false,String title}) {
  return AppBar(centerTitle:true,
  title:Text(isTitle ? title : 'share',
  style:TextStyle(
  fontFamily:isTitle ? "" :'Signatra',
  fontSize:isTitle ? 25 : 50.0 ),
    
    ),
  backgroundColor:Theme.of(context).accentColor,
    );
}
