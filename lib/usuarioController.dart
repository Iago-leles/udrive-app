import 'package:distribuida/usuario.dart';
import 'package:distribuida/usuarioService.dart';

class usuarioController{

  usuarioService uService = usuarioService();

  List<Usuario> listaUsuarios = <Usuario>[];

  void novoUsuario(String nome, String email, String senha){
    Usuario nUser = Usuario(listaUsuarios.length, nome, email, '', senha);
    if(uService.validarUsuario(nUser)) {
      listaUsuarios.add(nUser);
      print(listaUsuarios.length);
    }
  }

  void realizarLogin(String email, String senha){

    print(listaUsuarios.length);

    listaUsuarios.forEach((user) {
      if(user.email == email && user.senha == senha){
        print("Sucesso!!!");
      }
      else{
        print("Falha no login");
      }
    });

  }

}