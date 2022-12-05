import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


extension Widgets on String{

  Image image(width){
    var fullName = "assets/$this.png";
    return Image(image: AssetImage(fullName), width: width,);
  }
}


extension on String? {

  bool isEmpty() {
    if (this == null){
      return true;
    }
    
    var clean = this!.replaceAll(RegExp(r"\s+"), "");
    if (clean!.length == 0){
      return true;
    }
  
    return false;
  }


  bool isNotEmpty() {

  return !isEmpty();

  }
}




