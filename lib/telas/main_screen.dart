// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously, unused_field, prefer_final_fields, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:distribuida/assistants/assistants_methods.dart';
import 'package:distribuida/global/global.dart';
import 'package:distribuida/global/map_key.dart';
import 'package:distribuida/models/direction_details_info.dart';
import 'package:distribuida/telas/precise_pickup_location.dart';
import 'package:distribuida/telas/search_places_screen.dart';
import 'package:distribuida/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../infoHandler/app_info.dart';
import '../models/directions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geolocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> plineCoordinatedList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantsMethods.searchAdressForGeographicCoOrdinates(
            userCurrentPosition!, context);
  }

  Future<void> drawPolylineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition!.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Por favor espere ...",
            ));

    var directionsDetailsInfo =
        await AssistantsMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    var valueResponse =
        await calcularCorrida(directionsDetailsInfo.distance_value!);

    var message = valueResponse["Message"];
    var decimalValue = double.parse(message) / 2000;
    var valuePure = NumberFormat("#,##0.00", "pt_BR").format(decimalValue);

    setState(() {
      tripDirectionDetailsInfo = directionsDetailsInfo;
      valueRun = valuePure;
    });

    print("Valor da corrida: ${directionsDetailsInfo.distance_value}");

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionsDetailsInfo.e_points!);

    plineCoordinatedList.clear();

    if (decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        plineCoordinatedList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: plineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast:
              LatLng(originLatLng.latitude, destinationLatLng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 80));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origem"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    // Container valueRunContainer = Container(
    //   padding: EdgeInsets.all(16),
    //   color: Colors.blue,
    //   child: Text(
    //     'Valor da corrida: R\$ ${directionsDetailsInfo.distance_value}',
    //     style: TextStyle(
    //       color: Colors.white,
    //       fontSize: 18,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    // );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destino"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  Future<Map<String, dynamic>> calcularCorrida(int distance) async {
    final url = Uri.parse('http://10.204.65.104:3300/calculate');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'distance': distance});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Falha ao chamar a API: ${response.statusCode}');
    }
  }

  checkIfLocationPermissionAlloned() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissionAlloned();
  }

  bool showContainer = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Bem vindo!"),
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 200;
                });

                locateUserPosition();
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 119, 183, 255),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          color: Colors.blue),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Origem",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            Provider.of<AppInfo>(context)
                                                        .userPickUpLocation !=
                                                    null
                                                ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.getLocationName()).substring(0, 40)}..."
                                                : "Nenhum endereço selecionado",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var responseFromSearchScreen =
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (c) =>
                                                      SearchPlacesScreen()));

                                      if (responseFromSearchScreen ==
                                          'obtainerDropOff') {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      await drawPolylineFromOriginToDestination();

                                      setState(() {
                                        if (!showContainer) {
                                          showContainer = !showContainer;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            color: Colors.blue),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Destino",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .userDropOffLocation !=
                                                      null
                                                  ? Provider.of<AppInfo>(
                                                              context)
                                                          .userDropOffLocation!
                                                          .getLocationName() +
                                                      "..."
                                                  : "Nenhum endereço selecionado",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (showContainer)
                      Container(
                        padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color.fromARGB(
                                255, 119, 183, 255), // Cor da borda
                            width: 5, // Espessura da borda
                          ),
                        ),
                        child: Text(
                          'Valor da corrida:      R\$${valueRun} ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 119, 254),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => PrecisePickupScreen()));
                          },
                          child: Text(
                            "Mudar localização",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "Solicitar corrida",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
