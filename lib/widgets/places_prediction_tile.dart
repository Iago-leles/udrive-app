import 'package:distribuida/assistants/request_assistants.dart';
import 'package:distribuida/global/map_key.dart';
import 'package:distribuida/infoHandler/app_info.dart';
import 'package:distribuida/models/predicted_places.dart';
import 'package:distribuida/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/directions.dart';

class PlacesPredictionTileDesign extends StatefulWidget {

  final PredictedPlaces? predictedPlaces;

  PlacesPredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacesPredictionTileDesign> createState() => _PlacesPredictionTileState();
}

class _PlacesPredictionTileState extends State<PlacesPredictionTileDesign> {
  
  String userDropOffAdress = "";

  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context, 
      builder: (BuildContext context) => ProgressDialog(
        message: "Carregando rota... Aguarde",
      ),
    );

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if(responseApi == "Erro Ocurred. Failed. No Response"){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAdress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropOff");
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ElevatedButton(
      onPressed: (){
        getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.add_location,
            color: Colors.blue,
            ),

            SizedBox(width: 10,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),

                  Text(
                    widget.predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  )
                ],
                ),
                ),
          ],
        ),),
    );
  }
}