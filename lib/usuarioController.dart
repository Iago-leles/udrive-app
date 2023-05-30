import 'dart:convert';

import 'package:distribuida/usuario.dart';
import 'package:distribuida/usuarioService.dart';
import 'package:http/http.dart' as http;

class usuarioController{

  usuarioService uService = usuarioService();


  List<Usuario> listaUsuarios = <Usuario>[];

  void auth(String nome, String email, int cpf, String nTelefone) async {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('http://localhost:8900/api/auth'));
    request.body = json.encode({
      "fullName": "Iago Leles",
      "university": {
        "id": 1
      },
      "registrationNumber": "793133",
      "cpf": "12345678910",
      "email": "alvarocesar2002@gmail.com",
      "phoneNumber": "3193965283"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }

  void novoUsuario(String nome, String email, int cpf, String nTelefone){
    Usuario nUser = Usuario(1, nome, email, cpf, nTelefone, "");
  }

  void realizarLogin(String email, String senha){

    print(listaUsuarios.length);

  }

}