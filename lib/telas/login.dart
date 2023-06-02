import 'package:distribuida/telas/main_screen.dart';
import 'package:distribuida/usuario.dart';
import 'package:flutter/material.dart';

import '../usuarioController.dart';
import 'cadastro.dart';

class LoginUser extends StatelessWidget {

  usuarioController nUsuarioController = usuarioController();

  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('../assets/img/logo.png', width: 300,),
            const Center(
              child: Text('Login:',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: TextField(
                controller: _controladorEmail,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'exemplo@email.com',
                  prefixIcon: Padding(
                      padding: EdgeInsets.all(5),
                      child:
                      Icon(Icons.mail)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: TextField(
                controller: _controladorSenha,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Informe sua senha',
                  prefixIcon: Padding(
                      padding: EdgeInsets.all(5),
                      child:
                      Icon(Icons.key)),
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
                      'Login',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                      onPressed: () async {
                        String mensagem = await nUsuarioController
                            .realizarLogin(
                            _controladorEmail.text, _controladorSenha.text);

                          Navigator.push(
                            context, MaterialPageRoute(
                                builder: (context) => MainScreen()));

                      }
                  ),
                )
            ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextButton(
             child: const Text(
                'Cadastrar-se',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CadastroUser()),
                  );
              }
          ),
        ),
          ],
        ),
      ),
    );
  }

  void _showFalhaDialog(BuildContext context, String mensagem) {
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
                  MaterialPageRoute(builder: (context) =>  LoginUser()),
                );
              },
            ),
          ],
        );
      },
    );
  }

}
