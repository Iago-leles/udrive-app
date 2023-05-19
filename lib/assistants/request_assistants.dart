import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant{
  static Future<dynamic> receiveRequest(String url) async{
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode == 200){
        String responseData = httpResponse.body;
        var decodeReponseData = jsonDecode(responseData);

        return decodeReponseData;
      }
      else{
        return "Erro Ocurred. Failed. No Response";
      }
    }catch(exp){
      return "Erro Ocurred. Failed. No Response";
    }
  }
}