import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rck_painel_tarefa/model/web_usuario.dart';
import 'package:rck_painel_tarefa/screens/painel_tarefa_consulta_api_route.dart';
import 'package:rck_painel_tarefa/screens/painel_tarefa_consulta_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/web_api_exporta.dart';
class LoginsRoute extends StatelessWidget {
  const LoginsRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return  MyHomePage(title: 'Ola!\nRRC', );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var login   = TextEditingController();
  var senha   = TextEditingController();
  var token   = TextEditingController();
  bool passwordVisible  = true;
  var  isLogado         = false;
  Future<bool> _getSharedPreferences() async {
    try {
      if ((Platform.isIOS || Platform.isAndroid) ) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String temp = (prefs.getString('token_rck') ?? '');
        if (temp.isEmpty) {
          return false;
        }
        token.text = (prefs.getString('token_rck') ?? '');
        login.text = (prefs.getString('login_rck') ?? '');
        senha.text = (prefs.getString('senha_rck') ?? '');
        if (token.text.toString().isNotEmpty &&
            login.text.toString().isNotEmpty &&
            senha.text.toString().isNotEmpty) {
          isLogado = true;
          //_loginAPI(context);
          _login(context);
          return true;
        }
        return false;
      } else {
        login.text = "rck sistemas";
        senha.text = "secreto";
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
          login.text = "rck sistemas";
          senha.text = "secreto";
        }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SizedBox _sizedBoxPortrait() =>
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Card(
            // Define the shape of the card
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: MyColorsSample. rckappOld,
                  width: 1
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 12.0,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            margin: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            // Define how the card's content should be clipped
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 16, bottom: 16, right: 16, top: 16),
                      child: Text(
                        "Ola! Seja bem vindo! V 1.0.0-A 20-02-25 14:30 PM . Informe seu usuário/e-mail e senha e toque no botão abaixo para fazer o login no aplicativo!.(E)",
                        style: MyTextSample.small2(context)!.copyWith(
                          color: MyColorsSample.grey_80,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20.00),
                    child: Center(),
                  ),
                  Padding(
                    //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: login,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontFamily: 'AvenirLight'),
                          enabledBorder: new OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black, width: 1.0)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'Usuário/e-mail'),
                      //textInputAction: TextInputAction.done,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.00),
                    child: Center(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 0, bottom: 0),
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: senha,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(
                                    () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                          //alignLabelWithHint: false,
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontFamily: 'AvenirLight'),
                          enabledBorder: new OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.black, width: 1.0)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          labelText: 'Senha'),
                      keyboardType: TextInputType.visiblePassword,
                      //textInputAction: TextInputAction.done,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.00),
                    child: Center(),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(32),
                    height: 4,
                    decoration: BoxDecoration(color: MyColorsSample.grey_1),
                    margin: new EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 0.0),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    decoration: BoxDecoration(
                        color: MyColorsSample.rckapp,
                        borderRadius: BorderRadius.circular(4)),
                    child: TextButton(
                      onPressed: () {
                        //_loginAPI(context);
                        _login(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: MyColorsSample.white, fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: MyColorsSample.rckapp, width: 0.50)),
                    child: TextButton(
                      onPressed: () {
                        //_loginAPI(context, login, senha);
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: Text(
                        'Sair',
                        style: TextStyle(color: Colors.black87, fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black12, // Text Color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    Container _sizedBoxLandescape() =>
        Container(
          height: MediaQuery.of(context).size.height,
          child: Card(
            // Define the shape of the card
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: MyColorsSample. rckappOld,
                  width: 1
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 12.0,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            margin: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            // Define how the card's content should be clipped
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 16, bottom: 16, right: 16, top: 16),
                      child: Text(
                        "Ola! Seja bem vindo!. Informe seu usuário/e-mail e senha e toque no botão abaixo para fazer o login no aplicativo!!.",
                        style: MyTextSample.small2(context)!.copyWith(
                          color: MyColorsSample.grey_80,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: Center(),
                  ),
                  Center(
                    child: Row(mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[

                      Container(
                        constraints:
                        BoxConstraints.expand(height: 90.0, width:MediaQuery.of(context).size.width / 2.3),
                        margin: new EdgeInsets.symmetric(
                            horizontal: 8.0),
                        child: TextField(
                          controller: login,
                          decoration: InputDecoration(
                              labelStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontFamily: 'AvenirLight'),
                              enabledBorder: new OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'Usuário/e-mail'),
                        ),
                      ),

                      Container(
                        constraints:
                        BoxConstraints.expand(height: 90.0, width:MediaQuery.of(context).size.width / 2.3),
                        margin: new EdgeInsets.symmetric(
                            horizontal: 8.0),
                        child: TextField(
                          controller: senha,
                          //onChanged: (newText) {
                          //  senha.text = newText;
                          //},
                          obscureText: passwordVisible,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(
                                        () {
                                      passwordVisible = !passwordVisible;
                                    },
                                  );
                                },
                              ),
                              alignLabelWithHint: false,
                              labelStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontFamily: 'AvenirLight'),
                              enabledBorder: new OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.black, width: 1.0)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: 'Senha landscape'),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ]),
                  ),

                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    decoration: BoxDecoration(
                        color: MyColorsSample.rckapp,
                        borderRadius: BorderRadius.circular(4)),
                    child: TextButton(
                      onPressed: () {
                        //_loginAPI(context);
                        _login(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: MyColorsSample.white, fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin: new EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 4.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: MyColorsSample.rckapp, width: 0.50)),
                    child: TextButton(
                      onPressed: () {
                        //_loginAPI(context, login, senha);
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      child: Text(
                        'Sair',
                        style: TextStyle(color: Colors.black87, fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black12, // Text Color
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        );


    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: new Center(
              child: new Text("  RCK-RRC  RCK-EXPORTA-XML  ", textAlign: TextAlign.center)),
          automaticallyImplyLeading: false,
          titleTextStyle: MyTextSample.medium(context).copyWith(
            color: MyColorsSample.grey_80,
          ),
          //title: Text("  RCK-RRC   WEB RCK-WHALLE-APP  ", textAlign: TextAlign.center),
          //titleTextStyle: MyTextSample.medium(context).copyWith(
          //  color: MyColorsSample.grey_80,
          //),
        ),

        body: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _sizedBoxPortrait()
                : kIsWeb ? _sizedBoxPortrait() : _sizedBoxLandescape() ;
          },
        ),

        //body: kIsWeb == false ? _sizedBoxPortrait() : _sizedBoxLandescape(),
      ),
    );
  }

  Future<String> getUrlAPI() async {
    String fileText = await rootBundle.loadString('assets/URLAPI.txt');
    return fileText.toString().trim();
  }


  Future _login(BuildContext context) async{

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
      //}
    }




        //}





    final api       = ApiUsuario(Dio(BaseOptions(contentType: "application/json")), baseUrl: "${await getUrlAPI()}/ws");
    if ( isLogado) {
      try {
        final usuario = await api.getUsuario(
            login.text.toString(), senha.text.toString());
        if ( usuario.length <= 0) {
           _showToast(context, "Usuário/senha não localizado(s)!.", 3, false);
           return;
        }
        if (usuario[0].token.isNotEmpty) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PainelTarefasRouteAPI(idUsuario: /*int.parse(usuario[0].id_usuario)*/ usuario[0].id_usuario ?? "0",  tokenUsuario: usuario[0].token ?? '0')));

        } else {
          _showToast(context, "Usuário/senha não localizado(s)!!.", 3, false);
        }
      } on DioException catch (e) {
        if (e.response != null) {
          _showToast(context, e.toString(), 5, false);
        } else {
          _showToast(context, e.message.toString(), 5, false);
        }
      }
    } else {
      try {
        final usuario = await api.getUsuario(
            login.text.toString(), senha.text.toString());
        if ( usuario.length <= 0) {
          _showToast(context, "Usuário/senha não localizado(s)!.", 3, false);
          return;
        }
        if (usuario[0].token.isNotEmpty) {
          if (kIsWeb ) {
            Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PainelTarefasRouteAPI(idUsuario: /*int.parse(usuario[0].id_usuario)*/ usuario[0].id_usuario ?? "0",  tokenUsuario: usuario[0].token ?? '0')));
          } else {
            if ((Platform.isIOS || Platform.isAndroid)) {
              _setSharedPreferences(
                  usuario[0].token, usuario[0].login, usuario[0].senha, usuario[0].id_usuario, usuario[0].id_vendedor, usuario[0].nome_usuario);
            } else {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PainelTarefasRouteAPI(idUsuario: /*int.parse(usuario[0].id_usuario)*/ usuario[0].id_usuario ?? "0" ,  tokenUsuario: usuario[0].token ?? '0')));
            }
          }
          //}
        } else {
          _showToast(context, "Usuário/senha não localizado(s)!!.", 3, false);
        }
      } on DioException catch (e) {
        if (e.response != null) {
          _showToast(context, e.toString(), 5, false);
        } else {
          _showToast(context, e.message.toString(), 5 , false);
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

  Future<String?> _getId() async {
    if ( kIsWeb ) {
      return "web";
    }
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.fuchsia) {
      return defaultTargetPlatform.name.toString();
    }
    var deviceInfo = DeviceInfoPlugin();
    if ( (Platform.isIOS || Platform.isAndroid) ) {
      if (Platform.isIOS) {
        var iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor;
      }
      if (Platform.isAndroid) {
        var androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.id; // unique ID on Android
      }
      return "web";
    }
    return "outro";
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

class MyColorsSample {
  static const Color rckapp = Color(0xFF68ACA1);
  static const Color rckappOld = Color(0xFF31595F);
  static const Color primary = Color(0xFF12376F);
  static const Color primaryDark = Color(0xFF0C44A3);
  static const Color primaryLight = Color(0xFF43A3F3);
  static const Color green = Colors.green;
  static Color black = const Color(0xFF000000);
  static const Color accent = Color(0xFFFF4081);
  static const Color accentDark = Color(0xFFF50057);
  static const Color accentLight = Color(0xFFFF80AB);
  static const Color grey_1 = Color(0xFFf9f9f9);
  static const Color grey_3 = Color(0xFFf7f7f7);
  static const Color grey_5 = Color(0xFFf2f2f2);
  static const Color grey_10 = Color(0xFFe6e6e6);
  static const Color grey_20 = Color(0xFFcccccc);
  static const Color grey_40 = Color(0xFF999999);
  static const Color grey_60 = Color(0xFF666666);
  static const Color grey_80 = Color(0xFF37474F);
  static const Color grey_90 = Color(0xFF263238);
  static const Color grey_95 = Color(0xFF1a1a1a);
  static const Color grey_100_ = Color(0xFF0d0d0d);
  static const Color transparent = Color(0x00f7f7f7);
  static const Color white = Color(0xFFFFFFFF);
}
class MyTextSample {
  static TextStyle? display4(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge;
  }

  static TextStyle? display3(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium;
  }

  static TextStyle? display2(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall;
  }

  static TextStyle? display1(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium;
  }

  static TextStyle? headline(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall;
  }

  static TextStyle? title(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge;
  }

  static TextStyle medium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 16,
    );
  }

  static TextStyle mediumValue(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 18,
    );
  }

  static TextStyle small(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 12,
    );
  }

  static TextStyle small2(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 14,
    );
  }

  static TextStyle? subhead(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium;
  }

  static TextStyle? body2(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge;
  }

  static TextStyle? body1(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium;
  }

  static TextStyle? caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall;
  }

  static TextStyle? button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(letterSpacing: 1);
  }

  static TextStyle? subtitle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall;
  }

  static TextStyle? overline(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall;
  }
}
