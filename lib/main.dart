import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rck_painel_tarefa/screens/login_usuarios_api_route.dart';
import 'package:rck_painel_tarefa/screens/login_usuarios_route.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

//import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(
    MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
      home: LoginUsuarioRoute(),
    ),
  );
}
/*
void main() {
  runApp(MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate
    ],
    supportedLocales: [const Locale('pt', 'BR')],
    home: MyApp(),
  ))
  //);const MyApp());
}

 */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RCK-WHALLE-APP V1.0.0',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ola!\nRRC', ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _token = "";
  void _sharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = (prefs.getString('token') ?? '') ;
    if ( _token.isEmpty) {
      await prefs.setString('token', "-");
      setState(() {
        _token = (prefs.getString('token') ?? 'Token não definido');
        _showToast(context, 'Token atualizado $_token');
      });
    }
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  void _showToast(BuildContext context, String mensagem) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Contato'),
        action: SnackBarAction(label: mensagem , onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      backgroundColor: MyColorsSample.white,
      /*
      appBar: AppBar(
        title: Text("  RCK-RRC   WEB APP RCKWHALLE  "),
        titleTextStyle: MyTextSample.medium(context).copyWith(
          color: MyColorsSample.grey_80,
        ),
      ),
      */
      appBar: AppBar(
        title: const Center(
            child: Text("RCK-RRC WEB RCK-WHALLE-APP 20-02-25 14:30 PM ", textAlign: TextAlign.center)),
        automaticallyImplyLeading: false,
        titleTextStyle: MyTextSample.medium(context).copyWith(
          color: MyColorsSample.grey_80,
        ),
        //title: Text("  RCK-RRC   WEB RCK-WHALLE-APP  ", textAlign: TextAlign.center),
        //titleTextStyle: MyTextSample.medium(context).copyWith(
        //  color: MyColorsSample.grey_80,
        //),
      ),
      body: _buildCardView(context),
      //bottomNavigationBar: _makeBottom(context),
    );
  }

  Widget _buildCardView(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width:  MediaQuery.of(context).size.width,
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
        color: MyColorsSample.white,
        surfaceTintColor: MyColorsSample.white,
        margin: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        // Define how the card's content should be clipped
        clipBehavior: Clip.antiAliasWithSaveLayer,

         child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(left:16, bottom: 16, right: 16, top:16),
                  child:  Image.asset('assets/ic_logo.png',  width: MediaQuery.of(context).size.width /2 , height: MediaQuery.of(context).size.height /5),
                ),
              ),
              Container(
                child: Center(
                  child: SizedBox(
                    height:  MediaQuery.of(context).size.height /5,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginUsuarioRoute()),  // APP WEB
                          );
                        },
                        child: Text(
                          'Ola! Seja bem vindo!.\nToque para efetuar seu login.',
                          style: TextStyle(color: MyColorsSample. rckappOld, fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70, // Text Color
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                  child: Text(
                    '  Sair  ',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black12, // Text Color
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

  bool _showTelaPrincipal() {

    Timer.periodic(
        Duration(seconds: 1), (_) {
      //clickAtivo = !clickAtivo;
      Navigator.pop(context, null);
    });
    return true;

  }

  Widget _makeBottom(BuildContext context) {
    return Container(
      height: 55.0,
      decoration: BoxDecoration(color: MyColorsSample.white),
      child: BottomAppBar(
        color: MyColorsSample.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: <Widget>[


          ],
        ),
      ),
    );
  }


}

class MyColorsSample {
  static const Color rckapp    = Color(0xFF68ACA1);
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