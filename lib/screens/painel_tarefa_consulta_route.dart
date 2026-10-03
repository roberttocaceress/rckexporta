import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_difference/flutter_date_difference.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';
import 'package:rck_painel_tarefa/model/web_status_exportacao.dart';
import 'package:rck_painel_tarefa/screens/cliente_tarefa_consulta_route.dart';
import 'package:universal_html/html.dart';

import '../../api/web_api_exporta.dart';
import '../../model/web_tarefa.dart';
import '../firebase_options.dart';
import '../model/web_analise_arquivo_xml.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rck_painel_tarefa/screens/vendedor_consulta_route.dart';
class PainelTarefasRoute extends StatelessWidget {
  final String tokenUsuario;
  final String  idUsuario;
  const PainelTarefasRoute(
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
  late final ScrollController _scrollController;
  int offSet = 0,
      totalReg = 0,
      limiteReg = 21;
  bool isLoading = false;
  bool isobscureText = false;

  //final MediaQueryData data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single);
  //final bool isTablet = DeviceDetector.isTablet(MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single));

  var sizeQuery;
  var diagQuert;
  final int typeDevice = DeviceDetector.typeDevice(MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.single));


  GlobalKey btnMenu = GlobalKey();

  //final List<GlobalObjectKey> keyList = List.generate(20, (index) => GlobalObjectKey(index));
  List<GlobalObjectKey> keyList2 = [
  ]; //List.generate(20, (index) => GlobalObjectKey(index));
  late PopupMenu menu;
  late int idxClicado;
  final _dateDifference = FlutterDateDifference(language: "en");
  final tempoConsultaStatusCliente = Duration(/*seconds: 20*/ minutes: 15);
  final tempoConsultaStatusTarefa = Duration(minutes: 30);
  Timer? _timer;
  ScrollController scrollController = ScrollController();
  bool consultaTarefaIniciada = false;
  bool consultaTarefaAtiva    = false;
  late Stream<QuerySnapshot> _myStreamCliente;
  @override
  void initState() {
    super.initState();
    //Firebase.initializeApp();

   /* Future.delayed(const Duration(minutes: 2), () {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: Duration(seconds: listaClientes.length * 10),
          curve: Curves.linear);
    });*/


    isLoading = false;
    _fWebTarefa = _getWebTarefa();
    //_fWebCliente = fetchClientes();//_getWebCliente(offSet, limiteReg, false);
    offSet = 21;
    _startConsultaStatusTarefa();
    _startConsultaStatusAPI();
    _myStreamCliente =  fetchClientes() ;
    //fetchClientes();
    //fetchStatusAPI();
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    //scrollController.dispose();

    super.dispose();
  }

  Stream<QuerySnapshot> fetchClientes() {
    //db = FirebaseFirestore.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference cliente = firestore.collection('clientes');
    return cliente.orderBy("razao_social", descending: false).snapshots();
    /*return query.firestore.snapshotsInSync()
       query.get()
        .then((QuerySnapshot snapshot) {

      snapshot.docs.forEach((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        //setState(() {

          listaClientes.add(WebCliente.fromJson(data!));
       // });
           //print('${doc.id} => ${doc.data()}');
      });
      setState(() {});
      if (listaClientes.isNotEmpty) {
        fetchStatusAPI();
      }
      //return listaClientes;
    })
        .catchError((error) =>
      print(error));;
    throw Exception('Failed to fetch clientes');*/
  }

  Future<void> fetchStatusAPI() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference statusApi;
    DocumentReference statusExportacao;
    String dataAgendamento = DateFormat('yyyy-MM')
        .format(DateTime.now())
        .toString() + "-" ;
    for (WebCliente webCliente in listaClientes) {
      statusApi = firestore.collection('clientes').doc(
          webCliente.cpf_cnpj).collection("statusapi");
      await statusApi.get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) {
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          setState(() {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == doc.get("cnpj"))].webStatusApi =
                WebStatusApi.fromJson(data!);
          });
          //listaClientes.add(WebCliente.fromJson(data!));
          // });
          //print('${doc.id} => ${doc.data()}');
        });
      }).catchError((error) =>
          print(error));
      statusExportacao = firestore.collection('clientes').doc(
            webCliente.cpf_cnpj).collection("exportacao").doc(dataAgendamento + webCliente.data_exportacao_1);
      await statusApi.get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            WebStatusExportacao webStatusExportacao = WebStatusExportacao.fromJson(data!);
            String diaAtual = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString().substring(0,2);
            if (  diaAtual == webStatusExportacao.data_agendamento) {
              WebStatusExportacao webClienteExportacao = listaClientes[listaClientes
                  .indexWhere((item) =>
              item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao;
              if (webStatusExportacao.sucesso &&
                  !webClienteExportacao.sucesso) {
                webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada + 1);
                webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente - 1);
              }
              if (!webStatusExportacao.sucesso &&
                  webClienteExportacao.sucesso) {
                webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada - 1);
                webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente + 1);
              }
              //setState(() {
                _chartSections(webTarefaDia);
                listaClientes[listaClientes.indexWhere((item) =>
                item.cpf_cnpj == doc.get("cnpj"))].webStatusExportacao =
                    webStatusExportacao;
              //});
            }
            if (  diaAtual != webStatusExportacao.data_agendamento) {
              WebStatusExportacao webClienteExportacao = listaClientes[listaClientes
                  .indexWhere((item) =>
              item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao;
              if ( webStatusExportacao.sucesso && !webClienteExportacao.sucesso) {
                webTarefaMes.qtde_executada = (webTarefaMes.qtde_executada + 1);
                webTarefaMes.qtde_pendente = (webTarefaMes.qtde_pendente - 1);
              }
              if ( !webStatusExportacao.sucesso && webClienteExportacao.sucesso) {
                webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada - 1 );
                webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente + 1);
              }
              //setState(() {
                _chartSections(webTarefaMes);
                listaClientes[listaClientes.indexWhere((item) =>
                item.cpf_cnpj == doc.get("cnpj"))].webStatusExportacao =
                    webStatusExportacao;
              //});
            }
            //listaClientes.add(WebCliente.fromJson(data!));
            // });
            //print('${doc.id} => ${doc.data()}');
          });

      }).catchError((error) =>
          print(error));
      //setState(() {
      //  listaClientes;
      //} );
    }
    //await _atualizarStatusExportacao();

  }

  Future<List<WebCliente>> _getWebCliente(int offSet, int limiteReg,
      bool isAutoScrool) async {
    List<WebCliente> lista = [];
    lista.addAll(await ApiWebCliente(
        Dio(BaseOptions(contentType: "application/json")),
        baseUrl: "${await getUrlAPI()}/ws")
        .getWebCliente(
        widget.idUsuario.toString(), offSet, limiteReg, widget.tokenUsuario));

    /*for (WebCliente webCliente  in lista) {
      if ( webCliente.url_api != null && webCliente.url_api.isNotEmpty) {
        webCliente.webStatusApi = await _getDadosStatus(webCliente.url_api, webCliente.cpf_cnpj);
        if ( webCliente.webStatusApi.sucesso) {
            if ( webCliente.data_exportacao_1.isNotEmpty ) {
              if ( webCliente.data_exportacao_1 == webCliente.webStatusApi.dataHoraUltimoStatus.substring(0, 2)) {
                  //WebStatusApi webStatusExportacao =
                  //Analisar aqui para nao repetir a ultima exportacao
                  await _getWebAnaliseArquivoXml(webCliente, "-", "-", "-", "1", "S" );
              }
            }
            if ( webCliente.data_exportacao_2.isNotEmpty ) {
              if ( webCliente.data_exportacao_2 == webCliente.webStatusApi.dataHoraUltimoStatus.substring(0, 2)) {
                 await _getWebAnaliseArquivoXml(webCliente, "-", "-", "-", "1", "S" );
              }
            }

        }
      }
    }*/

    if (lista.length >= 1) {
      if (isAutoScrool) {
        if (lista.length == 3) {
          listaClientes.removeRange(0, 3);
        } else if (lista.length == 2) {
          listaClientes.removeRange(0, 3);
        } else if (lista.length == 1) {
          listaClientes.removeRange(0, 1);
        }
        listaClientes.addAll(lista);
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(/*seconds: listaClientes.length * 10*/
                minutes: 5), curve: Curves.linear);
      } else {
        listaClientes.addAll(lista);
      }
    } else {
      //scrollController.animateTo(scrollController.position.maxScrollExtent,
      //    duration: Duration(/*seconds: listaClientes.length * 10*/ minutes: 2),
      //    curve: Curves.linear);
      /*
      if ( isAutoScrool) {
        offSet = 0;
        limiteReg = 3;
        listaClientes.removeAt(3);

      }
*/
    }
    setState(() {});
    if (listaClientes.isNotEmpty) {
      _atualizarStatusApi();
    }
    return listaClientes;
  }

  Future<void> _atualizarStatusApi() async {
    List<WebStatusApi> lista = await _getDadosStatusAPI();
    for (WebStatusApi webStatusApi in lista) {
      setState(() {
        listaClientes[listaClientes.indexWhere((item) =>
        item.cpf_cnpj == webStatusApi.cnpj)].webStatusApi =
            webStatusApi;
      });
    }
    await _atualizarStatusExportacao();
    //_getWebTarefa();
  }

    /*for (WebCliente webCliente in listaClientes) {
      String dataAtual = DateFormat('dd-MM-yyyy')
          .format(DateTime.now())
          .toString();
      String dataExportacao = DateFormat('yyyy-MM-dd')
          .format(DateTime.now())
          .toString();
      String dataAgendamento = DateFormat('yyyy-MM')
          .format(DateTime.now())
          .toString() + "-" + webCliente.data_exportacao_1;
      if ((webCliente.data_exportacao_1.isNotEmpty &&
          webCliente.webStatusApi.sucesso) &&
          (webCliente.data_exportacao_1 == dataAtual.substring(0, 2)) ||
          int.parse(webCliente.data_exportacao_1) <=
              int.parse(dataAtual.substring(0, 2))) {
         //webCliente.webStatusApi.dataHoraUltimoStatus.substring(0, 2) ) {
         if ( webCliente.webAnaliseArquivoXml.id == "0") {
             await _atualizarStatusExportacao(
               dataAgendamento, webCliente);
         }
        *//*
          if( webCliente.status_exportacao_1.isEmpty ||  webCliente.status_exportacao_1 == "P" ) {
            if ( webCliente.webAnaliseArquivoXml.data_exportacao == '2025-09-23') {
              await _getWebAnaliseArquivoXml(
                  webCliente, "-", "-", "-", "1", "S");
            }
          }
           *//*
      }
      *//*
      if (webCliente.data_exportacao_2.isNotEmpty && webCliente.webStatusApi.sucesso && webCliente.data_exportacao_2 ==
          webCliente.webStatusApi.dataHoraUltimoStatus.substring(0, 2)) {
          if( webCliente.status_exportacao_2.isEmpty ||  webCliente.status_exportacao_2 == "P" ) {

             await _getWebAnaliseArquivoXml(webCliente, "-", "-", "-", "1", "S");
          }

      }

       *//*
    }*/
  //}

  Future<void> _atualizarStatusExportacao() async {
    List<WebStatusExportacao> lista = [];
    lista.addAll(await ApiWebDadosExportacao(
        Dio(BaseOptions(contentType: "application/json")),
        baseUrl: "${await getUrlAPI()}/ws")
        .getWebDadosExportacao( widget.tokenUsuario));
    if ( lista.isNotEmpty) {
      for (WebStatusExportacao webStatusExportacao in lista) {
        //if ( webCliente.webAnaliseArquivoXml.)
        //String dataAtual = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
        String diaAtual = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString().substring(0,2);
        if (  diaAtual == webStatusExportacao.data_agendamento) {
          WebStatusExportacao webClienteExportacao = listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao;
          //if ( webStatusExportacao.sucesso){
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
          //return;
        }
        if (  diaAtual != webStatusExportacao.data_agendamento) {
          WebStatusExportacao webClienteExportacao = listaClientes[listaClientes.indexWhere((item) =>
          item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao;
          //if ( webStatusExportacao.sucesso) {
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
    }
  }

/*
  Future<void> _atualizarStatusExportacao(
      String dataAgendamento, WebCliente webCliente) async {
      List<WebAnaliseArquivoXml> lista = [];
      lista.addAll(await ApiWebDadosExportacao(
          Dio(BaseOptions(contentType: "application/json")),
          baseUrl: "${await getUrlAPI()}/ws")
           .getWebDadosExportacao(
           webCliente.id_cadastro, dataAgendamento, widget.tokenUsuario));
      if ( lista.isNotEmpty) {
        for (WebAnaliseArquivoXml webAnaliseArquivoXml in lista) {
           //if ( webCliente.webAnaliseArquivoXml.)
           String dataAtual = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
           if (  dataAtual == webAnaliseArquivoXml.data_agendamento) {
             webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada + 1);
             webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente - 1);
             setState(() {
               _chartSections(webTarefaDia);
               listaClientes[listaClientes.indexWhere((item) =>
               item.cpf_cnpj == webCliente.cpf_cnpj)].webAnaliseArquivoXml =
                   webAnaliseArquivoXml;
             });
             return;
           }
           if (  dataAtual != webAnaliseArquivoXml.data_agendamento) {
              webTarefaMes.qtde_executada = (webTarefaMes.qtde_executada + 1);
              webTarefaMes.qtde_pendente = (webTarefaMes.qtde_pendente - 1);
              setState(() {
                _chartSections(webTarefaMes);
                 listaClientes[listaClientes.indexWhere((item) =>
                 item.cpf_cnpj == webCliente.cpf_cnpj)].webAnaliseArquivoXml =
                   webAnaliseArquivoXml;
              });
           }
        }
      } else {
        await _getWebAnaliseArquivoXml(
            webCliente, "-", "-", "-", "1", "S");
      }

}
*/

Future<List<WebTarefa>> _getWebTarefa() async {
    List<WebTarefa> lista = [];
    lista.addAll(await  ApiWebTarefa(
        Dio(BaseOptions(contentType: "application/json")), baseUrl: "${await getUrlAPI()}/ws")
        .getWebTarefa(widget.idUsuario.toString(), widget.tokenUsuario));

    setState(() {
      if (lista.length >= 1) {
        webTarefaDia = lista[0];
      }
      if (lista.length >= 2) {
        webTarefaMes = lista[1];
      }
    });
    if ( consultaTarefaIniciada == true) {
      setState(() {
        listaClientes.clear();
      });
      //();
      //_getWebCliente(0, 0, false);
    }
    //_atualizarStatusApi(/*listaClientes*/);
    consultaTarefaAtiva = false;
    return lista;
  }

  Future<List<WebStatusApi>> _getDadosStatusAPI() async{
    List<WebStatusApi> lista = [];
    try {
       lista.addAll(await  ApiWebStatusApi(
          Dio(BaseOptions(contentType: "application/json")), baseUrl: "${await getUrlAPI()}/ws")
           .getWebStatusApi(  widget.tokenUsuario));

    } on DioException catch (e) {
        print(e.error);
        print(e.requestOptions);
        print(e.message);
    }
    return lista;
     //return WebStatusApi(id: 0, url: "", cnpj: "", mensagem: "", sucesso: false,
     //   qtdeNotaEmitida: 0, qtdeNotaAutorizada: 0, qtdeNotaContigencia: 0, qtdeNotaCancelada: 0, qtdeNotaOutras: 0,
     //   dataHoraAtualStstus: "", dataHoraUltimoStatus: "", sequenciaNumerica: true, primeiraNota: false
    //);
  }


  /*Future<List<WebAnaliseArquivoXml>> _getWebAnaliseArquivoXml(WebCliente webCliente, String codModelo,
      String dataInicial, String dataFinal, String idPeriodo, String exportaArquivos ) async {
    List<WebAnaliseArquivoXml> listaAnalise = [];
    try {
      listaAnalise.addAll(await ApiWebExportaAnaliseArquivoXml(
          Dio(BaseOptions(contentType: "application/json")),
          baseUrl: "${webCliente.url_api}/ws")
          .getWebExportaAnaliseArquivoXml(
          widget.idUsuario.toString(),
          "-",
          "-",
          codModelo,
          webCliente.cpf_cnpj,
          "S",
          widget.tokenUsuario));
      if ( listaAnalise.length == 4) {
          if ( listaAnalise[0].sucesso && listaAnalise[1].sucesso && listaAnalise[2].sucesso && listaAnalise[3].sucesso ) {
            //await _getWebExportaArquivoXml(webCliente, codModelo);
            if ( exportaArquivos == "S") {
              await _getWebExportaTodosArquivoXml(webCliente);
            }
          }
      } else if ( listaAnalise.length == 8) {
        if ( listaAnalise[0].sucesso && listaAnalise[1].sucesso && listaAnalise[2].sucesso && listaAnalise[3].sucesso
          && listaAnalise[4].sucesso && listaAnalise[5].sucesso && listaAnalise[6].sucesso && listaAnalise[7].sucesso) {
          //await _getWebExportaArquivoXml(webCliente, codModelo);
          if ( exportaArquivos == "S") {
            await _getWebExportaTodosArquivoXml(webCliente);
          }
        }
      }

      return listaAnalise;
    } on DioException catch (e) {
      print(e.error);
      print(e.requestOptions);
      print(e.message);
    }

    return listaAnalise;
  }*/

  /*Future<void> _getWebExportaTodosArquivoXml(
      WebCliente webCliente) async {
    List<WebAnaliseArquivoXml> listaExporta = [];
    try {
      listaExporta.addAll(await ApiWebExportaZipTodosArquivoXml(
              Dio(BaseOptions(contentType: "application/json")),
              baseUrl: "${webCliente.url_api}/ws")
          .getWebExportaZipTodosArquivoXml(
              widget.idUsuario.toString(),
              "-",
              "-",
              webCliente.cpf_cnpj,
              webCliente.email_principal.isEmpty
                  ? "-"
                  : webCliente.email_principal,
              webCliente.email_financeiro.isEmpty
                  ? "-"
                  : webCliente.email_financeiro,
              "S",
              widget.tokenUsuario));
      if ( listaExporta[0].sucesso) {
        _addDadosExportacao(webCliente, listaExporta[0]);
        setState(() {
          String dataAtual = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
          if (  dataAtual.substring(8) == webCliente.data_exportacao_1) {
            webTarefaDia.qtde_executada = (webTarefaDia.qtde_executada + 1);
            webTarefaDia.qtde_pendente = (webTarefaDia.qtde_pendente - 1);
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webCliente.cpf_cnpj)].webAnaliseArquivoXml =
            listaExporta[0];
            return ;
          }
          if (dataAtual.substring(8) != webCliente.data_exportacao_1) {
            webTarefaMes.qtde_executada = (webTarefaMes.qtde_executada + 1);
            webTarefaMes.qtde_pendente = (webTarefaMes.qtde_pendente - 1);
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webCliente.cpf_cnpj)].webAnaliseArquivoXml =
            listaExporta[0];
            return;
          }
        });
      }
    } on DioException catch (e) {
      print(e.error);
      print(e.requestOptions);
      print(e.message);
    }
  }*/

 /* Future<List<WebAnaliseArquivoXml>> _addDadosExportacao(
      WebCliente webCliente, WebAnaliseArquivoXml webAnaliseArquivoXml) async {
    String dataAgendamento = DateFormat('yyyy-MM').format(DateTime.now()).toString() + "-"  + webCliente.data_exportacao_1;
    webAnaliseArquivoXml.id = webCliente.id_cadastro;
    webAnaliseArquivoXml.data_agendamento = dataAgendamento;
    List<WebAnaliseArquivoXml> listaExporta = [];
    listaExporta.add(webAnaliseArquivoXml);
    try {
      listaExporta.addAll(await ApiWebAddExportacaoCliente(
          Dio(BaseOptions(contentType: "application/json")),
          baseUrl: "${"http://192.168.100.152:725/rckwhalleAPI2.7.3"}/ws")
          .addExportacaoCliente( listaExporta,
          widget.tokenUsuario));
      return listaExporta;
    } on DioException catch (e) {
      print(e.error);
      print(e.requestOptions);
      print(e.message);
    }
    return listaExporta;
  }*/

  /*Future<List<WebAnaliseArquivoXml>> _getWebExportaArquivoXml(WebCliente webCliente, String codModelo ) async {
    List<WebAnaliseArquivoXml> listaExporta = [];
    try {
      listaExporta.addAll(await ApiWebExportaZipArquivoXml(
          Dio(BaseOptions(contentType: "application/json")),
          baseUrl: "${webCliente.url_api}/ws")
          .getWebExportaZipArquivoXml(
          widget.idUsuario.toString(),
          "-",
          "-",
          "-",//codModelo,
          webCliente.cpf_cnpj,
          webCliente.email_principal.isEmpty ? "-" :  webCliente.email_principal,
          webCliente.email_financeiro.isEmpty ? "-" :  webCliente.email_financeiro,
          "S",
          widget.tokenUsuario));
      return listaExporta;
    } on DioException catch (e) {
      print(e.error);
      print(e.requestOptions);
      print(e.message);
    }
    return listaExporta;
  }*/

  void _startConsultaStatusAPI() {
    _timer = Timer.periodic(tempoConsultaStatusCliente, (Timer timer) {
        offSet+= 3;
        limiteReg = 3;
        if ( !consultaTarefaAtiva)
           _atualizarStatusApi(/*listaClientes*/);
        //_getWebCliente(offSet, limiteReg, true);
    });
  }

  void _startConsultaStatusTarefa() {
    _timer = Timer.periodic(tempoConsultaStatusTarefa, (Timer timer) {
      consultaTarefaIniciada = true;
      consultaTarefaAtiva = true;
      _getWebTarefa();
    });
  }

  Future<String> getUrlAPI() async {
    String fileText = await rootBundle.loadString('assets/URLAPI.txt');
    return fileText.toString().trim();
  }

  List<PieChartSectionData> _chartSections(WebTarefa webTarefa) {
    final List<PieChartSectionData> lista = [];
    //for (var sector in sectors) {
      const double radius = 20.0;
      final dataAgendada = PieChartSectionData(
        color: Colors.orangeAccent,
        value: webTarefa.qtde_agendada.toDouble(),
        radius: radius,
        title: 'A',
      );
      //lista.add(dataAgendada);
    final dataExecutada = PieChartSectionData(
      color: Colors.greenAccent,
      value: webTarefa.qtde_executada.toDouble(),
      radius: radius,
      title: 'E',
    );
    lista.add(dataExecutada);
    //}
    final dataPendente = PieChartSectionData(
      color: Colors.deepPurpleAccent,
      value: webTarefa.qtde_pendente.toDouble(),
      radius: radius,
      title: 'P',
    );
    lista.add(dataPendente);
    return lista;
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
              title:  Text('Tela ' + DeviceDetector.typeDevice(MediaQueryData.fromView(
                  WidgetsBinding.instance.platformDispatcher.views.single)).toString() + " Tam "
              + DeviceDetector2.typeDevice(MediaQueryData.fromView(
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
      //body: FutureBuilder<List<WebCliente>>(
      body: StreamBuilder<QuerySnapshot>(
          stream: _myStreamCliente,

          //builder: builder


        //stream: FirebaseFirestore.instance.collection('clientes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if ( snapshot.hasData) {
            //await statusApi.get()
            //    .then((QuerySnapshot snapshot) {
            //snapshot.data.docChanges
            if (snapshot.data!.docChanges.isNotEmpty) {
              for (var change in snapshot.data!.docChanges) {
                if (change.type == DocumentChangeType.added) {
                  print('Document added: ${change.doc.data()}');
                  Map<String, dynamic>? data = change.doc.data() as Map<String,
                      dynamic>?;
                  listaClientes.add(WebCliente.fromJson(data!));
                  // Add the new document to your UI list
                } else if (change.type == DocumentChangeType.modified) {
                  print('Document modified: ${change.doc.data()}');
                  Map<String, dynamic>? data = change.doc.data() as Map<String,
                      dynamic>?;
                  listaClientes[listaClientes.indexWhere((item) =>
                  item.cpf_cnpj == change.doc.get("cnpj_cpf"))] =
                      WebCliente.fromJson(data!);

                  // Update the corresponding document in your UI list
                } else if (change.type == DocumentChangeType.removed) {
                  print('Document removed: ${change.doc.data()}');
                  // Remove the document from your UI list
                }
              }
              //fetchStatusAPI();
            } /*else {
              snapshot.data!.docs.forEach((doc) {
                Map<String, dynamic>? data = doc.data() as Map<String,
                    dynamic>?;
                listaClientes.add(WebCliente.fromJson(data!));

                //setState(() {
                //listaClientes[listaClientes.indexWhere((item) =>
                //item.cpf_cnpj == doc.get("cnpj_cpf"))].webStatusApi =
                //    WebStatusApi.fromJson(data!);
                //});
                //listaClientes.add(WebCliente.fromJson(data!));
                // });
                //print('${doc.id} => ${doc.data()}');
              });
          }*/}
                     //setState(() {});


          return Scaffold(
            backgroundColor: MyColorsSample.white,
            body: OrientationBuilder(
              builder: (context, orientation) {
                //if (listaClientes.isNotEmpty) {
                //  fetchStatusAPI();
                //}
                return listContainer(typeDevice, orientation == Orientation.portrait, kIsWeb);
              },
            ),
          );


          //}).catchError((error) =>
          //    print(error));
          // Se os dados são disponíveis, você pode exibi-los
         /* return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nome']), // Substitua 'nome' pelo campo real
                subtitle: Text(data['outra_informacao']), // Substitua pelo campo real
              );
            }).toList(),
          );*/
        },
        /*future: _fWebCliente,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: MyColorsSample.white,
              body: OrientationBuilder(
                builder: (context, orientation) {
                  return listContainer(typeDevice, orientation == Orientation.portrait, kIsWeb);
                },
              ),
            );
          } else {
            return Center(
              //heightFactor: 4,
              child: CircularProgressIndicator(color: MyColorsSample.rckapp, semanticsLabel: 'Aguarde...',),
            );
          }
        },*/
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
      webCliente.webStatusApi.sucesso && (!webCliente.webStatusExportacao.sucesso && webCliente.webStatusExportacao.dataHora.isNotEmpty) ? Colors.red :
      !webCliente.webStatusApi.sucesso && !webCliente.webStatusApi.sucesso ? Colors.red : MyColorsSample.rckapp,
      shadowColor: webCliente.webStatusApi.sucesso && webCliente.webStatusExportacao.sucesso ? MyColorsSample.rckapp :
      webCliente.webStatusApi.sucesso && (!webCliente.webStatusExportacao.sucesso && webCliente.webStatusExportacao.dataHora.isNotEmpty) ? Colors.red :
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
                                                          typeDevice <= 2 ? MascaraUtil()._formataData(webCliente.webStatusApi.dataHora.substring(0,10), "/", 8)
                                                            + " " +  webCliente.webStatusApi.dataHora.substring(11,16) : MascaraUtil()._formataData(webCliente.webStatusApi.dataHora.substring(0,10), "/", 10)
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
                                                          controller: TextEditingController()..text = webCliente.webStatusExportacao.cnpj.isEmpty ? "-" : webCliente.webStatusExportacao.sucesso == true ? MascaraUtil()._formataData(webCliente.webStatusExportacao.data_exportacao, "/", 10) + " - " + webCliente.webStatusExportacao.hora_exportacao  : "-",
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
                                                            controller: TextEditingController()..text = webCliente.webStatusExportacao.cnpj.isEmpty ? "-" : webCliente.webStatusExportacao.sucesso == true ? MascaraUtil()._formataData(webCliente.webStatusExportacao.data_exportacao, "/", 10) + " - " + webCliente.webStatusExportacao.hora_exportacao  : "-",
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
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.sequenciaNumericaNFe? "OK" : "ERRO",
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
                                //Produtos que alteram o preço sem a tabela(TKS)
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
                                                    ..text =
                                                        webTarefaDia.data_hora_atualizado.substring(3, 10),
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
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //crossAxisCount:   4 ,
                        //childAspectRatio:  3/1.6),
                        crossAxisCount:   typeDevice   <= 2  ? 1 : typeDevice == 3 ? 2 : 4 ,
                        childAspectRatio: typeDevice == 1 ? 2.0 : typeDevice == 2 ? 3 : 5 /1.4),
                    itemCount: listaClientes.length,
                    controller: scrollController,
                    // const NeverScrollableScrollPhysics(),//BouncingScrollPhysics() ,//AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      //if ( typeDevice == 1) {
                        return makeCard(listaClientes[index], index, typeDevice);
                      //}
                    }
                )
             ),
          ],
        ),
      )
      )
  );


  void _showToast(context, mensagem ,  int second) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: MyColorsSample.rckapp ,
          duration: Duration(seconds: second),
          behavior: SnackBarBehavior.floating,
          elevation: 50,
          content: Row(
            children: [

              const Icon(
                Icons.check,
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
                      backgroundColor: MyColorsSample.rckapp,
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



class MyTextSample{

  static TextStyle? display4(BuildContext context){
    return Theme.of(context).textTheme.displayLarge;
  }

  static TextStyle? display3(BuildContext context){
    return Theme.of(context).textTheme.displayMedium;
  }

  static TextStyle? display2(BuildContext context){
    return Theme.of(context).textTheme.displaySmall;
  }

  static TextStyle? display1(BuildContext context){
    return Theme.of(context).textTheme.headlineMedium;
  }

  static TextStyle? headline(BuildContext context){
    return Theme.of(context).textTheme.headlineSmall;
  }

  static TextStyle? title(BuildContext context){
    return Theme.of(context).textTheme.titleLarge;
  }

  static TextStyle medium(BuildContext context){
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 16,
    );
  }

  static TextStyle medium2(BuildContext context){
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 18,
    );
  }

  static TextStyle medium3(BuildContext context){
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 20,
    );
  }

  static TextStyle medium4(BuildContext context){
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 24,
    );
  }

  static TextStyle small(BuildContext context){
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 12,
    );
  }

  static TextStyle small2(BuildContext context){
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 14,
    );
  }

  static TextStyle large(BuildContext context){
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 34,
    );
  }
  static TextStyle large1(BuildContext context){
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 44,
    );
  }
  static TextStyle large2(BuildContext context){
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 54,
    );
  }

  //Large
  static TextStyle? subhead(BuildContext context){
    return Theme.of(context).textTheme.titleMedium;
  }

  static TextStyle? body2(BuildContext context){
    return Theme.of(context).textTheme.bodyLarge;
  }

  static TextStyle? body1(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium;
  }

  static TextStyle? caption(BuildContext context){
    return Theme.of(context).textTheme.bodySmall;
  }

  static TextStyle? button(BuildContext context){
    return Theme.of(context).textTheme.labelLarge!.copyWith(
        letterSpacing: 1
    );
  }

  static TextStyle? subtitle(BuildContext context){
    return Theme.of(context).textTheme.titleSmall;
  }

  static TextStyle? overline(BuildContext context){
    return Theme.of(context).textTheme.labelSmall;
  }
}

class MyColorsSample {
  static const Color rckapp = Color(0xFF68ACA1);
  static const Color rckappDesabled = Color(0x9068ACA1);
  static const Color primary = Color(0xFF12376F);
  static const Color primaryDark = Color(0xFF0C44A3);
  static const Color primaryLight = Color(0xFF43A3F3);
  static const Color green = Colors.green;
  static Color black = const Color(0xFF000000);
  static const Color desabled = Color(0x9068ACA1);
  static const Color accent = Color(0xFFFF4081);
  static const Color accentDark = Color(0xFFF50057);
  static const Color accentLight = Color(0xFFFF80AB);
  static const Color grey_1 = Color(0xFFf9f9f9);
  static const Color grey_2 = Color(0xFFf8f8f8);
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

class MascaraUtil {
  String _mascaraCpf(String cpf) {
    String valorLimpo = cpf.trim().replaceAll("[^0-9]", "");
    if (!valorLimpo.isEmpty && valorLimpo.length == 11) {
      cpf = valorLimpo.substring(0, 3) +
          "." +
          valorLimpo.substring(3, 6) +
          "." +
          valorLimpo.substring(6, 9) +
          "-" +
          valorLimpo.substring(9, 11);
    }
    return cpf;
  }

  String _mascaraCNPJ(String cnpj) {
    String valorLimpo = cnpj.trim().replaceAll("[^0-9]", "");
    if (!valorLimpo.isEmpty && valorLimpo.length == 14) {
      cnpj = valorLimpo.substring(0, 2) +
          "." +
          valorLimpo.substring(2, 5) +
          "." +
          valorLimpo.substring(5, 8) +
          "/" +
          valorLimpo.substring(8, 12) +
          "-" +
          valorLimpo.substring(12, 14);
    }
    return cnpj;
  }

  String _formataTelefone(String telefone) {
      telefone = telefone.trim().replaceAll("[^0-9]", "");
      if (telefone.length == 10) {
        telefone = "(" + telefone.substring(0, 2) + ") " + telefone.substring(2, 6) + "-" + telefone.substring(6, 10);
      } else if (telefone.length == 11) {
        telefone = "(" + telefone.substring(0, 2) + ") " + telefone.substring(2, 7) + "-" + telefone.substring(7, 11);
      } else if (telefone.length == 9 && !telefone.contains("-")) {
        telefone = telefone.substring(0, 5) + "-" + telefone.substring(5, 9);
      } else if (telefone.length == 8) {
        telefone = telefone.substring(0, 4) + "-" + telefone.substring(4, 8);
      } else {
        telefone= telefone;
      }
    return telefone;
  }

  String _formataData( String data, String separador, int tamanho) {
    if ( data == null || data.isEmpty) {
      return "";
    }
    if ( separador == "-") {
      data = data.substring(6,10) + separador + data.substring(3,5) + separador + data.substring(0,2);
    } else {
      if (tamanho == 10)
        data = data.substring(8, 10) + separador + data.substring(5, 7) + separador + data.substring(0, 4);
      else
        data = data.substring(8, 10) + separador + data.substring(5, 7) + separador + data.substring(2, 4);
    }
    return data;
  }
  String _formataMesAno( String data, String separador, int tamanho) {
    if ( data == null || data.isEmpty) {
      return "";
    }
    if ( separador == "-") {
      data = data.substring(6,10) + separador + data.substring(3,5) + separador + data.substring(0,2);
    } else {
      if (tamanho == 10)
        data =  data.substring(5, 7) + separador + data.substring(0, 4);
      else
        data =  data.substring(5, 7) + separador + data.substring(2, 4);
    }
    return data;
  }
}

class DeviceDetector2 {
  static double typeDevice(MediaQueryData query) {  // 1 Smartphone //2 Tablet  //3  PC   // 4 TV
    var size = query.size;
    var diagonal = sqrt(
        (size.width * size.width) +
            (size.height * size.height)
    );
    if ( diagonal < 1100.0) {
      return diagonal;
    }
    if (  diagonal >= 1100.0 && diagonal <= 2100.0) {
      return diagonal;
    }
    if (  diagonal > 2100.0) {
      return diagonal;
    }
    return diagonal;
  }

  static double isTablet2(MediaQueryData query) {
    var size = query.size;
    var diagonal = sqrt(
        (size.width * size.width) +
            (size.height * size.height)
    );

    /*
    print(
      'size: ${size.width}x${size.height}\n'
      'pixelRatio: ${query.devicePixelRatio}\n'
      'pixels: ${size.width * query.devicePixelRatio}x${size.height * query.devicePixelRatio}\n'
      'diagonal: $diagonal'
    );
    */

    return diagonal;
  }
}

class DeviceDetector {
  static int typeDevice(MediaQueryData query) {  // 1 Smartphone //2 Tablet  //3  PC   // 4 TV
    var size = query.size;
    var diagonal = sqrt(
        (size.width * size.width) +
            (size.height * size.height)
    );
    if ( diagonal < 1100.0) {
      return 1;
    }
    if (  diagonal >= 1100.0 && diagonal <= 2100.0) {
      return 2;
    }
    if (  diagonal > 2100.0) {
      return 3;
    }
    return 4;
  }

  static double isTablet2(MediaQueryData query) {
    var size = query.size;
    var diagonal = sqrt(
        (size.width * size.width) +
            (size.height * size.height)
    );

    /*
    print(
      'size: ${size.width}x${size.height}\n'
      'pixelRatio: ${query.devicePixelRatio}\n'
      'pixels: ${size.width * query.devicePixelRatio}x${size.height * query.devicePixelRatio}\n'
      'diagonal: $diagonal'
    );
    */

    return diagonal;
  }
}
