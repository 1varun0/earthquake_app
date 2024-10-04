import 'dart:convert';
import 'package:earthquake_app/helper_functions.dart';
import 'package:earthquake_app/models/earthquake_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as gc;


class appprovider with ChangeNotifier{
  final baseurl=Uri.parse('https://earthquake.usgs.gov/fdsnws/event/1/query');
  Map<String,dynamic> queryparameters={};

  EarthquakeModel? earthquakeModel;
  double _maxradiuskm=500;
  double _latitude=0.0;
  double _longitude=0.0;
  String? _starttime;
  String? _endtime;
  String _orderby='time';
  String? _city;
  double _maxradiuskmthreshold=20001.6;
  bool _locationuse=false;


  double get maxradiuskm => _maxradiuskm;

  double get latitude => _latitude;

  double get longitude => _longitude;

  String? get starttime => _starttime;

  String? get endtime => _endtime;

  String get orderby => _orderby;

  String? get city => _city;

  double get maxradiuskmthreshold => _maxradiuskmthreshold;

  bool get locationuse => _locationuse;

  bool get hasdataloaded => earthquakeModel!=null;

  void setorder(String value){
    _orderby=value;
    notifyListeners();
    _setqueryparameters();
    getearthquakedata();
  }

 _setqueryparameters(){
   queryparameters['format']='geojson';
   queryparameters['starttime']=_starttime;
   queryparameters['endtime']=_endtime;
   queryparameters['minmagnitude']='3';
   queryparameters['orderby']=_orderby;
   queryparameters['limit']='500';
   queryparameters['latitude']='$_latitude';
   queryparameters['longitude']='$_longitude';
   queryparameters['maxradiuskm']='$_maxradiuskm';
 }

 init(){
   _starttime=getFormattedDateTime(DateTime.now().subtract(Duration(days:1)).millisecondsSinceEpoch);
   _endtime=getFormattedDateTime(DateTime.now().millisecondsSinceEpoch);
   _maxradiuskm=maxradiuskmthreshold;
   _setqueryparameters();
   getearthquakedata();
 }

 Color getalertcolor(String color){
   return switch(color){
     'green'=>Colors.green,
     'yellow'=>Colors.yellow,
     'orange'=>Colors.orange,
     _=>Colors.red,
   };
 }

 Future<void> getearthquakedata() async{
   final uri=Uri.https(baseurl.authority,baseurl.path,queryparameters);
   // print(uri);
   try{
     final response = await http.get(uri);
     // print(response.statusCode);
     if(response.statusCode==200){
       final json=jsonDecode(response.body);
       earthquakeModel=EarthquakeModel.fromJson(json);
       // print(earthquakeModel!.features!.length);
       notifyListeners();
     }
   }catch(error){
     print(error.toString());
     // print('hi');
   }
 }

  void setstarttime(String date){
    _starttime=date;
    _setqueryparameters();
    notifyListeners();
  }

  void setendtime(String date){
    _endtime=date;
    _setqueryparameters();
    notifyListeners();
  }

  Future<void> setlocation(bool value) async{
    _locationuse=value;
    notifyListeners();
    if(value){
      final position= await _determinePosition();
      _latitude=position.latitude;
      _longitude=position.longitude;
      await _getcity();
      _maxradiuskm=500;
      _setqueryparameters();
      getearthquakedata();
    }
    else{
      _latitude=0.0;
      _longitude=0.0;
      _maxradiuskm=_maxradiuskmthreshold;
      _city=null;
      _setqueryparameters();
      getearthquakedata();
    }
  }

  Future<void> _getcity() async{
    // print(gc.GeocodingPlatform);
    // Geolocator geolocator = Geolocator();
    try{
      print(_longitude);
      print(_latitude);
      final placemarklist= await gc.placemarkFromCoordinates(19.0785451,72.878176);
      if(placemarklist.isNotEmpty && placemarklist!=null){
        final placemark=placemarklist.first;
        _city=placemark.locality;
        notifyListeners();
      }
      else{
        print('No placemark found for the given coordinates!');
      }
    }
    catch(error){
      print(error);
    }
  }




  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}