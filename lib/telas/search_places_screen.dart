import 'package:distribuida/assistants/request_assistants.dart';
import 'package:distribuida/global/map_key.dart';
import 'package:distribuida/widgets/places_prediction_tile.dart';
import 'package:flutter/material.dart';

import '../models/predicted_places.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({ Key? key }) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placesPredicetedList = [];

  findPlacedAutoCompleteSearch(String inputText) async{
    if(inputText.length > 1){
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:BR";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

       if(responseAutoCompleteSearch == "Erro Ocurred. Failed. No Response"){
      return;
      }

      if(responseAutoCompleteSearch["status"] == "OK"){
        var placesPreditions = responseAutoCompleteSearch["predictions"];

        var placesPredictionsList = (placesPreditions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredicetedList = placesPredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark; 

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: GestureDetector(
            onTap: () {
               Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white,),
          ),
          title: Text(
            "Pesquisar e definir destino",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7)
                  )
                ]
              ),
              child: Padding(padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.adjust_sharp, color: Colors.white,
                      ),

                      SizedBox(height: 18.0,),

                      Expanded(child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        onChanged: (value) {
                          findPlacedAutoCompleteSearch(value);
                        },
                        decoration: InputDecoration(hintText: "Digite o local aqui...",
                        fillColor: Colors.white54,
                        filled: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 11, top: 8, bottom: 8),),
                      ),
                      ))
                    ],
                  )
                ],
              ),
              ),
            ),

            //display place predictions result
            (placesPredicetedList.length > 0) ? Expanded(
              child: ListView.separated(
                itemCount: placesPredicetedList.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index){
                  return PlacesPredictionTileDesign(
                    predictedPlaces: placesPredicetedList[index],
                  );
                },
                
                separatorBuilder: (BuildContext context, int index){
                  return Divider(
                    height: 0,
                    color: Colors.blue,
                    thickness: 0,
                  );
                },
              ) 
            
            ) :  Container(),
          ],
        ),
      ),
    );
  }
}