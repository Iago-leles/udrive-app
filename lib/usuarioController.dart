import 'dart:convert';

import 'package:distribuida/loginService.dart';
import 'package:distribuida/usuario.dart';
import 'package:distribuida/usuarioService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class usuarioController {
  usuarioService uService = usuarioService();
  loginService lService = loginService();

  List<Usuario> listaUsuarios = <Usuario>[];

  Future<String> criarCadastro(String nome, String email, int cpf, String nTelefone)  async {
    Usuario nUser = Usuario(1, nome, email, cpf, nTelefone, "");

    try {
      int status = await lService.auth(nUser);
      if(status == 200){
        return "Cadastro realizado com sucesso!";
      }
      else{
        return "Erro no cadastro, tente novamente.";
      }
    } catch (error, stackTrace) {
      dev.log('Error: ', error: error, stackTrace: stackTrace);
    }

    return "Erro.";
  }

  Future<String> realizarLogin(String email, String senha) async {
    try {
      int status = await lService.login(email, senha);

      if(status == 200){
        return "Sucesso";
      }
      else{
        return "Dados incorretos!";
      }
    } catch (error, stackTrace) {
      dev.log('Error: ', error: error, stackTrace: stackTrace);
    }

    return "Erro, tente novamente.";
  }
}
