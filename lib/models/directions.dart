import 'package:flutter/material.dart';

class Directions{
  String? humanReadableAddress;
  String? locationName;
  String? locationId;
  double? locationLatitude;
  double? locationLongitude;

  Directions({
    this.humanReadableAddress,
    this.locationName,
    this.locationId,
    this.locationLatitude,
    this.locationLongitude,
  });

   getLocationName<String>(){
    int variavelLength = locationName!.length;

    if(locationName!.length >= 40 ){
      return locationName!.substring(0,40);
    }
   
    return this.locationName;
  }
}


