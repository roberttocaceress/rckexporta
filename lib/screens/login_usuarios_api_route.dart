import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rck_painel_tarefa/main.dart';
import 'package:rck_painel_tarefa/screens/painel_tarefa_consulta_api_route.dart' hide MyColorsSample;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/web_usuario.dart';

class LoginUsuarioRoute extends StatefulWidget {
  const LoginUsuarioRoute({Key? key}) : super(key: key);

  @override
  State<LoginUsuarioRoute> createState() => _LoginUsuarioRouteState();
}

class _LoginUsuarioRouteState extends State<LoginUsuarioRoute> {
  final _formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final senhaController = TextEditingController();
  final tokenController = TextEditingController();
  bool _isLoading = false; // Estado para controlar o feedback de carregamento
  bool _obscurePassword = true; // Estado para controlar a visibilidade da senha
  var  isLogado         = false;
  // MÉTODO SIMULADO DE LOGIN
  Future _login() async{

    final webUsuarios = FirebaseFirestore.instance
        .collection('usuarios')
        .withConverter<WebUsuario>(
      fromFirestore: (snapshot, _) => WebUsuario.fromFirestore(snapshot),
      toFirestore: (webUsuario, _) => webUsuario.toFirestore(),
    );


    final querySnapshot = await webUsuarios.get();

    for (var doc in querySnapshot.docs) {
      WebUsuario usuario = doc.data(); // Já vem como objeto Usuario!
      print(usuario.nome_usuario);
      //if (usuario.token.isNotEmpty) {
      if (kIsWeb ) {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PainelTarefasRouteAPI(idUsuario: /*int.parse(usuario[0].id_usuario)*/ usuario.id_usuario ?? "0",  tokenUsuario: usuario.token ?? '0')));
      } else {
        if ((Platform.isIOS || Platform.isAndroid)) {
          _setSharedPreferences(
              usuario.token, usuario.login, usuario.senha, usuario.id_usuario, usuario.id_vendedor, usuario.nome_usuario);
        } else {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PainelTarefasRouteAPI(idUsuario: /*int.parse(usuario[0].id_usuario)*/ usuario.id_usuario ?? "0" ,  tokenUsuario: usuario.token ?? '0')));
        }
      }
    }
  }
  void _setSharedPreferences(String token, String login, String senha, String idUsuario, String idVendedor, String nomeUsuario) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token_rck', token);
    await prefs.setString('login_rck', login);
    await prefs.setString('senha_rck', senha);
    await prefs.setString('id_usr__rck', idUsuario);
    await prefs.setString('id_vnd__rck', idVendedor);
    await prefs.setString('n_user_rck' , nomeUsuario);

    Navigator.of(context).pop();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PainelTarefasRouteAPI(idUsuario: /*int.parse(idUsuario)*/ idUsuario ?? "0",  tokenUsuario: token ?? '0')));

  }

  Future<bool> _getSharedPreferences() async {
    try {
      if ((Platform.isIOS || Platform.isAndroid) ) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String temp = (prefs.getString('token_rck') ?? '');
        if (temp.isEmpty) {
          return false;
        }
        tokenController.text = (prefs.getString('token_rck') ?? '');
        loginController.text = (prefs.getString('login_rck') ?? '');
        senhaController.text = (prefs.getString('senha_rck') ?? '');
        if (tokenController.text.toString().isNotEmpty &&
            loginController.text.toString().isNotEmpty &&
            senhaController.text.toString().isNotEmpty) {
          isLogado = true;
          //_loginAPI(context);
          _login();
          return true;
        }
        return false;
      } else {
        loginController.text = "rck sistemas";
        senhaController.text = "secreto";
      }


    } on Exception catch (e) {
      _showToast(context, e.toString(), 5, false);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    if ( !kIsWeb ) {
      if ((Platform.isIOS || Platform.isAndroid) ) {
        _getSharedPreferences();
      }
    } else {
      loginController.text = "rck sistemas";
      senhaController.text = "secreto";
    }
  }


  @override
  void dispose() {
    loginController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // MELHORIA 1: Usar um degradê sutil no fundo para mais profundidade visual
      // Evita um fundo branco ou de cor sólida chapada.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surface, colors.surface.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // MELHORIA 2: Usar `SingleChildScrollView` com `SafeArea`
        // Garante que a UI não seja cortada por entalhes (notches) e seja rolável em telas menores.
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // MELHORIA 3: Logo ou Ícone da Aplicação
                    // Cria uma identidade visual forte e preenche o espaço superior.
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(left:16, bottom: 16, right: 16, top:16),
                        child:  Image.asset('assets/ic_logo.png',  width: MediaQuery.of(context).size.width /2 , height: MediaQuery.of(context).size.height /5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bem-vindo!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Faça login para continuar.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // MELHORIA 4: Campos de Texto (TextFormField) Estilizados
                    // Uso de ícones, bordas arredondadas e `InputDecoration` customizada.
                    TextFormField(
                      controller: loginController,
                      decoration: InputDecoration(
                        labelText: 'Login',
                        prefixIcon: Icon(Icons.person, color: MyColorsSample.rckappOld),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      //keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Por favor, insira um login válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: senhaController,
                      obscureText: _obscurePassword, // Controla a visibilidade
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline, color: MyColorsSample.rckappOld),
                        // MELHORIA 5: Ícone de "olho" para mostrar/esconder a senha
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: colors.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // MELHORIA 6: Opção "Esqueci minha senha"
                    // Melhora a usabilidade, alinhando o texto à direita.


                    // MELHORIA 7: Botão de Login com Feedback de Carregamento
                    // O botão mostra um CircularProgressIndicator quando `_isLoading` é true.
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          elevation: 4, // Adiciona uma leve sombra
                        ),
                        // Desabilita o botão durante o carregamento
                        onPressed: _login,
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                            : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),


                    // MELHORIA 8: Divisor visual e opções de login social ou cadastro

                    const SizedBox(height: 24),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showToast(context, mensagem ,  int second,  bool sucesso) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: sucesso ? MyColorsSample.rckapp : MyColorsSample.accentDark,
          duration: Duration(seconds: second),
          behavior: SnackBarBehavior.floating,
          elevation: 50,
          content: Row(
            children: [
              sucesso ?
              const Icon(
                Icons.check,
                color: Colors.white,
                size: 22,
              ) : const Icon(
                Icons.warning,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(
                width: 24,
              ),
              Flexible(
                child: Text(
                  'Atenção\n$mensagem',
                  style: TextStyle(
                      backgroundColor: sucesso ? MyColorsSample.rckapp : MyColorsSample.accentDark,
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: MyColorsSample.white),
                ),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        )
    );
  }
}
