import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide VoidCallback;
import 'package:flutter/services.dart' hide VoidCallback;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_date_difference/flutter_date_difference.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';
import 'package:rck_painel_tarefa/model/web_status_exportacao.dart';
import 'package:rck_painel_tarefa/screens/cliente_dados_consulta_route.dart';
import 'package:rck_painel_tarefa/screens/cliente_tarefa_consulta_route.dart';
import 'package:rck_painel_tarefa/util/Mascaras.dart';
import 'package:universal_html/html.dart' hide VoidCallback;

import '../../api/web_api_exporta.dart';
import '../../model/web_tarefa.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../model/web_analise_arquivo_xml.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../util/DeviceDetector.dart';
import 'package:rck_painel_tarefa/screens/vendedor_consulta_route.dart';
enum OpcaoDialogo { opcaoUm, opcaoDois }
enum CampoOrdenacao { razaoSocial, dadosExportado, dadosErro, onLine }
class PainelTarefasRouteAPI extends StatelessWidget {
  final String tokenUsuario;
  final String  idUsuario;
  const PainelTarefasRouteAPI(
      {super.key, required this.idUsuario, required this.tokenUsuario});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(idUsuario: idUsuario, tokenUsuario: tokenUsuario,);
  }
}

class MyHomePage extends StatefulWidget {
  final String idUsuario;
  final String tokenUsuario;
  const MyHomePage({super.key, required this.idUsuario, required this.tokenUsuario});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String pesquisa = "-";
  late Future<List<WebCliente>> _fWebCliente;
  late Future<List<WebTarefa>> _fWebTarefa;
  late List<WebCliente> listaClientes = [];
  late List<WebTarefa> listaTarefas = [];
  List<WebTarefa> chartData = [];
  late WebTarefa webTarefaDia = WebTarefa(id_tarefa: 0,
      qtde_nao_agendada: 0,
      qtde_agendada: 0,
      qtde_executada: 0,
      qtde_pendente: 0,
      periodo_inicial: "",
      periodo_final: "",
      data_hora_atualizado: "");
  late WebTarefa webTarefaMes = WebTarefa(id_tarefa: 0,
      qtde_nao_agendada: 0,
      qtde_agendada: 0,
      qtde_executada: 0,
      qtde_pendente: 0,
      periodo_inicial: "",
      periodo_final: "",
      data_hora_atualizado: "");
  static const _scrollThreshold = 1.00;
  //late final ScrollController _scrollController;
  int offSet = 0,
      totalReg = 0,
      limiteReg = 21;
  bool isLoading = false;
  bool isobscureText = false;

  //final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
  //final bool isTablet = DeviceDetector.isTablet(MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single));

  var sizeQuery;
  var diagQuert;
  final int typeDevice = DeviceDetector().typeDevice1(MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.single));


  GlobalKey btnMenu = GlobalKey();

  //final List<GlobalObjectKey> keyList = List.generate(20, (index) => GlobalObjectKey(index));
  List<GlobalObjectKey> keyList2 = [
  ]; //List.generate(20, (index) => GlobalObjectKey(index));
  late PopupMenu menu;
  late int idxClicado;
  final _dateDifference = FlutterDateDifference(language: "en");
  final tempoConsultaStatusCliente = Duration(/*seconds: 20*/ minutes: 30);
  final tempoConsultaStatusTarefa = Duration(minutes: 30);
  Timer? _timer;
  //ScrollController scrollController = ScrollController();
  bool consultaTarefaIniciada = false;
  bool consultaTarefaAtiva    = false;

  late final ScrollController _scrollController;
  late Stream<QuerySnapshot> _myStreamCliente;

  List<WebCliente> minhaListaDeClienteEmTempoReal = [];
  StreamSubscription? _listaCliente;


  List<WebStatusApi> minhaListaDeStatusEmTempoReal = [];
  StreamSubscription? _statusApi;


  List<WebStatusExportacao> minhaListaDeExportacaoEmTempoReal = [];
  StreamSubscription? _statusExportacao;



// Defina as possíveis escolhas. Isso evita erros de digitação.

  @override
  void initState() {
    super.initState();
    /*
    if (kIsWeb) {
       FirebaseFirestore.instance.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    }

     */
    //Firebase.initializeApp();

   /* Future.delayed(const Duration(minutes: 2), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(seconds: listaClientes.length * 10),
          curve: Curves.linear);
    });*/

    //_scrollController = ScrollController();
    //_scrollController.addListener(_scrollListener);
    isLoading = false;
    _fWebTarefa = _getWebTarefa();
    _fWebCliente = _getWebCliente("razao_social"/*offSet, limiteReg, false*/);
    offSet = 21;
    //_startConsultaStatusAPI();
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    //_scrollController.dispose();
    _listaCliente?.cancel();
    _statusApi?.cancel();
    _statusExportacao?.cancel();

    super.dispose();
  }

  /// Reordena a lista `_listaClientes` localmente com base no campo fornecido.
  void _ordenarLista(CampoOrdenacao campo, String tipoOrdenacao) {
    if (listaClientes.isEmpty) return; // Não faz nada se a lista estiver vazia
    setState(() {
      // A função de comparação (a, b) é o coração da ordenação.
      // Ela deve retornar:
      //  < 0 se 'a' deve vir antes de 'b'
      //  > 0 se 'a' deve vir depois de 'b'
      //  = 0 se são iguais em ordem
      listaClientes.sort((WebCliente a, WebCliente b) {
        // Usamos um switch para escolher a lógica de comparação
        switch (campo) {
          case CampoOrdenacao.razaoSocial:
            if ( tipoOrdenacao == "D")
              return b.nome_cadastro.toLowerCase().compareTo(a.nome_cadastro.toLowerCase());
            return a.nome_cadastro.toLowerCase().compareTo(b.nome_cadastro.toLowerCase());
          case CampoOrdenacao.dadosErro:
            if ( tipoOrdenacao == "D")
                return b.notas_com_erro.compareTo(a.notas_com_erro);
            return a.notas_com_erro.compareTo(b.notas_com_erro);

            case CampoOrdenacao.dadosExportado:
              if ( tipoOrdenacao == "D")
                return b.exportacao_com_erro.compareTo(a.exportacao_com_erro);
              return a.exportacao_com_erro.compareTo(b.exportacao_com_erro);
          case CampoOrdenacao.onLine:
            if ( tipoOrdenacao == "D")
              return b.data_online.compareTo(a.data_online);
            return b.exportacao_com_erro.compareTo(a.exportacao_com_erro);
          case CampoOrdenacao.onLine:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
      });
    });

    // Opcional: Feedback para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lista ordenada por: ${campo.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }


  Future<List<WebCliente>> _getWebCliente(String ordem) async {
    final webClientes = FirebaseFirestore.instance
        .collection('clientes').orderBy(ordem)
        .withConverter<WebCliente>(
      fromFirestore: (snapshot, _) => WebCliente.fromFirestore(snapshot),
      toFirestore: (webCliente, _) => webCliente.toFirestore(),
    );
    final querySnapshot = await webClientes.get();
    listaClientes.addAll(querySnapshot.docs.map((doc) => doc.data()).toList());
    setState(() {});
    if (listaClientes.isNotEmpty) {
      _atualizarStatusApi();
      _atualizarDadosCliente(ordem);
    }

    return listaClientes;
  }

  Future<void> _atualizarDadosCliente(String ordem) async {
    final stream = _escutarListaCliente(ordem);
    //_listaCliente?.cancel();
    _listaCliente = stream.listen((novaLista) {
      minhaListaDeClienteEmTempoReal = novaLista;
      for (WebCliente webCliente in minhaListaDeClienteEmTempoReal) {
        setState(() {
          final int idx = listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webCliente.cpf_cnpj);
          if (idx != -1) {
            webCliente.webStatusApi        = listaClientes[idx].webStatusApi;
            webCliente.webStatusExportacao = listaClientes[idx].webStatusExportacao;
            listaClientes[idx] = webCliente;
          }
        });
      }
    }, onError: (error) {
      print("Ocorreu um erro no stream: $error");
    });
  }

  Stream<List<WebCliente>> _escutarListaCliente(String ordem) {
    final Query<WebCliente> webClienteRef = FirebaseFirestore.instance
        .collection('clientes').orderBy(ordem)
        .withConverter<WebCliente>(
      fromFirestore: (snapshot, _) => WebCliente.fromFirestore(snapshot),
      toFirestore: (webDadosCliente, _) => webDadosCliente.toFirestore(),
    );

    final Stream<QuerySnapshot<WebCliente>> snapshotStream = webClienteRef.snapshots();
    return snapshotStream.map((querySnapshot) {
      return querySnapshot.docChanges
          .where((change) =>
      change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified)
          .map((change) => change.doc.data()!)
          .toList();
    });
  }

  Future<void> _atualizarStatusApi() async {
    final stream = escutarStatusApi();
    _statusApi = stream.listen((novaLista) {
      minhaListaDeStatusEmTempoReal = novaLista;
      for (WebStatusApi webStatusApi in minhaListaDeStatusEmTempoReal/*querySnapshot.docs.map((doc) => doc.data()).toList()*/) {
        setState(() {
          listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusApi.cnpj)].webStatusApi =
              webStatusApi;
          if ( webStatusApi.qtdeNfeEmitida !=   webStatusApi.qtdeNfeAutorizada || webStatusApi.qtdeNfceEmitida !=   webStatusApi.qtdeNfceAutorizada)  {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusApi.cnpj)].notas_com_erro = "S";
          }
        });
      }

    }, onError: (error) {
      // Tratamento de erro
      print("Ocorreu um erro no stream: $error");
    });
    await _getWebTarefa();
    await _atualizarStatusExportacao();
  }

  Stream<List<WebStatusApi>> escutarStatusApi() {
    final Query<WebStatusApi> webStatusApiRef = FirebaseFirestore.instance
        .collectionGroup('statusapi')
        //.limit(2)
        .withConverter<WebStatusApi>(
      fromFirestore: (snapshot, _) => WebStatusApi.fromFirestore(snapshot),
      toFirestore: (webStatusAPI, _) => webStatusAPI.toFirestore(),
    );

    final Stream<QuerySnapshot<WebStatusApi>> snapshotStream = webStatusApiRef.snapshots();
    return snapshotStream.map((querySnapshot) {
         //return querySnapshot.docs.map((docSnapshot) => docSnapshot.data()).toList();
      return querySnapshot.docChanges
          .where((change) =>
      change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified)
          .map((change) => change.doc.data()!)
          .toList();
    });
  }

  Future<void> _atualizarStatusExportacao() async {
    final stream = escutarStatusExportacao();
    _statusExportacao = stream.listen((novaLista) {
      minhaListaDeExportacaoEmTempoReal = novaLista;
      for (WebStatusExportacao webStatusExportacao in  minhaListaDeExportacaoEmTempoReal) {
        String diaAtual = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString().substring(0,2);
        if (  diaAtual == webStatusExportacao.data_agendamento) {
          WebStatusExportacao webClienteExportacao = listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao;
          if ( webStatusExportacao.sucesso && !webClienteExportacao.sucesso) {
            webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada + 1);
            webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente - 1);
          }
          if ( !webStatusExportacao.sucesso && webClienteExportacao.sucesso) {
            webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada - 1 );
            webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente + 1);
          }
          setState(() {
            _chartSections(webTarefaDia);
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao =
                webStatusExportacao;
          });
        }
        if (  diaAtual != webStatusExportacao.data_agendamento) {
          WebStatusExportacao webClienteExportacao = listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao;
          if ( webStatusExportacao.sucesso && !webClienteExportacao.sucesso) {
            webTarefaMes.qtde_executada = (webTarefaMes.qtde_executada + 1);
            webTarefaMes.qtde_pendente = (webTarefaMes.qtde_pendente - 1);
          }
          if ( !webStatusExportacao.sucesso && webClienteExportacao.sucesso) {
            webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada - 1 );
            webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente + 1);
          }
          setState(() {
            _chartSections(webTarefaMes);
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao =
                webStatusExportacao;
          });
        }
      }
      webTarefaMes.qtde_pendente = webTarefaMes.qtde_agendada - webTarefaMes.qtde_executada;
      webTarefaDia.qtde_pendente = webTarefaDia.qtde_agendada - webTarefaDia.qtde_executada;
    }, onError: (error) {
      // Tratamento de erro
      print("Ocorreu um erro no stream: $error");
    });
    String mesAno = DateFormat('yyyy-MM').format(DateTime.now());
    final webStatusExportacaoErro = FirebaseFirestore.instance
        .collectionGroup('erro-exportacao-dados-invalidos')
        .where('dataHora', isGreaterThanOrEqualTo: mesAno)
        .where('dataHora', isLessThanOrEqualTo: mesAno + '\uf8ff')
        .withConverter<WebStatusExportacao>(
      fromFirestore: (snapshot, _) => WebStatusExportacao.fromFirestore(snapshot),
      toFirestore: (webStatusExportao, _) => webStatusExportao.toFirestore(),
    );
    final querySnapshotErro = await webStatusExportacaoErro.get();
    final listaStatusExportacaoErro = querySnapshotErro.docs.map((doc) => doc.data()).toList();
    for (WebStatusExportacao webStatusExportacao in listaStatusExportacaoErro) {
      if ( listaClientes[listaClientes.indexWhere((item) =>
      item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao.sucesso == false) {
        setState(() {
          _chartSections(webTarefaMes);
          listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao =
              webStatusExportacao;
          listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusExportacao.cnpj)].exportacao_com_erro = "S";
        });
      }
    }
  }

  Stream<List<WebStatusExportacao>> escutarStatusExportacao() {
    String mesAno = DateFormat('yyyy-MM').format(DateTime.now());
    final Query<WebStatusExportacao> webStatusExportacaoRef = FirebaseFirestore.instance
        .collectionGroup('exportacao')
        .where('data_exportacao', isGreaterThanOrEqualTo: mesAno)
        .where('data_exportacao', isLessThanOrEqualTo: mesAno + '\uf8ff')
        //.limit(2)
        .withConverter<WebStatusExportacao>(
      fromFirestore: (snapshot, _) => WebStatusExportacao.fromFirestore(snapshot),
      toFirestore: (webStatusExportacao, _) => webStatusExportacao.toFirestore(),
    );
    final Stream<QuerySnapshot<WebStatusExportacao>> snapshotStream = webStatusExportacaoRef.snapshots();
    return snapshotStream.map((querySnapshot) {
       //return querySnapshot.docs.map((docSnapshot) => docSnapshot.data()).toList();
       return querySnapshot.docChanges
          .where((change) =>
             change.type == DocumentChangeType.added ||
             change.type == DocumentChangeType.modified)
          .map((change) => change.doc.data()!)
          .toList();
    });
  }


  Future<List<WebTarefa>> _getWebTarefa() async {
  int qtdeAgendaDia = 0;
  int qtdeExecutadaDia = 0;
  int qtdeAgendaPeriodo = 0;
  int qtdeExecutadaPeriodo = 0;
  String diaAtual = DateFormat('dd').format(DateTime.now());
  for (WebCliente webCliente in listaClientes) {
    if (webCliente.data_exportacao_1 == diaAtual) {
      qtdeAgendaDia++;
      //webTarefaDia.qtde_agendada = qtdeAgendaDia;
    } else {
      qtdeAgendaPeriodo++;
      //webTarefaMes.qtde_agendada = qtdeAgendaDia;
    }
  }
  if ( listaClientes.length > 0) {
    setState(() {
       webTarefaDia.data_hora_atualizado = DateFormat('dd/MM/yy HH:mm').format(DateTime.now());
       webTarefaDia.qtde_agendada = qtdeAgendaDia;
       webTarefaMes.qtde_agendada = qtdeAgendaPeriodo;
       webTarefaDia.qtde_pendente = qtdeAgendaDia;
       webTarefaMes.qtde_pendente = qtdeAgendaPeriodo;
       listaTarefas.add(webTarefaDia);
       listaTarefas.add(webTarefaMes);
    });
  }
  if ( listaClientes.length > 0) {
    _statusExportacao?.cancel();
    _atualizarStatusExportacao();
  }
  consultaTarefaAtiva = false;
  return listaTarefas;
  }

  /*
  void _startConsultaStatusAPI() {
    _timer = Timer.periodic(tempoConsultaStatusCliente, (Timer timer) {
        offSet+= 3;
        limiteReg = 3;
        if ( !consultaTarefaAtiva) {
          _atualizarStatusApi();
        }
    });
  }
  */

  List<PieChartSectionData> _chartSections(WebTarefa webTarefa) {
    final List<PieChartSectionData> lista = [];
      const double radius = 20.0;
      final dataAgendada = PieChartSectionData(
        color: Colors.orangeAccent,
        value: webTarefa.qtde_agendada.toDouble(),
        radius: radius,
        title: 'A',
      );
    final dataExecutada = PieChartSectionData(
      color: Colors.greenAccent,
      value: webTarefa.qtde_executada.toDouble(),
      radius: radius,
      title: 'E',
    );
    lista.add(dataExecutada);
    final dataPendente = PieChartSectionData(
      color: Colors.deepPurpleAccent,
      value: webTarefa.qtde_pendente.toDouble(),
      radius: radius,
      title: 'P',
    );
    lista.add(dataPendente);
    return lista;
  }

  void _scrollListener() async {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent * _scrollThreshold &&
        !_scrollController.position.outOfRange) {
      if( isLoading)
        return;
      offSet+= 10;
      isLoading = true;
      //await _getWebProduto(offSet, limiteReg, true, widget.idPedido);
      //_atualizarStatusApi();
      isLoading = false;
      setState(() {
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyColorsSample.white,
          shadowColor: MyColorsSample.white,
          surfaceTintColor: MyColorsSample.white,
          //toolbarHeight: 20.0,
          title: Text(
            'Minhas tarefas',
          )),
      drawer: Drawer(
        backgroundColor: MyColorsSample.white,
        shadowColor: MyColorsSample.white,
        surfaceTintColor: MyColorsSample.white,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: MyColorsSample.rckapp,
               ),
               arrowColor: MyColorsSample.white,
              accountEmail: Text("rcksuporte@rcksistemas.com.br"),
              accountName: Text("RCK SISTEMAS ESPECIFICOS"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                //backgroundImage: AssetImage('assets/ic_logo.png', ),
                child: Text("RCK ",
                  style: TextStyle(
                      color: MyColorsSample.rckapp,
                      fontSize: 16),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
              ),
              title: const Text('Página inicial'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person,
              ),
              title: const Text('Clientes'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.people_outline,
              ),
              title: const Text('Vendedores'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendedorConsultaRoute(
                      idUsuario: widget.idUsuario,
                      tokenUsuario: widget.tokenUsuario,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                isobscureText ?  Icons.visibility : Icons.visibility_off
              ),
              title: Text(  isobscureText ?  'Visualizar dados' : 'Ocultar dados' ),
              onTap: () {
                  isobscureText = !isobscureText ;
                  Navigator.pop(context);
                  setState(() {
                  });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
              ),
              title:  Text('Tela ' + DeviceDetector().typeDevice1(MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.single)).toString() + " Tam "
              + DeviceDetector().typeDevice2(MediaQueryData.fromView(
                      WidgetsBinding.instance.platformDispatcher.views.single)).toString()),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
              ),
              title: const Text('Sair'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<WebCliente>>(
        future: _fWebCliente,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: MyColorsSample.white,
              body: OrientationBuilder(
                builder: (context, orientation) {
                  return listContainer2(typeDevice, orientation == Orientation.portrait, kIsWeb);
                },
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: MyColorsSample.rckapp, semanticsLabel: 'Aguarde...',),
            );
          }
        },
      ),
    );
  }

  Card makeSingleLineCard(WebCliente webCliente) {
    // --- Lógica de Status (API, Exportação, Indicador) ---
    // ... (toda a sua lógica de status que já existe permanece aqui, sem alterações)
    // ... (isApiOk, apiColor, isExportOk, exportColor, overallIndicatorColor, etc.)

    // --- Lógica de Status da API ---
    final bool isApiOk = webCliente.webStatusApi.sucesso;
    final IconData apiIcon = isApiOk && isSameDay( webCliente.webStatusApi.dataHora) ? Icons.wifi : Icons.wifi_off;
    final Color apiColor = isApiOk ? Colors.blueAccent : Colors.grey.shade600;
    final String apiStatusText = isApiOk ? "Online" : "Offline";
    final String apiTimeText = webCliente.webStatusApi.dataHora.isNotEmpty
        ? Mascaras().mascaraDataHora(webCliente.webStatusApi.dataHora)/*.substring(11, 16)*/
        : "";

    // --- Lógica de Status da Exportação ---
    final bool isExportOk = webCliente.webStatusExportacao.sucesso;
    final bool hasExportAttempt = webCliente.webStatusExportacao.dataHora.isNotEmpty;
    final bool isOnlineHoje = isSameDay( webCliente.webStatusApi.dataHora) ;
    final bool isOnlineMes = isSameMontYear( webCliente.webStatusApi.dataHora) ;
    IconData exportIcon;
    Color exportColor;
    String exportStatusText;
    String exportDateText;
    String exportMessageText = "";

    if (isExportOk) {
      exportIcon = Icons.check_circle;
      exportColor = Colors.blueAccent;
      exportStatusText = "Sucesso";
      exportDateText = Mascaras().mascaraDataHora(webCliente.webStatusExportacao.dataHora); // Assumindo que você tem um formatador
    } else if (hasExportAttempt) {
      exportIcon = Icons.error;
      exportColor = Colors.red;
      exportStatusText = "Falhou";
      exportDateText = Mascaras().mascaraDataHora(webCliente.webStatusExportacao.dataHora); // Assumindo que você tem um formatador
      exportMessageText = webCliente.webStatusExportacao.mensagem;
    } else {
      exportIcon = Icons.schedule;
      exportColor = Colors.blueGrey;
      exportStatusText = "Pendente";
      exportDateText = "";
      exportMessageText = webCliente.webStatusExportacao.mensagem;
    }

    // --- Lógica do Indicador Geral ---
    Color overallIndicatorColor;
    if (!isApiOk || webCliente.ativo == "N" || webCliente.email_envio_ativo == "N") {
      overallIndicatorColor = Colors.grey.shade600;
    } else if (hasExportAttempt && !isExportOk) {
      overallIndicatorColor = Colors.red;
    } else if (isApiOk && isExportOk) {
      overallIndicatorColor = Colors.green;
    } else {
      overallIndicatorColor = Colors.orange;
    }
    if ( webCliente.ativo == "N" || webCliente.email_envio_ativo == "N") {
      overallIndicatorColor = Colors.grey.shade600;
    }
    if (!isOnlineMes ) {
      webCliente.webStatusApi.qtdeNfeEmitida = 0;
      webCliente.webStatusApi.qtdeNfeAutorizada = 0;
      webCliente.webStatusApi.qtdeNfeContigencia = 0;
      webCliente.webStatusApi.qtdeNfceEmitida = 0;
      webCliente.webStatusApi.qtdeNfceAutorizada = 0;
      webCliente.webStatusApi.qtdeNfceContigencia = 0;
      //webCliente.webStatusApi.qtdeNotaTerceiros
    }
    // Define o tipo de dispositivo (ajuste conforme sua lógica)
    // Vou simular aqui, substitua pela sua variável real `typeDevice`
    //var typeDevice = 2; // Exemplo: 1 para mobile, 2 para tablet/desktop

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: overallIndicatorColor.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        // A estrutura principal agora é uma Coluna
        child: Column(
          children: [
            // --- LINHA 1: INFORMAÇÕES PRINCIPAIS (código que você já tinha) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.circle, color: overallIndicatorColor, size: 12.0),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isobscureText ? '#######${webCliente.id_cadastro}' : webCliente.nome_cadastro,
                        style: MyTextSample.small2(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (webCliente.nome_fantasia.isNotEmpty && !isobscureText)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            webCliente.nome_fantasia,
                            style: MyTextSample.small(context).copyWith(color: MyColorsSample.grey_60, fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (webCliente.cpf_cnpj.isNotEmpty && !isobscureText)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            Mascaras().mascaraCnpj(webCliente.cpf_cnpj),
                            style: MyTextSample.small(context).copyWith(color: MyColorsSample.grey_60, fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),
                Visibility(
                  visible: typeDevice > 2 ? true : false,
                  child:
                Column(
                  // ... Status da API
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        exportMessageText,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          //color: valueColor,
                        ),
                      ),
                    ]
                ),
                ),

                const SizedBox(width: 16),
                Column(
                  // ... Status da API
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(exportIcon, color: exportColor, size: 20),
                      const SizedBox(width: 8.0),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 100), // Duração da animação
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // Efeito: Escala (Pop)
                          return ScaleTransition(child: child, scale: animation);
                        },
                        // A KEY É ESSENCIAL: Sem ela, o AnimatedSwitcher não detecta a mudança
                        child: Text(
                          exportDateText.isEmpty ? "      /      /      :   " : exportDateText,
                          key: ValueKey<String>( exportDateText),
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            //color: valueColor,
                          ),
                        ),
                      ),
                    ]
                ),

                const SizedBox(width: 16),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(apiIcon, color: apiColor, size: 20),
                      const SizedBox(width: 8.0),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 100), // Duração da animação
                        transitionBuilder: (Widget child, Animation<double> animation) {
                        // Efeito: Escala (Pop)
                           return ScaleTransition(child: child, scale: animation);
                        },
                        // A KEY É ESSENCIAL: Sem ela, o AnimatedSwitcher não detecta a mudança
                       child: Text(
                           apiTimeText,
                           key: ValueKey<String>(apiTimeText),
                           style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                             //color: valueColor,
                           ),
                       ),
                      ),
                    ]
                  // ... Status da Exportação
                ),

              ],
            ),

            // --- LINHA 2: STATUS DETALHADOS (código que você forneceu, agora integrado) ---
            Visibility(
              visible: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0), // Espaço entre a linha 1 e 2
                child: Column(
                  children: [
                    //Divider(color: Colors.grey.shade200),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Row(
                             children: <Widget>[
                               Icon(Icons.calendar_month, size: 16, color: MyColorsSample.grey_60),
                               const SizedBox(width: 12),
                               Text(typeDevice > 2 ? "Este mês" : "", style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_80),
                               ),
                            ],
                          ),
                          Visibility(
                             visible: typeDevice > 2 ? true : false,
                             child: _buildStatusField(
                                label: "NF-e Emitidas",
                                value: webCliente.webStatusApi.qtdeNfeEmitida.toString(),
                                valueColor:  webCliente.webStatusApi.qtdeNfeEmitida != webCliente.webStatusApi.qtdeNfeAutorizada
                                   ? Colors.red : MyColorsSample.grey_60,
                             ),
                          ),
                          Visibility(
                              visible: typeDevice > 2 ? true : false,
                              child: _buildStatusField(
                                 label: "NF-e Autorizadas",
                                 value: webCliente.webStatusApi.qtdeNfeAutorizada.toString(),
                                 valueColor:  webCliente.webStatusApi.qtdeNfeEmitida != webCliente.webStatusApi.qtdeNfeAutorizada
                                    ? Colors.red : MyColorsSample.grey_60,
                              ),
                          ),
                          Visibility(
                            visible: typeDevice <= 2 ? true : false,
                            child: _buildStatusField(
                              label: "NF-e Em./Aut.",
                              value: webCliente.webStatusApi.qtdeNfeEmitida.toString() + " / " +webCliente.webStatusApi.qtdeNfeAutorizada.toString(),
                              valueColor:  webCliente.webStatusApi.qtdeNfeEmitida != webCliente.webStatusApi.qtdeNfeAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          ),

                          _buildStatusField(
                            label: "NF-e Conting.",
                            value: webCliente.webStatusApi.qtdeNfeContigencia.toString(),
                            valueColor: webCliente.webStatusApi.qtdeNfeContigencia > 0
                                ? Colors.red : MyColorsSample.grey_60,
                          ),
                          Visibility(
                            visible: typeDevice > 2 ? true : false,
                            child: _buildStatusField(
                              label: "NFC-e Emitidas",
                              value: webCliente.webStatusApi.qtdeNfceEmitida.toString(),
                              valueColor:  webCliente.webStatusApi.qtdeNfceEmitida != webCliente.webStatusApi.qtdeNfceAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          ),
                          Visibility(
                            visible: typeDevice > 2 ? true : false,
                            child: _buildStatusField(
                              label: "NFC-e Autorizadas",
                              value: webCliente.webStatusApi.qtdeNfceAutorizada.toString(),
                              valueColor:  webCliente.webStatusApi.qtdeNfceEmitida != webCliente.webStatusApi.qtdeNfceAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          ),
                          Visibility(
                            visible: typeDevice <= 2 ? true : false,
                            child: _buildStatusField(
                              label: "NFC-e Em./Aut.",
                              value: webCliente.webStatusApi.qtdeNfceEmitida.toString() + " / " +webCliente.webStatusApi.qtdeNfceAutorizada.toString(),
                              valueColor:  webCliente.webStatusApi.qtdeNfceEmitida != webCliente.webStatusApi.qtdeNfceAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          ),

                          _buildStatusField(
                            label: "NFC-e Conting.",
                            value: webCliente.webStatusApi.qtdeNfceContigencia.toString(),
                            valueColor: webCliente.webStatusApi.qtdeNfceContigencia > 0
                                ? Colors.red : MyColorsSample.grey_60,
                          ),
                          //_buildStatusField(
                          //  label: "NFC-e Inut.",
                          //  value: webCliente.webStatusApi.qtdeNfceInutilizada.toString(),

                          //),
                          Visibility(
                             visible: typeDevice > 2 ? true : false,
                             child: _buildStatusField(
                                label: "Seq. NFC-e",
                                value: webCliente.webStatusApi.sequenciaNumericaNFCe ? "OK" : "ERRO",
                                valueColor: webCliente.webStatusApi.sequenciaNumericaNFCe
                                   ? MyColorsSample.grey_60 : Colors.red,
                             ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// <summary>
  /// HELPER: Constrói um campo de status padronizado para a linha de informações fiscais.
  /// </summary>
  ///
  ///
  ///
  Widget _buildStatusField({
    required String label,
    required String value,
    Color valueColor = MyColorsSample.grey_60,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: MyTextSample.small(context).copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: MyTextSample.small(context).copyWith(
              color: MyColorsSample.grey_60,
              fontSize: 10, // Fonte menor para o rótulo
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  Card makeCard(WebCliente webCliente, int pos, int typeDEvice) =>
      Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4.0,
      color: Colors.white,
      surfaceTintColor: webCliente.webStatusApi.sucesso && webCliente.webStatusExportacao.sucesso ? MyColorsSample.rckapp :
      webCliente.webStatusApi.sucesso && (!webCliente.webStatusExportacao.sucesso || webCliente.webStatusExportacao.dataHora.isNotEmpty) ? Colors.red :
      !webCliente.webStatusApi.sucesso && !webCliente.webStatusApi.sucesso ? Colors.red : MyColorsSample.rckapp,
      shadowColor: webCliente.webStatusApi.sucesso && webCliente.webStatusExportacao.sucesso ? MyColorsSample.rckapp :
      webCliente.webStatusApi.sucesso && (!webCliente.webStatusExportacao.sucesso || webCliente.webStatusExportacao.dataHora.isNotEmpty) ? Colors.red :
      !webCliente.webStatusApi.sucesso && !webCliente.webStatusApi.sucesso ? Colors.red : MyColorsSample.rckapp,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(color: MyColorsSample.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (
                                    context) =>
                                    ClienteConsultaTarefasRoute(
                                        idUsuario: widget
                                            .idUsuario,
                                        periodoInicial: "-",
                                        periodoFinal: "-",
                                        idxTipo: 0,
                                        isobscureText: isobscureText,
                                        tokenUsuario: widget
                                            .tokenUsuario,
                                        cnpjCliente: webCliente.cpf_cnpj,)
                            ));
                        //_showToast(context, "Em desenvolvimento " + webCliente.cpf_cnpj, 2);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 0.0, top: 2.00, right: 0, bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: <Widget>[
                                        Row(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                          Expanded(
                                              flex: typeDevice == 1 ? 2 : 3,
                                              child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: <Widget>[
                                                   Card(
                                                       elevation: 0.0,
                                                       color: Colors.white,
                                                       child: TextFormField( textAlign: TextAlign.left,
                                                         controller:  TextEditingController()..text = webCliente.nome_cadastro,
                                                         obscureText: isobscureText,
                                                         style: typeDevice == 1 ? MyTextSample.small2(context).copyWith(
                                                           color: MyColorsSample.grey_80,) : MyTextSample.medium(context).copyWith(
                                                           color: MyColorsSample.grey_80,),
                                                         enabled: false,
                                                         maxLines: 1,
                                                         decoration: InputDecoration(
                                                           labelText: 'Razão social',
                                                           isDense: true,
                                                           border: InputBorder.none,
                                                           labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                         ),
                                                       )),
                                                   Card(
                                                       elevation: 0.0,
                                                       color: Colors.white,
                                                       child: TextFormField( textAlign: TextAlign.left,
                                                           controller:  TextEditingController()..text = webCliente.nome_fantasia,
                                                           obscureText: isobscureText,
                                                           style: typeDevice == 1 ? MyTextSample.small2(context).copyWith(
                                                             color: MyColorsSample.grey_80,) : MyTextSample.medium(context).copyWith(
                                                           color: MyColorsSample.grey_80,),
                                                           enabled: false,
                                                           maxLines: 1,
                                                           decoration: InputDecoration(
                                                               labelText: 'Nome fantasia',
                                                               isDense: true,
                                                               border: InputBorder.none,
                                                               labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                                               contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                           ),
                                                       ),
                                                   ),
                                                   Container(height: 2,)
                                                 ]
                                              )
                                           ),
                                          Container(width: typeDevice <= 2 ? 16 : 36,
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.dataHora == null || webCliente.webStatusApi.dataHora.isEmpty
                                                              ? "-" :
                                                          typeDevice <= 2 ? Mascaras().mascaraData2(webCliente.webStatusApi.dataHora.substring(0,10), "/", 8)
                                                            + " " +  webCliente.webStatusApi.dataHora.substring(11,16) : Mascaras().mascaraData2(webCliente.webStatusApi.dataHora.substring(0,10), "/", 10)
                                                              + " " + webCliente.webStatusApi.dataHora.substring(11),//( _dadosStatus("http://192.168.100.68:725/rckexportaAPI1.0.0") )== true ? "ON LINE" : "OFF LINE",//_dadosStatus("192.168.100.68:725/rckexportaAPI1.0.0") == true ? "ON" : "OFF" ,
                                                          style: typeDEvice == 1 ?  MyTextSample.small2(context).copyWith( color:  MyColorsSample.grey_60 ) :
                                                             MyTextSample.medium(context).copyWith( color:  MyColorsSample.grey_60 /*webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red,*/ ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: typeDevice <= 2 ? "On line " : 'On line em',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                                                          ),
                                                        )),
                                                  ]
                                              )
                                          ),
                                        ]
                                        ),
                                        Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(32),
                                        height: 2.5,
                                        decoration:
                                        BoxDecoration(color: MyColorsSample.grey_1),
                                        margin: new EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0.0),
                                      ),
                                        Container(height: 4,),
                                        Row(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                              Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.data_exportacao_1.isEmpty ? "-" :  webCliente.data_exportacao_1,
                                                          style: typeDevice == 1 ? MyTextSample.small(context).copyWith(
                                                              color: MyColorsSample.grey_60) :
                                                          MyTextSample.medium(context).copyWith(
                                                              color: MyColorsSample.grey_60),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: typeDevice == 1 ? 'Agendada': 'Data agendada',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),
                                                          ),
                                                        )),
                                            ),
                                              Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                              Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.left,
                                                          //initialValue: "100",
                                                          //controller: TextEditingController()..text = webCliente.status_exportacao_1.isEmpty ? "-" : webCliente.status_exportacao_1,
                                                          //controller: TextEditingController()..text = webCliente.webStatusExportacao.cnpj.isEmpty ? "-" : webCliente.webStatusExportacao.sucesso == true ? MascaraUtil()._formataData(webCliente.webStatusExportacao.data_exportacao, "/", 10) + " - " + webCliente.webStatusExportacao.hora_exportacao  : "-",
                                                          controller: TextEditingController()..text =   webCliente.webStatusDadosInvalido.cnpj.isEmpty && webCliente.webStatusErroAddArquivo.cnpj.isEmpty ?
                                                          webCliente.webStatusExportacao.mensagem == null || webCliente.webStatusExportacao.mensagem.isEmpty ?  " " : webCliente.webStatusExportacao.mensagem :
                                                          ( (webCliente.webStatusDadosInvalido  == null ? " " : "ERRO ")
                                                              +  (webCliente.webStatusErroAddArquivo == null ? " " : "ERRO") ),
                                                          style: typeDevice == 1 ? MyTextSample.small(context).copyWith(
                                                              color: MyColorsSample.grey_60) :
                                                          MyTextSample.medium(context).copyWith(
                                                              color: MyColorsSample.grey_60),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: typeDevice == 1 ? 'Status' : 'Status da exportação',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),

                                                          ),
                                                        )),
                                            ),
                                              Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                              Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.left,
                                                          //controller: TextEditingController()..text = webCliente.data_exportacao_2.isEmpty ? "-" : webCliente.data_exportacao_2,
                                                            controller: TextEditingController()..text = webCliente.webStatusExportacao.cnpj.isEmpty ? "-" : webCliente.webStatusExportacao.sucesso == true ? "${Mascaras().mascaraData2(webCliente.webStatusExportacao.data_exportacao, "/", 10)} - ${webCliente.webStatusExportacao.hora_exportacao}"  : "-",
                                                          //initialValue: "1",

                                                          style: typeDevice == 1 ? MyTextSample.small(context).copyWith(
                                                            color: MyColorsSample.grey_60) :
                                                            MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: typeDevice == 1 ? 'Exportação' : 'Data exportação',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),

                                                          ),
                                                        )),
                                            ),
                                              Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            /*Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.status_exportacao_2.isEmpty ? "-" :  webCliente.status_exportacao_2,
                                                          //initialValue: "0",
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Status',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),

                                                          ),
                                                        )),
                                            ),*/
                                           ]
                                        ),
                                        Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(32),
                                        height: 2.5,
                                        decoration:
                                        BoxDecoration(color: MyColorsSample.grey_1),
                                        margin: new EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0.0),
                                      ),
                                        Container(height: 4,),
                                      //DADOS DA NF-e
                                        Visibility(
                                           visible: typeDevice == 1 ? false : true,
                                           child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: <Widget>[
                                                  Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.right,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfeEmitida.toString(),
                                                          style: webCliente.nome_fantasia.isEmpty ? MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ) : MyTextSample.small(context).copyWith(
                                                            color: MyColorsSample.grey_60,),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'NF-e emitidas',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.medium(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),
                                                          ),
                                                        )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child:  Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.right,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfeAutorizada.toString(),
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'NF-e autorizadas',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),

                                                          ),
                                                        )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.right,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfeContigencia.toString(),
                                                          //initialValue: "1",
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: webCliente.webStatusApi.qtdeNfeContigencia <= 0 ? MyColorsSample.grey_60 : Colors.red,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'NF-e em contigência',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: webCliente.webStatusApi.qtdeNfeContigencia > 0 ? Colors.red : MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),
                                                          ),
                                                        )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child:  Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.right,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfeCancelada.toString(),
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'NF-e canceladas',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),
                                                          ),
                                                        )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                                    child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.right,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNotaTerceiros.toString(),
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color:  MyColorsSample.grey_60 ,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'NF-e de terceiros',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),
                                                          ),
                                                        )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child:  Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.center,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.sequenciaNumericaNFe? "OK" :
                                                          "ERRO",
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: webCliente.webStatusApi.sequenciaNumericaNFe ? MyColorsSample.grey_60 : Colors.red,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'NF-e sequencia',
                                                            isDense: true,
                                                            border: InputBorder.none,
                                                            labelStyle: MyTextSample.small2(context).copyWith(
                                                              color: MyColorsSample.grey_60,
                                                            ),
                                                            contentPadding:
                                                            const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 0),
                                                          ),
                                                        )),
                                            ),
                                          ]
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(32),
                                        height: 2.5,
                                        decoration:
                                        BoxDecoration(color: MyColorsSample.grey_1),
                                        margin: new EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0.0),
                                      ),
                                               //DADOS DA NFC-e
                                      Container(height: 4,),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.right,
                                                    controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfceEmitida.toString(),
                                                    style: webCliente.nome_fantasia.isEmpty ? MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ) : MyTextSample.small(context).copyWith(
                                                      color: MyColorsSample.grey_60,),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'NFC-e emitidas',
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      labelStyle: MyTextSample.medium(context).copyWith(
                                                        color: MyColorsSample.grey_60,
                                                      ),
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),
                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child:  Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.right,
                                                    controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfceAutorizada.toString(),
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'NFC-e autorizadas',
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      labelStyle: MyTextSample.small2(context).copyWith(
                                                        color: MyColorsSample.grey_60,
                                                      ),
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),

                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.right,
                                                    controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfceContigencia.toString(),
                                                    //initialValue: "1",
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: webCliente.webStatusApi.qtdeNfceContigencia <= 0 ? MyColorsSample.grey_60 : Colors.red,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'NFC-e em contigência',
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      labelStyle: MyTextSample.small2(context).copyWith(
                                                        color: webCliente.webStatusApi.qtdeNfeContigencia > 0 ? Colors.red : MyColorsSample.grey_60,
                                                      ),
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),
                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child:  Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.right,
                                                    controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNfceCancelada.toString(),
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'NFC-e canceladas',
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      labelStyle: MyTextSample.small2(context).copyWith(
                                                        color: MyColorsSample.grey_60,
                                                      ),
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),
                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.left,
                                                    controller: TextEditingController()..text = ""/*webCliente.webStatusApi.qtdeNotaOutras.toString()*/,
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: webCliente.webStatusApi.qtdeNotaOutras <= 0 ? MyColorsSample.grey_60 : MyColorsSample.grey_60,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: '---',
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      labelStyle: MyTextSample.small2(context).copyWith(
                                                        color: MyColorsSample.grey_60,
                                                      ),
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),
                                                    ),
                                                  )),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(16),
                                              width: 1.7,
                                              decoration:
                                              BoxDecoration(color: MyColorsSample.grey_1),
                                              margin: new EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 4.0),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child:  Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField(
                                                    textAlign: TextAlign.center,
                                                    controller: TextEditingController()..text = webCliente.webStatusApi.sequenciaNumericaNFCe? "OK" : "ERRO",
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: webCliente.webStatusApi.sequenciaNumericaNFCe ? MyColorsSample.grey_60 : Colors.red,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'NFC-e sequencia',
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      labelStyle: MyTextSample.small2(context).copyWith(
                                                        color: MyColorsSample.grey_60,
                                                      ),
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 0),
                                                    ),
                                                  )),
                                            ),
                                          ]
                                      ),
                                               ],
                                            ),
                                        ),
                                     ],
                                  ),
                                ),
                              ],
                           ),
                          )
                        ]
                      )
                    ),
                  ),
                  Container(width: 8,),
                ],
              ),
              //),
            ),
          ],
        ),
      )
  );

  /// <summary>
  /// Constrói a estrutura principal da UI, com cards de resumo visualmente aprimorados
  /// que mantêm toda a informação e interatividade originais, sem os gráficos.
  /// </summary>
  Widget listContainer2(int typeDevice, bool isPortrait, bool kIsWeb) {
    return Column(
      children: <Widget>[
        // ===================================================================
        // 1. SEÇÃO DE RESUMO DE TAREFAS (COM CARDS E INTERATIVIDADE)
        // ===================================================================
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título para a seção.
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  "Resumo das Tarefas " + webTarefaDia.data_hora_atualizado, textAlign: TextAlign.center,
                  style: MyTextSample.subhead(context)
                      ?.copyWith(color: MyColorsSample.grey_80, fontWeight: FontWeight.bold),
                ),
              ),
              // A Row contém os dois cards de resumo.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- CARD DE TAREFAS "HOJE" ---
                  Expanded(
                    child: _buildTaskSummaryCard(
                      title: "Hoje",
                      total: webTarefaDia.qtde_agendada.toString(),
                      emAberto: webTarefaDia.qtde_pendente.toString(),
                      realizadas: webTarefaDia.qtde_executada.toString(),
                      icon: Icons.today,
                      iconColor: Colors.blue.shade700,

                      // Funcionalidades onTap e onLongPress originais PRESERVADAS.
                        onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClienteConsultaTarefasRoute(
                              idUsuario: widget.idUsuario,
                              periodoInicial: "HOJE",
                              periodoFinal: "HOJE",
                              idxTipo: 0,
                              isobscureText: isobscureText,
                              tokenUsuario: widget.tokenUsuario,
                              cnpjCliente: '',
                            ),
                          ),
                        );
                      },
                      periodo: "3",

                    ),
                  ),
                  const SizedBox(width: 12),

                  // --- CARD DE TAREFAS "MÊS" ---
                  Expanded(
                    child: _buildTaskSummaryCard(
                      title: "Este Mês",
                      total: webTarefaMes.qtde_agendada.toString(),
                      emAberto: webTarefaMes.qtde_pendente.toString(),
                      realizadas: webTarefaMes.qtde_executada.toString(),
                      icon: Icons.calendar_month,
                      iconColor: Colors.purple.shade700,
                      // Funcionalidades onTap e onLongPress originais PRESERVADAS.
                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClienteConsultaTarefasRoute(
                              idUsuario: widget.idUsuario,
                              periodoInicial: "MES",
                              periodoFinal: "MES",
                              idxTipo: 0,
                              isobscureText: isobscureText,
                              tokenUsuario: widget.tokenUsuario,
                              cnpjCliente: '',
                            ),
                          ),
                        );
                      },
                      periodo: "3"
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ===================================================================
        // 2. CABEÇALHO E LISTA DE CLIENTES
        // ===================================================================

        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Lista de clientes",
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        //color: valueColor,
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 16),



              const SizedBox(width: 16),
              Column(
                // ... Status da API
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Icon(Icons.arrow_upward_sharp, color: Colors.blueGrey, size: 20),
                    //const SizedBox(width: 8.0),
                    //Icon(Icons.arrow_downward_sharp, color: Colors.blueGrey, size: 20),
                    //const SizedBox(width: 8.0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(42.0, 0.0, 32.0, 0.0),
                      child: Text(
                      "Exportação",
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                        //color: valueColor,
                      ),
                    )),
                    InkWell(
                      onTap: () {
                        _ordenarLista(CampoOrdenacao.dadosExportado, "C");
                      },
                      child: Icon(Icons.arrow_upward_sharp, color: Colors.blueGrey, size: 20),
                    ),
                    const SizedBox(width: 8.0),
                    InkWell(
                      onTap: () {
                        _ordenarLista(CampoOrdenacao.dadosExportado, "D");
                      },
                      child: Icon(Icons.arrow_downward_sharp, color: Colors.blueGrey, size: 20),
                    ),
                  ]
              ),

              const SizedBox(width: 16),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Icon(apiIcon, color: apiColor, size: 20),
                    //const SizedBox(width: 8.0),
                     Padding(
                       padding: const EdgeInsets.fromLTRB(42.0, 0.0, 32.0, 0.0),
                         child: Text("On Line", style: TextStyle(
                             fontSize: 10.0,
                             fontWeight: FontWeight.w600,
                             //color: valueColor,
                            ),
                         )),

                     InkWell(
                        onTap: () {
                          _ordenarLista(CampoOrdenacao.onLine, "C");
                       },
                       child: Icon(Icons.arrow_upward_sharp, color: Colors.blueGrey, size: 20),
                     ),
                     const SizedBox(width: 8.0),
                     InkWell(
                        onTap: () {
                           _ordenarLista(CampoOrdenacao.dadosErro, "D");
                        },
                        child: Icon(Icons.arrow_downward_sharp, color: Colors.blueGrey, size: 20),
                     ),
                     const SizedBox(width: 8.0),


                  ]

                // ... Status da Exportação
              ),

            ],
          ),

          /*child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "",
                style: MyTextSample.body1(context)
                    ?.copyWith(color: MyColorsSample.grey_80, fontWeight: FontWeight.bold),
              ),
              Text(
                "${listaClientes.length} clientes",
                style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_60),
              ),
              Text(
                "${listaClientes.length} clientes",
                style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_60),
              ),
            ],
          ),*/
        ),


        const Divider(height: 0.5, indent: 16, endIndent: 16),

        // A lista de clientes permanece com a mesma lógica.
        Expanded(
          child: ListView.builder(
            //controller: _scrollController,
            itemCount: listaClientes.length,
            padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
            itemBuilder: (context, index) {
              final cliente = listaClientes[index];
              return InkWell(
                onTap: () async {
                  final OpcaoDialogo? resultado =  await mostrarDialogDeEscolha(context: context, titulo: "Clique em uma das opções", cnpj: cliente.cpf_cnpj);
                  if (resultado == OpcaoDialogo.opcaoUm) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClienteConsultaTarefasRoute(
                          idUsuario: widget.idUsuario,
                          periodoInicial: "-",
                          periodoFinal: "-",
                          idxTipo: 0,
                          isobscureText: isobscureText,
                          tokenUsuario: widget.tokenUsuario,
                          cnpjCliente: cliente.cpf_cnpj,
                        ),
                      ),
                    );
                  } else if (resultado == OpcaoDialogo.opcaoDois) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClienteConsultaDadosRoute(

                          cnpjCliente: cliente.cpf_cnpj,
                        ),
                      ),
                    );
                  }
                  /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClienteConsultaTarefasRoute(
                        idUsuario: widget.idUsuario,
                        periodoInicial: "-",
                        periodoFinal: "-",
                        idxTipo: 0,
                        isobscureText: isobscureText,
                        tokenUsuario: widget.tokenUsuario,
                        cnpjCliente: cliente.cpf_cnpj,
                      ),
                    ),
                  );

                   */
                },
                child: makeSingleLineCard(cliente),
              );
            },
          ),
        ),
      ],
    );
  }

  /// <summary>
  /// HELPER: Constrói um Card de Resumo interativo, baseado em texto.
  /// </summary>
  /// <summary>
  /// HELPER: Constrói um Card de Resumo com sub-métricas interativas.
  /// A interatividade principal foi movida do card para as métricas individuais.
  /// </summary>
  Widget _buildTaskSummaryCard({
    required String title,
    required String total,
    required String emAberto,
    required String realizadas,
    required IconData icon,
    required Color iconColor,
    // A ação onLongPress continua no card, mas onTap geral foi removido daqui
    required VoidCallback onLongPress,
    // O período ("HOJE" ou "MES") é necessário para a navegação
    required String periodo,
  }) {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Apenas o onLongPress permanece no card inteiro
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabeçalho do Card
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: MyTextSample.subhead(context)?.copyWith(
                      color: MyColorsSample.grey_80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // 2. Métrica Principal (Total) - Não interativa
              Center(
                child: Column(
                  children: [
                    Text(
                      total,
                      style: MyTextSample.headline(context)
                          ?.copyWith(color: MyColorsSample.grey_90, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Total de Tarefas",
                      style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_60),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Métricas Secundárias INTERATIVAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Para "Abertas", idxTipo = 1 (exemplo)
                  _buildSubMetric("Abertas", emAberto, Colors.blue, () {
                    _navigateToFilteredList(periodo, 3); // 1 = Em Aberto
                  }),
                  // Para "Realizadas", idxTipo = 2 (exemplo)
                  _buildSubMetric("Realizadas", realizadas, Colors.green, () {
                    _navigateToFilteredList(periodo, 2); // 2 = Realizadas
                  }),
                  // Para "Vencidas", idxTipo = 3 (exemplo)

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// 4. Crie este método auxiliar de navegação para evitar repetição de código
  void _navigateToFilteredList(String periodo, int idxTipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteConsultaTarefasRoute(
          idUsuario: widget.idUsuario,
          periodoInicial: periodo,
          periodoFinal: periodo,
          idxTipo: idxTipo, // O filtro dinâmico!
          isobscureText: isobscureText,
          tokenUsuario: widget.tokenUsuario,
          cnpjCliente: '',
        ),
      ),
    );
  }


  /// <summary>
  /// HELPER: Constrói o widget para uma sub-métrica (ex: "Abertas", "Vencidas").
  /// </summary>
  /// <summary>
  /// HELPER: Constrói uma sub-métrica INTERATIVA para o card de resumo.
  /// Agora é envolvido por um InkWell para capturar o onTap.
  /// </summary>
  ///
  Widget _buildSubMetric(String label, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, // Usa o callback passado como parâmetro
      borderRadius: BorderRadius.circular(8.0), // Para um efeito visual mais agradável
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Text(
              value,
              style: MyTextSample.subhead(context)?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: MyTextSample.small(context).copyWith(color: MyColorsSample.grey_60),
            ),
          ],
        ),
      ),
    );
  }


  /// Exibe um dialog de confirmação com visual aprimorado, ícones e animações.
  ///
  /// Retorna um `Future` que completa com o valor de `OpcaoDialogo` correspondente
  /// à escolha do usuário, ou `null` se o dialog for fechado.
  Future<OpcaoDialogo?> mostrarDialogDeEscolha({
  required BuildContext context,
  required String titulo,
  required String cnpj,
  // NOVO PARÂMETRO: Ícone para dar contexto visual.
  // Use ícones como Icons.warning_amber_rounded, Icons.help_outline, etc.
  IconData? icone,
  }) async {
  // Pega as cores do tema atual para um design consistente
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return showDialog<OpcaoDialogo>(
  context: context,
  barrierDismissible: true,
  builder: (BuildContext dialogContext) {
  return AlertDialog(
  // MELHORIA 1: Bordas mais suaves e consistentes com o design moderno
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(8.0),
  ),
  // Remove o padding padrão para ter controle total do conteúdo
  contentPadding: EdgeInsets.zero,
  // Remove a elevação padrão para um look mais "flat"
  elevation: 10,
  shadowColor: Colors.black.withOpacity(0.3),
  backgroundColor: colors.surface,

  // MELHORIA 2: Conteúdo totalmente customizado dentro de um Column
  content: Padding(
  padding: const EdgeInsets.all(24.0),
  child: Column(
  mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço vertical
  children: [
  // MELHORIA 3: Ícone grande e animado no topo
  if (icone != null)
  CircleAvatar(
  radius: 30,
  backgroundColor: colors.primary.withOpacity(0.1),
  child: Icon(
  icone,
  size: 32,
  color: colors.primary,
  ),
  ),
  SizedBox(height: icone != null ? 16 : 0),

  // Título centralizado e com estilo
  Text(
  titulo,
  textAlign: TextAlign.center,
  style: theme.textTheme.titleLarge?.copyWith(
  //fontWeight: FontWeight.bold,
  color: colors.onSurface,
  ),
  ),
  const SizedBox(height: 8),

  // Conteúdo com cor mais suave para não competir com o título

  ],
  ),
  ),

  // MELHORIA 4: Botões estilizados e com espaçamento
  actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
  actionsAlignment: MainAxisAlignment.center,
  actions: <Widget>[
  // Container para os botões, usando Row para ficarem lado a lado
  Row(
  children: [
  // --- BOTÃO OPÇÃO 2 (CANCELAR) ---
  // Expanded para ocupar metade do espaço. Usamos um TextButton para uma ação secundária.
  Expanded(
  child: TextButton(
  style: TextButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 12),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(4),
  ),
  ),
  child: Text(
  "Visualizar cadastro",
  style: const TextStyle(fontWeight: FontWeight.bold,  color: Colors.black),
  ),
  onPressed: () => Navigator.of(dialogContext).pop(OpcaoDialogo.opcaoDois),
  ),
  ),
  const SizedBox(width: 48),

  // --- BOTÃO OPÇÃO 1 (CONFIRMAR) ---
  // Expanded com ElevatedButton para destacar a ação principal.
  Expanded(
  child: ElevatedButton(
  style: ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 12),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(4),
  ),
  elevation: 2,
  ),
  child: Text(
  "Visualizar tarefa",
  style: const TextStyle(fontWeight: FontWeight.bold , color: Colors.black),
  ),
  onPressed: () => Navigator.of(dialogContext).pop(OpcaoDialogo.opcaoUm),
  ),
  ),
  ],
  ),
  ],
  )
  // MELHORIA 5: Animação de entrada (fade in + scale)
      .animate()
      .fadeIn(duration: 200.ms)
      .scale(
  begin: const Offset(0.9, 0.9),
  duration: 200.ms,
  curve: Curves.easeOutCubic,
  );
  },
  );
  }

  /*
  Container listContainer(int typeDevice, bool isPortrait, bool isWeb) => Container(
     child: Card(
         shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(4),
      ),
      elevation: 00.0,
      color: Colors.white,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        decoration: BoxDecoration(color: MyColorsSample.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
              Expanded(flex: 1,
                  child: Card(
                      elevation: 2.0,
                      color: Colors.white,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                          decoration: BoxDecoration(color: MyColorsSample.white),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Visibility(
                                   visible: typeDevice <= 2 ? false : true,
                                   child: Expanded(flex: 1,
                                     child: SingleChildScrollView(
                                       child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Card(
                                                elevation:
                                                0.0,
                                                color: Colors
                                                    .white,
                                                child:
                                                TextFormField(
                                                  textAlign:
                                                  TextAlign.center,
                                                  controller: TextEditingController()
                                                    ..text =
                                                        webTarefaDia.data_hora_atualizado,
                                                  style:
                                                  MyTextSample.medium3(context).copyWith(color: MyColorsSample.grey_80),
                                                  enabled:
                                                  false,
                                                  maxLines:
                                                  1,
                                                  decoration:
                                                  InputDecoration(
                                                    label:
                                                    const Center(
                                                      child: Text('Periodo',
                                                          textAlign: TextAlign.center),
                                                    ),
                                                    alignLabelWithHint:
                                                    true,
                                                    isDense:
                                                    true,
                                                    border:
                                                    InputBorder.none,
                                                    labelStyle:
                                                    MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ),
                                                  ),
                                                )),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(flex: 1,
                                                  child: InkWell(
                                                      onTap: () async {
                                                        if (webTarefaDia
                                                            .qtde_agendada >
                                                            0) {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      ClienteConsultaTarefasRoute(
                                                                          idUsuario: widget
                                                                              .idUsuario,
                                                                          periodoInicial: webTarefaDia
                                                                              .periodo_inicial,
                                                                          periodoFinal: "-",
                                                                          idxTipo: 1,
                                                                          isobscureText: isobscureText,
                                                                          tokenUsuario: widget
                                                                              .tokenUsuario, cnpjCliente: "-",)
                                                              ));
                                                        }  else {
                                                          _showToast(context, "Nenhuma tarefa agendada na data atual", 3);
                                                        }
                                                      },
                                                    /*onTap: () async {
                                                      _showToast(context, "Consultar titulos agendados no periodo!!", 4);
                                                    },*/
                                                      child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[
                                                      Container(
                                                        height: 8.0,
                                                        alignment: Alignment.center,
                                                        margin: new EdgeInsets.fromLTRB(  40.0, 8.0,  40.0, 2.0),
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            gradient: LinearGradient(
                                                                colors: [
                                                                   Colors.orangeAccent,
                                                                   Colors.orangeAccent,
                                                                ],
                                                                begin: Alignment.centerLeft,
                                                                end: Alignment.centerRight,
                                                            ),
                                                         ),
                                                      ),
                                                     Card(
                                                                        elevation:
                                                                            0.0,
                                                                        color: Colors
                                                                            .white,
                                                                        child:
                                                                            TextFormField(
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          controller: TextEditingController()
                                                                            ..text =
                                                                                webTarefaDia.qtde_agendada.toString(),
                                                                          style:
                                                                              MyTextSample.large2(context).copyWith(color: MyColorsSample.grey_80),
                                                                          enabled:
                                                                              false,
                                                                          maxLines:
                                                                              1,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            label:
                                                                                const Center(
                                                                              child: Text("Tarefas agendadas",
                                                                                  textAlign: TextAlign.center),
                                                                            ),
                                                                            alignLabelWithHint:
                                                                                true,
                                                                            isDense:
                                                                                true,
                                                                            border:
                                                                                InputBorder.none,
                                                                            labelStyle:
                                                                                MyTextSample.large1(context).copyWith(
                                                                              color: MyColorsSample.grey_60,
                                                                            ),
                                                                          ),
                                                                        )),
                                                   ],
                                                )
                                             ),
                                           ),
                                                Expanded(flex: 1,
                                                   child: InkWell(
                                                     onTap: () async {
                                                       if (webTarefaDia
                                                           .qtde_executada >
                                                           0) {
                                                         Navigator.push(
                                                             context,
                                                             MaterialPageRoute(
                                                                 builder: (
                                                                     context) =>
                                                                     ClienteConsultaTarefasRoute(
                                                                         idUsuario: widget
                                                                             .idUsuario,
                                                                         periodoInicial: webTarefaDia
                                                                             .periodo_inicial,
                                                                         periodoFinal: "-",
                                                                         idxTipo: 2,
                                                                         isobscureText: isobscureText,
                                                                         tokenUsuario: widget
                                                                             .tokenUsuario,
                                                                         cnpjCliente: "-")
                                                             ));
                                                       }  else {
                                                         _showToast(context, "Nenhuma tarefa executada na data atual", 3);
                                                       }
                                                     },
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                      Container(
                                                   height: 8.0,
                                                   alignment: Alignment.center,
                                                   margin: new EdgeInsets.fromLTRB(  40.0, 8.0,  40.0, 2.0),
                                                   decoration: BoxDecoration(
                                                     color: Colors.grey,
                                                     gradient: LinearGradient(
                                                       colors: [
                                                         Colors.greenAccent,
                                                         Colors.greenAccent,
                                                       ],
                                                       begin: Alignment.centerLeft,
                                                       end: Alignment.centerRight,
                                                     ),
                                                   ),
                                                 ),
                                                 Card(
                                                     elevation: 0.0,
                                                     color: Colors.white,
                                                     child: TextFormField( textAlign: TextAlign.center,
                                                       controller:  TextEditingController()..text = webTarefaDia.qtde_executada.toString(),
                                                       style: MyTextSample.large2(context).copyWith(color: MyColorsSample.grey_80),
                                                       enabled: false,
                                                       maxLines: 1,
                                                       decoration: InputDecoration(
                                                         label: const Center(
                                                           child: Text("Tarefas executadas",
                                                               textAlign: TextAlign.center),
                                                         ),
                                                         alignLabelWithHint: true,
                                                         isDense: true,
                                                         border: InputBorder.none,
                                                         labelStyle: MyTextSample.large1(context).copyWith(
                                                           color: MyColorsSample.grey_60,
                                                         ),
                                                       ),
                                                     )),

                                               ],
                                             ),
                                               )
                                           ),
                                                Expanded(flex: 1,
                                                   child: InkWell(
                                                     onTap: () async {
                                                       if (webTarefaDia
                                                           .qtde_pendente >
                                                           0) {
                                                         Navigator.push(
                                                             context,
                                                             MaterialPageRoute(
                                                                 builder: (
                                                                     context) =>
                                                                     ClienteConsultaTarefasRoute(
                                                                         idUsuario: widget
                                                                             .idUsuario,
                                                                         periodoInicial: webTarefaDia
                                                                             .periodo_inicial,
                                                                         periodoFinal: "-",
                                                                         idxTipo: 3,
                                                                         isobscureText: isobscureText,
                                                                         tokenUsuario: widget
                                                                             .tokenUsuario,
                                                                         cnpjCliente: "-")
                                                             ));
                                                       }  else {
                                                         _showToast(context, "Nenhuma tarefa agendada na data atual", 3);
                                                       }
                                                     },
                                                     child: Column(
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                            Container(
                                                   height: 8.0,
                                                   alignment: Alignment.center,
                                                   margin: new EdgeInsets.fromLTRB(  40.0, 8.0,  40.0, 2.0),
                                                   //horizontal: 32.0, vertical: 2.0),
                                                   decoration: BoxDecoration(
                                                     color: Colors.grey,
                                                     gradient: LinearGradient(
                                                       colors: [
                                                         Colors.deepPurpleAccent,
                                                         Colors.deepPurpleAccent,
                                                       ],
                                                       begin: Alignment.centerLeft,
                                                       end: Alignment.centerRight,
                                                     ),
                                                   ),
                                                 ),
                                                            Card(
                                                     elevation: 0.0,
                                                     color: Colors.white,
                                                     child: TextFormField( textAlign: TextAlign.center,
                                                       controller:  TextEditingController()..text = webTarefaDia.qtde_pendente.toString(),
                                                       style: MyTextSample.large2(context).copyWith(color: MyColorsSample.grey_80),
                                                       enabled: false,
                                                       maxLines: 1,
                                                       decoration: InputDecoration(
                                                         label: const Center(
                                                           child: Text("Tarefas pendentes",
                                                               textAlign: TextAlign.center),
                                                         ),
                                                         alignLabelWithHint: true,
                                                         isDense: true,
                                                         border: InputBorder.none,
                                                         labelStyle: MyTextSample.large1(context).copyWith(
                                                           color: MyColorsSample.grey_60,
                                                         ),
                                                       ),
                                                     )),
                                                        ],
                                                     ),
                                                   )
                                                ),
                                                Expanded(
                                                   flex: 1,
                                                    child: Column(
                                                       crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[

                                                          Padding(
                                                        padding: const EdgeInsets.fromLTRB(0.0,4,0.00,0),
                                                        child: AspectRatio(
                                                           aspectRatio: 3.5,
                                                           child: PieChart(PieChartData(
                                                             centerSpaceColor: Colors.white38,
                                                             startDegreeOffset: 120,
                                                             sectionsSpace: .5,
                                                             borderData: FlBorderData(show: true,),
                                                             sections: _chartSections(webTarefaDia),
                                                           )
                                                        ))
                                                     )
                                                       ]
                                                    )
                                                )
                                             ]
                                            ),
                                            Card(
                                                elevation:
                                                0.0,
                                                color: Colors
                                                    .white,
                                                child:
                                                TextFormField(
                                                  textAlign:
                                                  TextAlign.center,
                                                  controller: TextEditingController()
                                                    ..text = ""
                                                        /*webTarefaDia.data_hora_atualizado.substring(3, 10)*/,
                                                  style:
                                                  MyTextSample.medium3(context).copyWith(color: MyColorsSample.grey_80),
                                                  enabled:
                                                  false,
                                                  maxLines:
                                                  1,
                                                  decoration:
                                                  InputDecoration(
                                                    label:
                                                    const Center(
                                                      child: Text(''),
                                                    ),
                                                    alignLabelWithHint:
                                                    true,
                                                    isDense:
                                                    true,
                                                    border:
                                                    InputBorder.none,
                                                    labelStyle:
                                                    MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ),
                                                  ),
                                                )),
                                            Row(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(flex: 1,
                                               child: InkWell(
                                                 //onTap: () async {
                                                 //  _showToast(context, "Consultar titulos agendados no peridodo!!", 4);
                                                 //},
                                                 onTap: () async {
                                                     if (webTarefaMes
                                                         .qtde_agendada >
                                                         0) {
                                                       Navigator.push(
                                                           context,
                                                           MaterialPageRoute(
                                                               builder: (
                                                                   context) =>
                                                                   ClienteConsultaTarefasRoute(
                                                                       idUsuario: widget
                                                                           .idUsuario,
                                                                       periodoInicial: "-",
                                                                       periodoFinal: "-",
                                                                       idxTipo: 4,
                                                                       isobscureText: isobscureText,
                                                                       tokenUsuario: widget
                                                                           .tokenUsuario,
                                                                       cnpjCliente: "-")
                                                           ));
                                                     }  else {
                                                       _showToast(context, "Nenhuma tarefa agendada no periodo/mês atual", 3);
                                                     }
                                                 },
                                                 child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[
                                                     Container(
                                                  height: 3.0,
                                                  alignment: Alignment.center,
                                                  margin: new EdgeInsets.fromLTRB(  64.0, 8.0,  64.0, 2.0),
                                                  decoration: BoxDecoration(
                                                     color: Colors.grey,
                                                     gradient: LinearGradient(
                                                       colors: [
                                                         Colors.orangeAccent,
                                                         Colors.orangeAccent,
                                                       ],
                                                       begin: Alignment.centerLeft,
                                                       end: Alignment.centerRight,
                                                     ),
                                                  ),
                                               ),
                                                     Card(
                                                  elevation: 0.0,
                                                  color: Colors.white,
                                                  child: TextFormField( textAlign: TextAlign.center,
                                                    controller:  TextEditingController()..text = webTarefaMes.qtde_agendada.toString(),
                                                    style: MyTextSample.large(context).copyWith(color: MyColorsSample.grey_60),
                                                    enabled: false,
                                                     maxLines: 1,
                                                     decoration: InputDecoration(
                                                        label: const Center(
                                                            child: Text("Tarefas agendadas"),
                                                        ),
                                                        alignLabelWithHint: true,
                                                        isDense: true,
                                                        border: InputBorder.none,
                                                        labelStyle: MyTextSample.large(context).copyWith(
                                                           color: MyColorsSample.grey_60,
                                                       ),
                                                     ),
                                                  )
                                               ),
                                                   ],
                                                 ),
                                               ),
                                           ),
                                                Expanded(flex: 1,
                                               child: InkWell(
                                                 onTap: () async {
                                                   if (webTarefaMes
                                                       .qtde_executada >
                                                       0) {
                                                     Navigator.push(
                                                         context,
                                                         MaterialPageRoute(
                                                             builder: (
                                                                 context) =>
                                                                 ClienteConsultaTarefasRoute(
                                                                     idUsuario: widget
                                                                         .idUsuario,
                                                                     periodoInicial: "-",
                                                                     periodoFinal: "-",
                                                                     idxTipo: 5,
                                                                     isobscureText: isobscureText,
                                                                     tokenUsuario: widget
                                                                         .tokenUsuario,
                                                                     cnpjCliente: "-")
                                                         ));
                                                   }  else {
                                                     _showToast(context, "Nenhuma tarefa executada no periodo/mês atual", 3);
                                                   }
                                                 },
                                                 child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Container(
                                                          height: 3.0,
                                                          alignment: Alignment.center,
                                                          margin: new EdgeInsets.fromLTRB(  64.0, 8.0,  64.0, 2.0),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.greenAccent,
                                                                Colors.greenAccent,
                                                              ],
                                                              begin: Alignment.centerLeft,
                                                              end: Alignment.centerRight,
                                                            ),
                                                          ),
                                                        ),
                                                        Card(
                                                            elevation: 0.0,
                                                            color: Colors.white,
                                                            child: TextFormField( textAlign: TextAlign.center,
                                                              controller:  TextEditingController()..text = webTarefaMes.qtde_executada.toString(),
                                                              style: MyTextSample.large(context).copyWith(color: MyColorsSample.grey_60),
                                                              enabled: false,
                                                              maxLines: 1,
                                                              decoration: InputDecoration(
                                                                label: const Center(
                                                                  child: Text("Tarefas executadas"),
                                                                ),
                                                                alignLabelWithHint: true,
                                                                isDense: true,
                                                                border: InputBorder.none,
                                                                labelStyle: MyTextSample.large(context).copyWith(
                                                                  color: MyColorsSample.grey_60,
                                                                ),
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                               )
                                           ),
                                                Expanded(flex: 1, child: InkWell(
                                                    onTap: () async {
                                                      if (webTarefaMes
                                                          .qtde_pendente >
                                                          0) {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (
                                                                    context) =>
                                                                    ClienteConsultaTarefasRoute(
                                                                        idUsuario: widget
                                                                            .idUsuario,
                                                                        periodoInicial: "-",
                                                                        periodoFinal: "-",
                                                                        idxTipo: 6,
                                                                        isobscureText: isobscureText,
                                                                        tokenUsuario: widget
                                                                            .tokenUsuario,
                                                                        cnpjCliente: "-")
                                                            ));
                                                      }  else {
                                                        _showToast(context, "Nenhuma tarefa pendente no periodo/mês atual", 3);
                                                      }
                                                    },
                                                 child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[
                                                      Container(
                                                          height: 3.0,
                                                          alignment: Alignment.center,
                                                          margin: new EdgeInsets.fromLTRB(  64.0, 8.0,  64.0, 2.0),
                                                          //horizontal: 32.0, vertical: 2.0),
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.deepPurpleAccent,
                                                                Colors.deepPurpleAccent,
                                                              ],
                                                              begin: Alignment.centerLeft,
                                                              end: Alignment.centerRight,
                                                            ),
                                                          ),
                                                        ),
                                                      Card(
                                                            elevation: 0.0,
                                                            color: Colors.white,
                                                            child: TextFormField( textAlign: TextAlign.center,
                                                              controller:  TextEditingController()..text = webTarefaMes.qtde_pendente.toString(),
                                                              style: MyTextSample.large(context).copyWith(color: MyColorsSample.grey_60),
                                                              enabled: false,
                                                              maxLines: 1,
                                                              decoration: InputDecoration(
                                                                label: const Center(
                                                                  child: Text("Tarefas pendentes"),
                                                                ),
                                                                alignLabelWithHint: true,
                                                                isDense: true,
                                                                border: InputBorder.none,
                                                                labelStyle: MyTextSample.large(context).copyWith(
                                                                  color: MyColorsSample.grey_60,
                                                                ),
                                                              ),
                                                            )),
                                                   ],
                                                 )
                                              )),
                                                Expanded(
                                              flex: 1,
                                               child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[

                                                     Padding(
                                                          padding:
                                                          const EdgeInsets.fromLTRB(0.0, 4, 0.00, 0),
                                                          child: AspectRatio(aspectRatio: 4,
                                                              child: PieChart(
                                                                 PieChartData( centerSpaceColor: Colors.white38,
                                                                    startDegreeOffset: 120,
                                                                    sectionsSpace: .5,
                                                                    borderData:FlBorderData(show: true,),
                                                                    sections: _chartSections(webTarefaMes),
                                                              ))))
                                                   ]
                                               )
                                              )
                                             ]
                                            )
                                         ]
                                       )
                                     )
                                   )
                                ),
                                Visibility(
                                    visible: typeDevice <= 2 ? true : false,
                                    child: Expanded(flex: 1,
                                      child: SingleChildScrollView(
                                       child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Card(
                                                elevation:
                                                0.0,
                                                color: Colors
                                                    .white,
                                                child:
                                                TextFormField(
                                                  textAlign:
                                                  TextAlign.center,
                                                  controller: TextEditingController()
                                                    ..text =
                                                        webTarefaDia.data_hora_atualizado,
                                                  style:
                                                  MyTextSample.medium(context).copyWith(color: MyColorsSample.grey_80),
                                                  enabled:
                                                  false,
                                                  maxLines:
                                                  1,
                                                  decoration:
                                                  InputDecoration(
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                    label:
                                                    const Center(
                                                      child: Text('',
                                                          textAlign: TextAlign.center),
                                                    ),
                                                    alignLabelWithHint:
                                                    true,
                                                    isDense:
                                                    true,
                                                    border:
                                                    InputBorder.none,
                                                    labelStyle:
                                                    MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ),
                                                  ),
                                                )),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(flex: 1,
                                                    child: InkWell(
                                                        onTap: () async {
                                                          if (webTarefaDia
                                                              .qtde_agendada >
                                                              0) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        ClienteConsultaTarefasRoute(
                                                                            idUsuario: widget
                                                                                .idUsuario,
                                                                            periodoInicial: webTarefaDia
                                                                                .periodo_inicial,
                                                                            periodoFinal: "-",
                                                                            idxTipo: 1,
                                                                            isobscureText: isobscureText,
                                                                            tokenUsuario: widget
                                                                                .tokenUsuario,
                                                                            cnpjCliente: "-")
                                                                ));
                                                          }  else {
                                                            _showToast(context, "Nenhuma tarefa agendada na data atual", 3);
                                                          }
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              height: typeDevice == 1 ? 6.0 : 8.0,
                                                              alignment: Alignment.center,
                                                              margin: new EdgeInsets.fromLTRB(  10.0, 4.0,  10.0, 2.0),
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey,
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Colors.orangeAccent,
                                                                    Colors.orangeAccent,
                                                                  ],
                                                                  begin: Alignment.centerLeft,
                                                                  end: Alignment.centerRight,
                                                                ),
                                                              ),
                                                            ),
                                                            Card(
                                                                elevation:
                                                                0.0,
                                                                color: Colors
                                                                    .white,
                                                                child:
                                                                TextFormField(
                                                                  textAlign:
                                                                  TextAlign.center,
                                                                  controller: TextEditingController()
                                                                    ..text =
                                                                    webTarefaDia.qtde_agendada.toString(),
                                                                  style:
                                                                  typeDevice == 1 ? MyTextSample.medium4(context).copyWith(color: MyColorsSample.grey_80): MyTextSample.large(context).copyWith(color: MyColorsSample.grey_80),
                                                                  enabled:
                                                                  false,
                                                                  maxLines:
                                                                  1,
                                                                  decoration:
                                                                  InputDecoration(
                                                                    label:
                                                                    const Center(
                                                                      child: Text("Agendadas",
                                                                              textAlign: TextAlign.center),
                                                                    ),
                                                                    alignLabelWithHint:
                                                                    true,
                                                                    isDense:
                                                                    true,
                                                                    border:
                                                                    InputBorder.none,
                                                                    labelStyle: typeDevice == 1 ? MyTextSample.medium3(context).copyWith(
                                                                    color: MyColorsSample.grey_60, ) : MyTextSample.medium4(context).copyWith(
                                                                      color: MyColorsSample.grey_60,
                                                                    )
                                                                  ),
                                                                )),
                                                          ],
                                                        )
                                                    ),
                                                  ),
                                                  Expanded(flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (webTarefaDia
                                                              .qtde_executada >
                                                              0) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        ClienteConsultaTarefasRoute(
                                                                            idUsuario: widget
                                                                                .idUsuario,
                                                                            periodoInicial: webTarefaDia
                                                                                .periodo_inicial,
                                                                            periodoFinal: "-",
                                                                            idxTipo: 2,
                                                                            isobscureText: isobscureText,
                                                                            tokenUsuario: widget
                                                                                .tokenUsuario,
                                                                            cnpjCliente: "-")
                                                                ));
                                                          }  else {
                                                            _showToast(context, "Nenhuma tarefa executada na data atual", 3);
                                                          }
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              height: typeDevice == 1 ? 6.0 : 8.0,
                                                              alignment: Alignment.center,
                                                              margin: new EdgeInsets.fromLTRB(  10.0, 4.0,  10.0, 2.0),
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey,
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Colors.greenAccent,
                                                                    Colors.greenAccent,
                                                                  ],
                                                                  begin: Alignment.centerLeft,
                                                                  end: Alignment.centerRight,
                                                                ),
                                                              ),
                                                            ),
                                                            Card(
                                                                elevation: 0.0,
                                                                color: Colors.white,
                                                                child: TextFormField( textAlign: TextAlign.center,
                                                                  controller:  TextEditingController()..text = webTarefaDia.qtde_executada.toString(),
                                                                  style: typeDevice == 1 ? MyTextSample.medium4(context).copyWith(color: MyColorsSample.grey_80) : MyTextSample.large(context).copyWith(color: MyColorsSample.grey_80),
                                                                  enabled: false,
                                                                  maxLines: 1,
                                                                  decoration: InputDecoration(
                                                                    label: const Center(
                                                                      child: Text("Executadas",
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    alignLabelWithHint: true,
                                                                    isDense: true,
                                                                    border: InputBorder.none,
                                                                    labelStyle: typeDevice == 1 ? MyTextSample.medium3(context).copyWith(
                                                                    color: MyColorsSample.grey_60,
                                                                  ): MyTextSample.medium4(context).copyWith(
                                                                      color: MyColorsSample.grey_60,
                                                                    ),
                                                                  ),
                                                                )),

                                                          ],
                                                        ),
                                                      )
                                                  ),
                                                  Expanded(flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                           if (webTarefaDia
                                                              .qtde_pendente >
                                                              0) {
                                                              Navigator.push(
                                                                 context,
                                                                 MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        ClienteConsultaTarefasRoute(
                                                                            idUsuario: widget
                                                                                .idUsuario,
                                                                            periodoInicial: webTarefaDia
                                                                                .periodo_inicial,
                                                                            periodoFinal: "-",
                                                                            idxTipo: 3,
                                                                            isobscureText: isobscureText,
                                                                            tokenUsuario: widget
                                                                                .tokenUsuario,
                                                                            cnpjCliente: "-")
                                                                 ));
                                                          }  else {
                                                             _showToast(context, "Nenhuma tarefa pendente na data atual", 3);
                                                           }
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              height: typeDevice == 1 ? 6.0 : 8.0,
                                                              alignment: Alignment.center,
                                                              margin: new EdgeInsets.fromLTRB(  10.0, 4.0,  10.0, 2.0),
                                                              //horizontal: 32.0, vertical: 2.0),
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey,
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Colors.deepPurpleAccent,
                                                                    Colors.deepPurpleAccent,
                                                                  ],
                                                                  begin: Alignment.centerLeft,
                                                                  end: Alignment.centerRight,
                                                                ),
                                                              ),
                                                            ),
                                                            Card(
                                                                elevation: 0.0,
                                                                color: Colors.white,
                                                                child: TextFormField( textAlign: TextAlign.center,
                                                                  controller:  TextEditingController()..text = webTarefaDia.qtde_pendente.toString(),
                                                                  style: typeDevice == 1 ? MyTextSample.medium4(context).copyWith(color: MyColorsSample.grey_80) : MyTextSample.large(context).copyWith(color: MyColorsSample.grey_80),
                                                                  enabled: false,
                                                                  maxLines: 1,
                                                                  decoration: InputDecoration(
                                                                    label: const Center(
                                                                      child: Text("Pendentes",
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    alignLabelWithHint: true,
                                                                    isDense: true,
                                                                    border: InputBorder.none,
                                                                    labelStyle: typeDevice == 1 ? MyTextSample.medium3(context).copyWith(
                                                                      color: MyColorsSample.grey_60,
                                                                    ) : MyTextSample.medium4(context).copyWith(
                                                                      color: MyColorsSample.grey_60,
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      )
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[

                                                            Padding(
                                                                padding: const EdgeInsets.fromLTRB(0.0,4,0.00,0),
                                                                child: AspectRatio(
                                                                    aspectRatio: typeDevice == 1 ? 1.5 : 2.5,
                                                                    child: PieChart(PieChartData(
                                                                      centerSpaceColor: Colors.white38,
                                                                      startDegreeOffset: typeDevice == 1 ? 80 :  60,
                                                                      sectionsSpace: typeDevice == 1 ? .9 : .3,
                                                                      borderData: FlBorderData(show: true,),
                                                                      sections: _chartSections(webTarefaDia),
                                                                    )
                                                                    ))
                                                            )
                                                          ]
                                                      )
                                                  )
                                                ]
                                             ),
                                            Container(height: 0,),
                                            Card(
                                                elevation:
                                                0.0,
                                                color: Colors
                                                    .white,
                                                child:
                                                TextFormField(
                                                  textAlign:
                                                  TextAlign.center,
                                                  controller: TextEditingController()
                                                    ..text =
                                                        MascaraUtil()._formataMesAno(webTarefaMes.periodo_inicial, "/", 10) ,
                                                  style:
                                                  MyTextSample.medium(context).copyWith(color: MyColorsSample.grey_80),
                                                  enabled:
                                                  false,
                                                  maxLines:
                                                  1,
                                                  decoration:
                                                  InputDecoration(
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                    label:
                                                    const Center(
                                                      child: Text(''),
                                                    ),
                                                    alignLabelWithHint:
                                                    true,
                                                    isDense:
                                                    true,
                                                    border:
                                                    InputBorder.none,
                                                    labelStyle:
                                                    MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60,
                                                    ),
                                                  ),
                                                )),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(flex: 1,
                                                    child: InkWell(
                                                        onTap: () async {
                                                          if (webTarefaMes
                                                              .qtde_agendada >
                                                              0) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        ClienteConsultaTarefasRoute(
                                                                            idUsuario: widget
                                                                                .idUsuario,
                                                                            periodoInicial: "-",
                                                                            periodoFinal: "-",
                                                                            idxTipo: 4,
                                                                            isobscureText: isobscureText,
                                                                            tokenUsuario: widget
                                                                                .tokenUsuario,
                                                                            cnpjCliente: "-")
                                                                ));
                                                          } else {
                                                            _showToast(context,
                                                                "Nenhuma tarefa agendada no periodo/mês atual",
                                                                3);
                                                          }
                                                        },
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Container(
                                                            height: typeDevice == 1 ? 2.0 : 3.0,
                                                            alignment: Alignment.center,
                                                            margin: new EdgeInsets.fromLTRB(  24.0, 4.0,  24.0, 2.0),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey,
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Colors.orangeAccent,
                                                                  Colors.orangeAccent,
                                                                ],
                                                                begin: Alignment.centerLeft,
                                                                end: Alignment.centerRight,
                                                              ),
                                                            ),
                                                          ),
                                                          Card(
                                                              elevation: 0.0,
                                                              color: Colors.white,
                                                              child: TextFormField( textAlign: TextAlign.center,
                                                                controller:  TextEditingController()..text = webTarefaMes.qtde_agendada.toString(),
                                                                style: MyTextSample.medium4(context).copyWith(color: MyColorsSample.grey_60),
                                                                enabled: false,
                                                                maxLines: 1,
                                                                decoration: InputDecoration(
                                                                  label: const Center(
                                                                    child: Text("Agendadas",
                                                                        textAlign: TextAlign.center),
                                                                  ),
                                                                  alignLabelWithHint: true,
                                                                  isDense: true,
                                                                  border: InputBorder.none,
                                                                  labelStyle: MyTextSample.medium3(context).copyWith(
                                                                    color: MyColorsSample.grey_60,
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (webTarefaMes
                                                              .qtde_executada >
                                                              0) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                        ClienteConsultaTarefasRoute(
                                                                            idUsuario: widget
                                                                                .idUsuario,
                                                                            periodoInicial: "-",
                                                                            periodoFinal: "-",
                                                                            idxTipo: 5,
                                                                            isobscureText: isobscureText,
                                                                            tokenUsuario: widget
                                                                                .tokenUsuario,
                                                                            cnpjCliente: "-")
                                                                ));
                                                          }  else {
                                                            _showToast(context, "Nenhuma tarefa executada no periodo/mês atual", 3);
                                                          }
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              height: typeDevice == 1 ? 2.0 : 3.0,
                                                              alignment: Alignment.center,
                                                              margin: new EdgeInsets.fromLTRB(  24.0, 4.0,  24.0, 2.0),
                                                              decoration: BoxDecoration(
                                                                color: Colors.grey,
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Colors.greenAccent,
                                                                    Colors.greenAccent,
                                                                  ],
                                                                  begin: Alignment.centerLeft,
                                                                  end: Alignment.centerRight,
                                                                ),
                                                              ),
                                                            ),
                                                            Card(
                                                                elevation: 0.0,
                                                                color: Colors.white,
                                                                child: TextFormField( textAlign: TextAlign.center,
                                                                  controller:  TextEditingController()..text = webTarefaMes.qtde_executada.toString(),
                                                                  style: MyTextSample.medium4(context).copyWith(color: MyColorsSample.grey_60),
                                                                  enabled: false,
                                                                  maxLines: 1,
                                                                  decoration: InputDecoration(
                                                                    label: const Center(
                                                                      child: Text("Executadas",
                                                                          textAlign: TextAlign.center),
                                                                    ),
                                                                    alignLabelWithHint: true,
                                                                    isDense: true,
                                                                    border: InputBorder.none,
                                                                    labelStyle: MyTextSample.medium3(context).copyWith(
                                                                      color: MyColorsSample.grey_60,
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      )
                                                  ),
                                                  Expanded(
                                                         flex: 1,
                                                      child: InkWell(
                                                          onTap: () async {
                                                            if (webTarefaMes
                                                                .qtde_pendente >
                                                                0) {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (
                                                                          context) =>
                                                                          ClienteConsultaTarefasRoute(
                                                                              idUsuario: widget
                                                                                  .idUsuario,
                                                                              periodoInicial: "-",
                                                                              periodoFinal: "-",
                                                                              idxTipo: 6,
                                                                              isobscureText: isobscureText,
                                                                              tokenUsuario: widget
                                                                                  .tokenUsuario,
                                                                              cnpjCliente: "-")
                                                                  ));
                                                            }  else {
                                                              _showToast(context, "Nenhuma tarefa pendente no periodo/mês atual", 3);
                                                            }
                                                          },
                                                         child: Column(
                                                           crossAxisAlignment: CrossAxisAlignment.start,
                                                           children: <Widget>[
                                                             Container(
                                                               height: typeDevice == 1 ? 2.0 : 3.0,
                                                               alignment: Alignment.center,
                                                               margin: new EdgeInsets.fromLTRB(  24.0, 4.0,  24.0, 2.0),
                                                               //horizontal: 32.0, vertical: 2.0),
                                                               decoration: BoxDecoration(
                                                                  color: Colors.grey,
                                                                  gradient: LinearGradient(
                                                                     colors: [
                                                                        Colors.deepPurpleAccent,
                                                                        Colors.deepPurpleAccent,
                                                                     ],
                                                                     begin: Alignment.centerLeft,
                                                                     end: Alignment.centerRight,
                                                                 ),
                                                               ),
                                                             ),
                                                             Card(
                                                              elevation: 0.0,
                                                              color: Colors.white,
                                                              child: TextFormField( textAlign: TextAlign.center,
                                                                controller:  TextEditingController()..text = webTarefaMes.qtde_pendente.toString(),
                                                                style: MyTextSample.medium4(context).copyWith(color: MyColorsSample.grey_60),
                                                                enabled: false,
                                                                maxLines: 1,
                                                                decoration: InputDecoration(
                                                                  label: const Center(
                                                                    child: Text("Pendentes",
                                                                      textAlign: TextAlign.center),
                                                                  ),
                                                                  alignLabelWithHint: true,
                                                                  isDense: true,
                                                                  border: InputBorder.none,
                                                                  labelStyle: MyTextSample.medium3(context).copyWith(
                                                                    color: MyColorsSample.grey_60,
                                                                  ),
                                                                ),
                                                              )),
                                                           ],
                                                         )
                                                      )
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[

                                                            Padding(
                                                                padding: const EdgeInsets.fromLTRB(0.0,4,0.00,0),
                                                                child: AspectRatio(
                                                                    aspectRatio: typeDevice == 1 ? 1.5 : 2.5,
                                                                    child: PieChart(PieChartData(
                                                                      centerSpaceColor: Colors.white38,
                                                                      startDegreeOffset: typeDevice == 1 ? 80 :  60,
                                                                      sectionsSpace: typeDevice == 1 ? .9 : .3,
                                                                      borderData: FlBorderData(show: true,),
                                                                      sections: _chartSections(webTarefaMes),
                                                                    )
                                                                    ))
                                                            )
                                                          ]
                                                      )
                                                  )

                                                ]
                                            ),
                                          ]
                                       ))
                                    ),
                                ),
                              ]
                          )
                      )

                  )),
              Container(height: typeDevice <= 2 ? 8 : 16,),
              Expanded(flex: typeDevice == 1 ? 1 :  typeDevice == 2 ? 1 : 1,
                child:

                    ListView.builder(
                       itemCount: listaClientes.length,
                       itemBuilder: (context, index) {
                          //if ( typeDevice == 1) {
                         return makeSingleLineCard(listaClientes[index]);
                       //}
                       }
                   )
                   /*
                    GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //crossAxisCount:   4 ,
                          //childAspectRatio:  3/1.6),
                            crossAxisCount:   typeDevice   <= 2  ? 1 : typeDevice == 3 ? 2 : 4 ,
                            childAspectRatio: typeDevice == 1 ? 2.0 : typeDevice == 2 ? 3 : 5 /1.4),
                        itemCount: listaClientes.length,
                        //controller: _scrollController,
                        // const NeverScrollableScrollPhysics(),//BouncingScrollPhysics() ,//AlwaysScrollableScrollPhysics(),
                        //shrinkWrap: true,
                        itemBuilder: (context, index) {
                          //if ( typeDevice == 1) {
                          return makeCard(listaClientes[index], index, typeDevice);
                          //}
                        }
                    )

                    */
             ),
          ],
        ),
      )
      )
  );
  */
  bool isSameDay(String dataStatusString) {
    final agora = DateTime.now();
   if (dataStatusString.isEmpty) {
      return false;
    }
    try {
      final dataStatus = DateTime.parse(dataStatusString);
      return agora.year  == dataStatus.year &&
          agora.month == dataStatus.month &&
          agora.day   == dataStatus.day;

    } catch (e) {
      print("Erro ao converter a data do status da API: $e. String recebida: '$dataStatusString'");
      return false;
    }
  }
  bool isSameMontYear(String dataStatusString) {
    // 1. Guarda o momento exato em que a função é chamada para obter a data atual.
    final agora = DateTime.now();

    // 2. Garante que a string de entrada não está vazia.
    // Se estiver, não pode ser comparada, então retorna `false` para evitar erros.
    if (dataStatusString.isEmpty) {
      return false;
    }

    try {
      // 3. Converte a string da API em um objeto DateTime.
      // O bloco 'try-catch' protege contra formatos de data inesperados.
      final dataStatus = DateTime.parse(dataStatusString);

      // 4. A comparação principal: verifica se ano, mês e dia são idênticos.
      // Esta é a forma mais robusta de comparar "o dia" sem se preocupar com a hora.
      return agora.year  == dataStatus.year &&
          agora.month == dataStatus.month;/* &&
          agora.day   == dataStatus.day;*/

    } catch (e) {
      // 5. Se a conversão da string falhar, loga o erro para depuração
      // e retorna `false` para garantir que o aplicativo não quebre.
      print("Erro ao converter a data do status da API: $e. String recebida: '$dataStatusString'");
      return false;
    }
  }

}








