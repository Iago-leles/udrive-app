// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, unused_import, avoid_web_libraries_in_flutter

// import 'dart:html';

import 'package:distribuida/telas/login.dart';
import 'package:distribuida/usuario.dart';
import 'package:distribuida/usuarioController.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class CadastroUser extends StatelessWidget {
  final TextEditingController _controladorNome = TextEditingController();
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorCpf = TextEditingController();
  final TextEditingController _controladorNumeroTelefone =
      TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();

  usuarioController nUsuarioController = usuarioController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              '../assets/img/logo.png',
              width: 300,
            ),
            const Center(
              child: Text('Cadastre-se:',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: _controladorNome,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Informe o seu Nome',
                  prefixIcon: Padding(
                      padding: EdgeInsets.all(5), child: Icon(Icons.person)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: _controladorEmail,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'exemplo@email.com',
                  prefixIcon: Padding(
                      padding: EdgeInsets.all(5), child: Icon(Icons.mail)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: _controladorCpf,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'CPF',
                  prefixIcon: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.document_scanner)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                controller: _controladorNumeroTelefone,
                decoration: const InputDecoration(
                  labelText: 'Número de Telefone',
                  hintText: 'Telefone',
                  prefixIcon: Padding(
                      padding: EdgeInsets.all(5), child: Icon(Icons.phone)),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(50.0),
                child: SizedBox(
                  width: 150,
                  height: 45,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 100,
                      shadowColor: Colors.white54,
                    ),
                    child: const Text(
                      'Cadastrar-se',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      _showSuccessDialog(context, await nUsuarioController.criarCadastro(
                          _controladorNome.text,
                          _controladorEmail.text,
                          _controladorCpf.hashCode,
                          _controladorNumeroTelefone.text));
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mensagem de retorno: '),
          content: Text(mensagem),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  (mensagem).contains("Cadastro realizado com sucesso!") ?  MainScreen(): CadastroUser()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
