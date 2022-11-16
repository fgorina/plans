import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


extension Widgets on String{

  Image image(width){
    var fullName = "assets/$this.png";
    return Image(image: AssetImage(fullName), width: width,);
  }
}
