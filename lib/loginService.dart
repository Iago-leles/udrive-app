import 'dart:convert';

import 'package:distribuida/usuario.dart';
import 'package:distribuida/usuarioService.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class loginService {
  var url_base = "http://localhost:8900/api/";

  usuarioService uService = usuarioService();

  Future<int> auth(Usuario nUser) async {
    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({
      "fullName": nUser.nome,
      "university": {"id": 1},
      "registrationNumber": nUser.cpf.toString().substring(0, 5),
      "cpf": nUser.cpf,
      "email": nUser.email,
      "phoneNumber": nUser.numeroTelefone
    });

    try {
      final response = await http.post(
        Uri.parse(url_base + "auth"),
        headers: headers,
        body: body,
      );

     if(response.statusCode == 200){
       return 200;
     }else{
       return response.statusCode;
     }

    } catch (error, stackTrace) {
      dev.log('Error: ', error: error, stackTrace: stackTrace);
    }

    return 0;

  }

  Future<int> login(String email, String password) async {
    var headers = {'Content-Type': 'application/json'};

    var body = jsonEncode({"email": email, "password": password});

    try {
      final response = await http.post(
        Uri.parse(url_base + "auth/authenticate"),
        headers: headers,
        body: body,
      );


      if(response.statusCode == 200){
        return 200;
      }else{
        return response.statusCode;
      }

    } catch (error, stackTrace) {
      dev.log('Error: ', error: error, stackTrace: stackTrace);
    }

    return 0;
  }

}
