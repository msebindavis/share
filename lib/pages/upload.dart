import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
 final User currentUser;
Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;

  bool isUploading =false;
  
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();


Future<String> uploadImage(imageFile,postId) async {
 
StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
String downloadUrl =await storageSnap.ref.getDownloadURL();
return downloadUrl;
}

compressImage() async{

  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  String postId = Uuid().v4();
  final compressedImage = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 85));
  setState(() {
    file = compressedImage;
  });
  return postId;
}
createPostInFirestore({String mediaUrl,String postId}){
postRef.document(widget.currentUser.id).collection("userPosts").document(postId)
.setData({
"postId":postId,
"ownerId":widget.currentUser.id,
'username':widget.currentUser.username,
'mediaUrl':mediaUrl,
'description':captionController.text,
'location':locationController.text,
'timestamp':timestamp,
'likes':[]

});
captionController.clear();
locationController.clear();
setState(() {
  file=null;
  isUploading=false;
});
}

handleSubmit() async {
     setState(() {
         isUploading = true;
        });
    String postId = await compressImage();
    String mediaUrl = await uploadImage(file,postId);
    createPostInFirestore(mediaUrl:mediaUrl,postId:postId);
  }

handleCamera()async{
  Navigator.pop(context);
  File file = await ImagePicker.pickImage(source: ImageSource.camera);
  setState(() {
    this.file=file;
  });
}
handleGallery()async{
  Navigator.pop(context);
  File file = await ImagePicker.pickImage(source: ImageSource.gallery);
  setState(() {
    this.file=file;
  });
}

  selectImage(context) {
    return showDialog(context:context,
    builder:(context){
      return SimpleDialog(
        title:Text('Create a Post'),
        children: <Widget>[
          SimpleDialogOption(child: Text('Photo from Camera'),
          onPressed: handleCamera,),
        SimpleDialogOption(child: Text('Photo from Gallery'),
        onPressed:handleGallery,),
        SimpleDialogOption(child: Text('Cancel'),
        onPressed:()=> Navigator.pop(context),)
        ],);
    }
    );
  }
  buildSplashScreen(){
    
    return Container(
        
        child:Column(
         mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          
            SvgPicture.asset('assets/images/upload.svg',
            height:260,
            
              ),

            RaisedButton(
                padding: EdgeInsets.only(
                  left:25,right:25,bottom: 10,top:10
                ),
                shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(8.0)),
             color: Colors.blueAccent,
             child:Text('Post',style: TextStyle(color: Colors.white,fontSize: 22),),
             onPressed:()=>selectImage(context),)
                
            
          ],
        ) ,
        );
    
  }
  clearImage(){
    setState(() {
      file=null;
    });
  }
  buildForm(){
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.white70,
        title:Center(child:Text('Caption Post',style: TextStyle(color: Colors.black),)),
        leading: IconButton(icon:Icon(Icons.arrow_back,
        color: Colors.black,),
        onPressed:clearImage,
    ),
    actions:[
      FlatButton(
        child:Text('Post',style: TextStyle(color: Colors.blue,fontSize: 22),),
      onPressed:isUploading ? null : handleSubmit,
      )
    ],
      ),
    
      body: ListView(
        shrinkWrap: true,
        children:<Widget>[
          isUploading ? linearProgress():Text(''),
       Container(
          height: 260,
          width: MediaQuery.of(context).size.width,
          
            child:Container(
              decoration: BoxDecoration(
                image:DecorationImage(
                  image:FileImage(file) ) ) ,),),
                  SizedBox(height:20 ,),
        ListTile(
          leading:CircleAvatar(
            backgroundImage:CachedNetworkImageProvider(widget.currentUser.photourl),
            backgroundColor: Colors.grey ,),
            title:TextField(
              controller: captionController,
              decoration:InputDecoration(contentPadding:EdgeInsets.only(right:5,left:5),
              border:InputBorder.none,
              hintText:'Caption'
              ) ,  ),),
              Divider(),
      Padding(
        padding:EdgeInsets.only(right:8,left: 20),
        child: ListTile(leading: Icon(Icons.pin_drop,color: Colors.orange,size: 30,),
        title:TextField(controller: locationController, decoration:InputDecoration(border: InputBorder.none,hintText: 'Location'),
        ) 
        ,),
      ),
      Container(
        alignment: Alignment.center,
        child: RaisedButton.icon(onPressed:getUserLocation, 
        label  : Text('Use Current LOcation',style: TextStyle(color: Colors.white),),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: Colors.blue,
        icon:Icon(
          Icons.my_location,
          color: Colors.orange,
        )
        ),
      )
      ],),
      );
  }
  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
 List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude,position.longitude);
  Placemark placemark =placemarks[0];
  String completeAdress = '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
  print(completeAdress);
  String formattedAddress = " ${placemark.locality},${placemark.country}";
  locationController.text =formattedAddress;
  }
  @override
  Widget build(BuildContext context) {
    return file==null? buildSplashScreen() : buildForm();
  }
}
