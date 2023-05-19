import 'package:flutter/material.dart';
import 'package:distribuida/usuario.dart';
import 'dart:convert';

class usuarioService {

  bool validarUsuario(Usuario nUser){

    bool userValido = false;
    userValido = validarEmail(nUser.email);

    return (validarEmail(nUser.email));
  }

  bool validarEmail(String email){
    // Pendente fazer chamada de api;
    /*Exemplo:
    *   final String _apiKey;

  EmailValidatorService(this._apiKey);

  Future<bool> validate(String email) async {
    final url = Uri.parse('https://api.mailboxvalidator.com/v1/validation/single?key=$_apiKey&email=$email');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['error_code'] != null) {
        throw Exception('Erro ao validar e-mail: ${data['error_message']}');
      }

      return data['is_verified'] == 'True';
    } else {
      throw Exception('Erro ao validar e-mail.');
    }
  }*/
    return true;
  }

}
