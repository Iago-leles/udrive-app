import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  //List<String> historyTripsKeysList = [];
  //List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}