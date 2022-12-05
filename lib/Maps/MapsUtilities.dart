import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';



IconData windIcon (double dir){

  List<IconData> icons = [CupertinoIcons.arrow_down,
    CupertinoIcons.arrow_down_left,
    CupertinoIcons.arrow_down_left,
    CupertinoIcons.arrow_up_left,
    CupertinoIcons.arrow_up,
    CupertinoIcons.arrow_up_right,
    CupertinoIcons.arrow_right,
    CupertinoIcons.arrow_down_right];


  double step = 45.0;

  double normalized = dir + (step/2.0);

  while(normalized < 0){
    normalized += 360.0;
  }

  while (normalized >= 360.0){
    normalized -= 360.0;
  }

  int i = (normalized / step).floor();

  return (icons[i]);

  /*

  if (normalized > 337.5 && normalized <= 22.5){
    return CupertinoIcons.arrow_down;
  } else if (normalized > 22.5 && normalized <= 67.5){
    return CupertinoIcons.arrow_down_left;
  }else if (normalized >67.5 && normalized <= 112.5){
    return CupertinoIcons.arrow_down_left;
  }else if (normalized > 112.5 && normalized <= 157.5){
    return CupertinoIcons.arrow_up_left;
  }else if (normalized > 157.5 && normalized <= 202.5){
    return CupertinoIcons.arrow_up;
  }else if (normalized > 202.5 && normalized <= 247.5){
    return CupertinoIcons.arrow_up_right;
  }else if (normalized > 247.5 && normalized <= 292.5){
    return CupertinoIcons.arrow_right;
  }else if (normalized > 292.5 && normalized <= 337.5){
    return CupertinoIcons.arrow_down_right;
  } else {
    return CupertinoIcons.arrow_down;
  }

   */
}

int beaufort(double speed){ // Speed in m/s

  var speedKmH = speed * 3.6;

  List<double> scale = [2.0, 5.0, 11.9, 19.0, 28.0, 38.0, 49.0, 61.0, 74.0, 88.0, 102.0, 117.0];

  for(var i = 0;  i < scale.length ; i++){
    if (speedKmH < scale[i]){
      return i;
    }
  }
  return scale.length;

}

int douglas(double speed){

  List<double> scale = [0.01, 0.10, 0.50, 1.25, 2.50, 4.00, 6.00, 9.00, 14.0];

  for(var i = 0;  i < scale.length ; i++){
    if (speed < scale[i]){
      return i;
    }
  }
  return scale.length-1;

}