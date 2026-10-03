import 'dart:async';
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_difference/flutter_date_difference.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';
import 'package:universal_html/html.dart';

import '../../api/web_api_exporta.dart';
import '../../model/web_tarefa.dart';
import '../model/web_analise_arquivo_xml.dart';
class ClienteConsultaTarefasRoute extends StatelessWidget {
  final String  idUsuario;
  final String periodoInicial;
  final String periodoFinal;
  final int idxTipo;
  final bool isobscureText;// 1 Agendada 2 Executada 3 Pendente
  final String tokenUsuario;
  final String cnpjCliente;

  const ClienteConsultaTarefasRoute(
      {super.key, required this.idUsuario,  required this.periodoInicial,  required this.periodoFinal ,  required this.idxTipo ,
        required this.isobscureText  , required this.tokenUsuario, required this.cnpjCliente});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(idUsuario: idUsuario, periodoInicial: periodoInicial, periodoFinal: periodoFinal, idxTipo: idxTipo,
      isobscureText: isobscureText,  tokenUsuario: tokenUsuario, cnpjCliente: cnpjCliente);
  }
}

class MyHomePage extends StatefulWidget {
  final String idUsuario;
  final String periodoInicial;
  final String periodoFinal;
  final int idxTipo;
  final bool isobscureText;
  final String tokenUsuario;
  final String cnpjCliente;
  const MyHomePage({super.key, required this.idUsuario, required this.periodoInicial,  required this.periodoFinal ,
    required this.idxTipo , required this.isobscureText,  required this.tokenUsuario, required this.cnpjCliente});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String pesquisa = "-";
  late Future<List<WebCliente>> _fWebCliente;
  late Future<List<WebAnaliseArquivoXml>>? _fWebAnaliseArquivoXml;
  late Future<List<WebAnaliseArquivoXml>>? _fWebExportaArquivoXml;
  late List<WebCliente> listaClientes = [];
  late List<String> listaStatus = [];
  int offSet = 0, totalReg = 0, limiteReg = 21;
  bool isLoading = false;
  final int typeDevice = DeviceDetector.typeDevice(MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single));
  GlobalKey btnMenu = GlobalKey();
  late int idxClicado;
  var dataIniConrtroller   = TextEditingController();
  var dataFinConrtroller   = TextEditingController();
  var emailSuporteTecnico  = TextEditingController();
  var emailClienteContador = TextEditingController();
  late List<DropdownMenuItem<String>> menuModeloDocumento = [];
  var modeloSelecionado;
  var dataInicial, dataFinal;
  List<WebAnaliseArquivoXml> listaAnalise = [];
  List<WebAnaliseArquivoXml> listaExporta = [];
  bool check1 = false;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    //_fWebAnaliseArquivoXml = _getEmptyFuture();
    _fWebCliente  = _getWebCliente(offSet, limiteReg, false);
    //_getModeloDocumento();
    offSet = 21;

  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<WebCliente>> _getWebCliente(int offSet, int limiteReg, bool isAutoScrool ) async {
    if ( widget.idxTipo == 0) {
      final webClientes = FirebaseFirestore.instance
          .collection('clientes').doc(widget.cnpjCliente)
          .withConverter<WebCliente>(
        fromFirestore: (snapshot, _) => WebCliente.fromFirestore(snapshot),
        toFirestore: (webCliente, _) => webCliente.toFirestore(),
      );

      final querySnapshot = await webClientes.get();
      final WebCliente? cliente = querySnapshot.data();
      List<WebCliente> lista = [];
      lista.add(cliente!);
      if (lista.length >= 1) {
        if (isAutoScrool) {
          listaClientes.addAll(lista);
        }else {
          listaClientes.addAll(lista);
        }
      }
      setState(() {
      });
      return listaClientes;
    }
    /*
    List<WebCliente> lista = [];
    lista.addAll(await  ApiWebClienteTarefa(
        Dio(BaseOptions(contentType: "application/json")), baseUrl: "${await getUrlAPI()}/ws")
        .getWebClienteTarefa(widget.idUsuario.toString(), offSet, limiteReg, widget.periodoInicial, widget.periodoFinal,
        widget.idxTipo, widget.idxTipo == 0 ? widget.cnpjCliente : "-", widget.tokenUsuario));

    if (lista.length >= 1) {
      if (isAutoScrool) {
        listaClientes.addAll(lista);
      }else {
        listaClientes.addAll(lista);
      }
    }

     */
    setState(() {
    });
    return listaClientes;
  }

/*
  Future<List<DropdownMenuItem<String>>>  _getModeloDocumento() async {
      menuModeloDocumento.add(const DropdownMenuItem(value: '99',   child: Text('Todos documentos(NF-e/NFC-e/CT-e)')));
      menuModeloDocumento.add(const DropdownMenuItem(value: '55', child: Text('Nota fiscal eletronica(NF-e)')));
      menuModeloDocumento.add(const DropdownMenuItem(value: '65', child: Text('Nota fiscal eletronica ao consumidor(NFC-e)')));
      menuModeloDocumento.add(const DropdownMenuItem(value: '57', child: Text('Conhecimento de transporte eletronico(CT-e)')));
    return menuModeloDocumento;
  }
*/


  /*Future<List<WebAnaliseArquivoXml>> _getWebAnaliseArquivoXml(WebCliente webCliente, String codModelo, String dataInicial, String dataFinal, String idPeriodo ) async {
    listaAnalise.clear();
    try {
      listaAnalise.addAll(await ApiWebExportaAnaliseArquivoXml(
          Dio(BaseOptions(contentType: "application/json")),
          baseUrl: "${webCliente.url_api}/ws")
          .getWebExportaAnaliseArquivoXml(
          widget.idUsuario.toString(),
          dataInicial,
          dataFinal,
          codModelo,
          webCliente.cpf_cnpj,
          "N",
          widget.tokenUsuario));
    } on DioException catch (e) {
      print(e.error);
      print(e.requestOptions);
      print(e.message);
    }
    if ( listaAnalise.length == 0)  {
        return  _getEmptyFuture();
    }
    return listaAnalise;
  }*/

  /*Future<List<WebAnaliseArquivoXml>> _getWebAnaliseTodosArquivoXml(WebCliente webCliente,  String dataInicial, String dataFinal, String idPeriodo ) async {
    listaAnalise.clear();
    try {
      listaAnalise.addAll(await ApiWebExportaAnaliseTodosArquivoXml(
          Dio(BaseOptions(contentType: "application/json")),
          baseUrl: "${webCliente.url_api}/ws")
          .getWebExportaAnaliseTodosArquivoXml(
          widget.idUsuario.toString(),
          dataInicial,
          dataFinal,
          webCliente.cpf_cnpj,
          "N",
          widget.tokenUsuario));
    } on DioException catch (e) {
      print(e.error);
      print(e.requestOptions);
      print(e.message);
    }
    if ( listaAnalise.length == 0)  {
      return  _getEmptyFuture();
    }
    return listaAnalise;
  }*/

/*
  Future<List<WebAnaliseArquivoXml>> _getWebExportaArquivoXml(WebCliente webCliente, String codModelo ) async {
    listaExporta.clear();
    listaExporta.addAll(await  ApiWebExportaZipArquivoXml(
        Dio(BaseOptions(contentType: "application/json")), baseUrl: "${webCliente.url_api}/ws")
        .getWebExportaZipArquivoXml(widget.idUsuario.toString(), dataInicial, dataFinal, codModelo, webCliente.cpf_cnpj,
        emailClienteContador.text.isEmpty ? "-" : emailClienteContador.text, emailSuporteTecnico.text.isEmpty ? "-" : emailSuporteTecnico.text,
        "N", widget.tokenUsuario));
    return listaExporta;

  }

  Future<List<WebAnaliseArquivoXml>> _getWebExportaTodosArquivoXml(WebCliente webCliente ) async {
    listaExporta.clear();
    listaExporta.addAll(await  ApiWebExportaZipTodosArquivoXml(
        Dio(BaseOptions(contentType: "application/json")), baseUrl: "${webCliente.url_api}/ws")
        .getWebExportaZipTodosArquivoXml(widget.idUsuario.toString(), dataInicial, dataFinal, webCliente.cpf_cnpj,
        emailClienteContador.text.isEmpty ? "-" : emailClienteContador.text, emailSuporteTecnico.text.isEmpty ? "-" : emailSuporteTecnico.text,
        "N", widget.tokenUsuario));
    return listaExporta;

  }

  Future<List<WebAnaliseArquivoXml>> _getEmptyFuture( ) async {

    WebAnaliseArquivoXml webAnaliseArquivoXml = new WebAnaliseArquivoXml(id: '0', mensagem: "", sucesso: false, modelo: "",
    qtde_autorizadas: 0, qtde_canceladas: 0, qtde_contigencia: 0, qtde_cte: 0, qtde_emitidas: 0, qtde_inutilizadas: 0, qtde_nfe: 0, qtde_nfce: 0, qtde_terc: 0, qtde_outras: 0,
    status_exportacao: "", data_exportacao: "", hora_exportacao: "", email_exportacao_1: "", email_exportacao_2: "", data_agendamento: "");
    listaAnalise.add(webAnaliseArquivoXml);

    return listaAnalise;
  }
*/

  Future<String> getUrlAPI() async {
    String fileText = await rootBundle.loadString('assets/URLAPI.txt');
    return fileText.toString().trim();
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
          title: Text( widget.idxTipo == 0 ? "Tarefas do cliente": widget.idxTipo == 1 || widget.idxTipo == 4 ? 'Tarefas agendadas' : widget.idxTipo == 2 || widget.idxTipo == 5 ? 'Tarefas executadas' : 'Tarefas pendentes' ,
          )),
      body: FutureBuilder<List<WebCliente>>(
        future: _fWebCliente,
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
        },
      ),
    );
  }

  Card makeCard(WebCliente webCliente, int pos) =>
      Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4.0 ,
      color: Colors.white,
      //surfaceTintColor: webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red ,
      //shadowColor: webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red ,
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
                                              flex: 3,
                                              child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: <Widget>[
                                                   Card(
                                                       elevation: 0.0,
                                                       color: Colors.white,
                                                       child: TextFormField( textAlign: TextAlign.left,
                                                         controller:  TextEditingController()..text = webCliente.nome_cadastro,
                                                         obscureText: widget.isobscureText,
                                                         style: MyTextSample.medium(context).copyWith(
                                                           color: MyColorsSample.grey_80,
                                                         ),
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
                                                       child: TextField(
                                                           enabled: false,
                                                            maxLines: 1,
                                                           controller:  TextEditingController()..text = webCliente.nome_fantasia,
                                                           obscureText: widget.isobscureText,
                                                           style: MyTextSample.medium(context).copyWith(
                                                              color: MyColorsSample.grey_80,
                                                         ),
                                                       )),
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
                                                          controller: TextEditingController()..text = !webCliente.webStatusApi.sucesso ? "-" :
                                                              MascaraUtil()._formataData(webCliente.webStatusApi.dataHora.substring(0,10), "/", 10) + " " + webCliente.webStatusApi.dataHora.substring(11),//( _dadosStatus("http://192.168.100.68:725/rckexportaAPI1.0.0") )== true ? "ON LINE" : "OFF LINE",//_dadosStatus("192.168.100.68:725/rckexportaAPI1.0.0") == true ? "ON" : "OFF" ,
                                                          style: MyTextSample.medium(context).copyWith( color: MyColorsSample.grey_60/*webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red,*/ ),
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
                                        height: 0.5,
                                        decoration:
                                        BoxDecoration(color: MyColorsSample.grey_1),
                                        margin: new EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0.0),
                                      ),
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
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Data agendada',
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
                                                          controller: TextEditingController()..text = webCliente.status_exportacao_1.isEmpty ? "-" : webCliente.status_exportacao_1,
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
                                                          controller: TextEditingController()..text = webCliente.data_exportacao_2.isEmpty ? "-" : webCliente.data_exportacao_2,
                                                          //initialValue: "1",
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: webCliente.webStatusApi.qtdeNfeContigencia <= 0 ? MyColorsSample.grey_60 : Colors.red,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Data exportação',
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
                                                    controller: TextEditingController()..text = webCliente.webStatusExportacao.mensagem.isEmpty ? "-" :
                                                     webCliente.webStatusExportacao.mensagem,
                                                    //initialValue: "1",
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60 ,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'Mensagem da exportação',
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
                                                    controller: TextEditingController()..text = webCliente.webStatusExportacao.sucesso ?
                                                    webCliente.webStatusExportacao.email_exportacao_1 + (webCliente.webStatusExportacao.email_exportacao_2.isEmpty ? "" : "  -  " +webCliente.webStatusExportacao.email_exportacao_2)
                                                    : "-",
                                                    obscureText: widget.isobscureText,
                                                    //initialValue: "1",
                                                    style: MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60 ,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      labelText: 'Enviado para',
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

                                      /*Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Card(
                                                        elevation: 0.0,
                                                        color: Colors.white,
                                                        child: TextFormField(
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNotaEmitida.toString(),
                                                          style: webCliente.telefone_dois.isEmpty ? MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ) : MyTextSample.small(context).copyWith(
                                                            color: MyColorsSample.grey_60,),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Emitidas',
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
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNotaAutorizada.toString(),
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Autorizadas',
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
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNotaContigencia.toString(),
                                                          //initialValue: "1",
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: webCliente.webStatusApi.qtdeNotaContigencia <= 0 ? MyColorsSample.grey_60 : Colors.red,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Contigência',
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
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNotaCancelada.toString(),
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Canceladas',
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
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.qtdeNotaOutras.toString(),
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: webCliente.webStatusApi.qtdeNotaOutras <= 0 ? MyColorsSample.grey_60 : Colors.red,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Outras',
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
                                                          textAlign: TextAlign.left,
                                                          controller: TextEditingController()..text = webCliente.webStatusApi.sequenciaNumerica ? "OK" : "ERRO",
                                                          style: MyTextSample.medium(context).copyWith(
                                                            color: webCliente.webStatusApi.sequenciaNumerica ? MyColorsSample.grey_60 : Colors.red,
                                                          ),
                                                          enabled: false,
                                                          maxLines: 1,
                                                          decoration: InputDecoration(
                                                            labelText: 'Sequencia',
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
                                      ),*/
                                      /*Container(
                                        alignment: Alignment.bottomCenter,
                                        margin: new EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 16.0),
                                        decoration: BoxDecoration(
                                            color: MyColorsSample.rckapp,
                                            borderRadius: BorderRadius.circular(4)),
                                        child: TextButton(
                                          onPressed: () async {
                                            //_getWebAnaliseArquivoXml(webCliente, "55", 1);
                                            _showMyDialogDataIniDataFin(webCliente);
                                          },
                                          child: Text(
                                            'Analisar arquivos',
                                            style: TextStyle(
                                                color: MyColorsSample.white, fontSize: 16),
                                          ),
                                        ),
                                      ),*/

                                      ],
                                  ),
                                ),
                                //Produtos que alteram o preço sem a tabela(TKS)
                              ],
                            ),
                          ),

                        ],
                      ),
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
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:   typeDevice   <= 2  ? 1 : typeDevice == 3 ? 3 : 5 ,
                        childAspectRatio: typeDevice == 1 ? 1.2 : typeDevice == 2 ? 5 / 2.2 : typeDevice == 3 ? 5/2.2 : 5/2.2),
                        //childAspectRatio: typeDevice == 1 ? 1.2 : typeDevice == 2 ? 5/1.8 : 5/1.7),
                    itemCount: listaClientes.length,
                    ///controller: _scrollController,
                    //physics: const NeverScrollableScrollPhysics(),//BouncingScrollPhysics() ,//AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return makeCard(listaClientes[index], index);
                    }
                )
             ),
          ],
        ),
      )
    )
  );

  /*Widget createResultCardAnalise(webCliente){
    emailClienteContador.text = webCliente.email_principal;
    emailSuporteTecnico.text = webCliente.email_financeiro;
    if ( modeloSelecionado == "99") {
      _fWebAnaliseArquivoXml = _getWebAnaliseTodosArquivoXml(
          webCliente,  dataInicial, dataFinal, "1");
    } else {
      _fWebAnaliseArquivoXml = _getWebAnaliseArquivoXml(
          webCliente, modeloSelecionado, dataInicial, dataFinal, "1");
    }

    return Card(
        elevation: 00.0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child:  FutureBuilder<List<WebAnaliseArquivoXml>>(
          future: _fWebAnaliseArquivoXml,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                              child: InkWell(
                                onTap: () async {
                                  _showToast(context, listaAnalise[0].mensagem, 3);
                                },
                                child: Column(
                                   children: [
                                       Checkbox(
                                           value: true,
                                           checkColor: Colors.white,
                                           fillColor: listaAnalise![0].sucesso ? MaterialStateProperty.all(MyColorsSample.rckapp) : MaterialStateProperty.all(Colors.red),
                                           onChanged: (bool? selected) {
                                      ///Your logic here
                                           }),
                                       const Text("Contingencia"),
                                   ],
                                ),
                              ),
                          ),
                          Container( width: typeDevice <=2 ? 8 : 16,),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Checkbox(
                                    value: true,
                                    checkColor: Colors.white,
                                    fillColor: listaAnalise![3].sucesso ? MaterialStateProperty.all(MyColorsSample.rckapp) : MaterialStateProperty.all(Colors.red),
                                    onChanged: (bool? selected) {
                                      ///Your logic here
                                    }),
                                const Text("Primeiro n° do mes"),
                              ],
                            ),
                          ),
                      ]),
                    Container(height: typeDevice == 1 ? 4: 8),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: InkWell(
                                onTap: () async {
                                   _showToast(context, listaAnalise![1].mensagem, 3);
                                },
                                child: Column(
                                    children: [
                                       Checkbox(
                                          value: true,
                                          checkColor: Colors.white,
                                          fillColor: listaAnalise![1].sucesso ? MaterialStateProperty.all(MyColorsSample.rckapp) : MaterialStateProperty.all(Colors.red),
                                          onChanged: (bool? selected) {
                                      ///Your logic here
                                          }),
                                       const Text("Status desconhecido"),
                                    ],
                                ),
                            )
                          ),
                          Container( width: typeDevice <=2 ? 8 : 16,),
                          Expanded(
                            flex: 1,
                               child: InkWell(
                                  onTap: () async {
                                     _showToast(context, listaAnalise![2].mensagem, 3);
                                  },
                                  child: Column(
                                       children: [
                                           Checkbox(
                                               value: true,
                                               checkColor: Colors.white,
                                               fillColor: listaAnalise![2].sucesso ? MaterialStateProperty.all(MyColorsSample.rckapp) : MaterialStateProperty.all(Colors.red),
                                               onChanged: (bool? selected) {
                                               }),
                                           const Text("Sequencia númerica"),
                                       ],
                                  )
                               ),
                          ),
                        ]),
                    Divider(height: typeDevice == 1 ? 8 : 16),
                    Container(height: typeDevice == 1 ? 4 : 16),
                    Visibility(
                      visible: typeDevice <= 2 ? false : true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Card(
                                elevation: 0.0,
                                color: Colors.white,
                                child: TextFormField( textAlign: TextAlign.left,
                                  controller:  emailClienteContador,
                                  style: MyTextSample.medium(context).copyWith(
                                    color: MyColorsSample.grey_80,
                                  ),
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail do destinatario(1)',
                                    isDense: true,
                                    //border: InputBorder.none,
                                    labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                  ),
                                  onChanged: (value) {
                                    emailClienteContador.text = value;
                                    //descontoPercController.text = newText;
                                  },
                                )),
                          ),
                          Container(width: 32,),
                          Expanded(
                            flex: 1,
                            child: Card(
                                elevation: 0.0,
                                color: Colors.white,
                                child: TextFormField( textAlign: TextAlign.left,
                                  controller: emailSuporteTecnico,

                                  style: MyTextSample.medium(context).copyWith(
                                    color: MyColorsSample.grey_80,
                                  ),
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail do destinatario(2)',
                                    isDense: true,
                                    //border: InputBorder.none,
                                    labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                  ),
                                  onChanged: (value) {
                                    emailSuporteTecnico.text = value;
                                    //descontoPercController.text = newText;
                                  },
                                )),
                          ),
                    ]),
                    ),
                    Visibility(
                      visible: typeDevice <= 2 ? true : false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                              Card(
                                  elevation: 0.0,
                                  color: Colors.white,
                                  child: TextFormField( textAlign: TextAlign.left,
                                    controller:  emailClienteContador,
                                    style: MyTextSample.medium(context).copyWith(
                                      color: MyColorsSample.grey_80,
                                    ),
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'E-mail do destinatario(1)',
                                      isDense: true,
                                      border: InputBorder.none,
                                      labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                    ),
                                    onChanged: (value) {
                                      emailClienteContador.text = value;
                                      //descontoPercController.text = newText;
                                    },
                                  )),

                            Card(
                                  elevation: 0.0,
                                  color: Colors.white,
                                  child: TextFormField( textAlign: TextAlign.left,
                                    controller:  emailSuporteTecnico,
                                    style: MyTextSample.medium(context).copyWith(
                                      color: MyColorsSample.grey_80,
                                    ),
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'E-mail do destinatario(2)',
                                      isDense: true,
                                      border: InputBorder.none,
                                      labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                    ),
                                    onChanged: (value) {
                                      emailSuporteTecnico.text = value;
                                      //descontoPercController.text = newText;
                                    },
                                  )),

                         ]
                      )
                    ),
                    Divider(height: typeDevice == 1 ? 8 : 16),
                    Container(height: typeDevice == 1 ? 4 : 16),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 0.0),
                      decoration: BoxDecoration(
                          color: MyColorsSample.rckapp,
                          borderRadius: BorderRadius.circular(4)),
                      child: TextButton(
                        onPressed: () async {
                          if( listaAnalise.length > 0) {
                            if ( listaAnalise[0].sucesso && listaAnalise[1].sucesso && listaAnalise[2].sucesso && listaAnalise[3].sucesso) {
                              _showResultExportaXml(
                                  webCliente, modeloSelecionado);
                              return;
                            }
                          }
                          _showToast(context, "Necessário a validação de todos os documentos antes de efetuar a exportação!", 3);
                        },
                        child: Text(
                          'Exportar arquivos XML',
                          style: TextStyle(
                              color: MyColorsSample.white, fontSize: 16),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      decoration: BoxDecoration(
                          color: MyColorsSample.white,
                          borderRadius: BorderRadius.circular(4)),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                              color: MyColorsSample.grey_80, fontSize: 16),
                        ),
                      ),
                    ),
                  ]
              );
            } else {
              return Center(
                //widthFactor: 4,
                heightFactor: 4,
                child: CircularProgressIndicator(color: MyColorsSample.rckapp, semanticsLabel: 'Aguarde...',),
              );
            }
          },
        )
    );
  }*/

  /*Widget createResultCardExporta( webCliente  ){
    if ( modeloSelecionado == "99") {
      _fWebExportaArquivoXml =
          _getWebExportaTodosArquivoXml(webCliente);
    } else {
      _fWebExportaArquivoXml =
          _getWebExportaArquivoXml(webCliente, modeloSelecionado);
    }
    return Card(
        elevation: 00.0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child:  FutureBuilder<List<WebAnaliseArquivoXml>>(
          future: _fWebExportaArquivoXml,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Card(
                        elevation: 0.0,
                        color: Colors.white,
                        child: TextFormField( textAlign: TextAlign.left,
                          controller:  TextEditingController()..text = listaExporta[0].mensagem ,
                          style: MyTextSample.medium(context).copyWith(
                            color: MyColorsSample.grey_80,
                          ),
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: '',
                            isDense: true,
                            //border: InputBorder.none,
                            labelStyle: MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          ),
                        )),

                    Container(
                      alignment: Alignment.bottomCenter,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      decoration: BoxDecoration(
                          color: MyColorsSample.white,
                          borderRadius: BorderRadius.circular(4)),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Fechar',
                          style: TextStyle(
                              color: MyColorsSample.grey_80, fontSize: 16),
                        ),
                      ),
                    ),
                  ]
              );
            } else {
              return Center(
                //widthFactor: 4,
                heightFactor: 4,
                child: CircularProgressIndicator(color: MyColorsSample.rckapp, semanticsLabel: 'Aguarde...',),
              );
            }
          },
        )
    );
  }*/

  /*Future<void> _showMyDialogDataIniDataFin(WebCliente webCliente) async {
    //await _getModeloDocumento();
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6))),
          icon: Icon(
              Icons.calendar_month),
          title: const Text('Atenção!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Informe a data inicial e final para a analise dos arquivos!',  style: TextStyle(color: Colors.black87, fontSize: 16)),
              ],
            ),
          ),
          actions: <Widget>[
            Visibility(
               visible: typeDevice <= 2 ? false : true,
                child:  Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     Expanded(
                     flex: 1,
                      child: Card(
                         shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 00.0,
                      color: Colors.white,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Container(
                    decoration: BoxDecoration(color: MyColorsSample.white),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              //constraints: BoxConstraints.expand(
                              //    height: 100.0, width: 130.0),
                              child: TextFormField(
                                  controller: dataIniConrtroller,
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.calendar_today),
                                      //icon of text field
                                      labelStyle: TextStyle(
                                        color: MyColorsSample.black,
                                      ),
                                      labelText: "Data inicial" //label text of field
                                  ),
                                  readOnly: true,
                                  style: MyTextSample.medium(context).copyWith(color: MyColorsSample.grey_80,),
                                  //set it true, so that user will not able to edit text
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        cancelText: "Cancelar",
                                        confirmText: "Confirmar",
                                        fieldLabelText: "Informe a data inicial",
                                        context: context,


                                        //locale: Locale('pt', 'BR'),//locale: const Locale("pt", "PT"),
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(DateTime.now().year - 1),
                                        lastDate: DateTime(DateTime.now().year + 30),
                                        builder: (context, child) {
                                           return Theme(
                                              data: Theme.of(context).copyWith(
                                                  colorScheme: ColorScheme.light(
                                                      primary: MyColorsSample.rckapp, // <-- SEE HERE
                                                     //onPrimary: Colors.redAccent, // <-- SEE HERE
                                                     //onSurface: Colors.blueAccent, // <-- SEE HERE
                                                  ),
                                                  textButtonTheme: TextButtonThemeData(
                                                     style: TextButton.styleFrom(
                                                        //primary: Colors.red, // button text color
                                                      ),
                                                   ),
                                              ),
                                              child: child!,
                                          );
                                        },
                                    );
                                    if (pickedDate != null) {
                                      //DateTime dataFinal = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                      //DateTime dataSelec = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                      //if(dataFinal.compareTo(dataSelec) > 0){
                                        //_showToast(context, "Data selecionada é inválida", 2, false);
                                        //return;
                                      //}
                                      dataIniConrtroller.text = DateFormat('dd/MM/yyyy').format(pickedDate).toString(); //set o
                                      dataInicial = DateFormat('yyyy-MM-dd').format(pickedDate).toString();
                                    }
                                  }

                              )
                          ),
                        ]
                    )
                )
                      )),
                     Expanded(
                    flex: 1,
                    child:Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 00.0,
                color: Colors.white,
                margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                    decoration: BoxDecoration(color: MyColorsSample.white),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              //constraints: BoxConstraints.expand(
                              //    height: 100.0, width: 130.0),
                             child: TextFormField(
                                controller: dataFinConrtroller,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.calendar_today),
                                    //icon of text field
                                    labelStyle: TextStyle(
                                        color: MyColorsSample.black,
                                    ),
                                    labelText: "Data final" //label text of field
                                ),
                                readOnly: true,
                                style: MyTextSample.medium(context).copyWith(color: MyColorsSample.grey_80,),
                                //set it true, so that user will not able to edit text
                                 onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        cancelText: "Cancelar",
                                        confirmText: "Confirmar",
                                        fieldLabelText: "Informe a data final",
                                        //locale: Locale('pt', 'BR'),//locale: const Locale("pt", "PT"),
                                         context: context,
                                         initialDate: DateTime.now(),
                                         firstDate: DateTime(DateTime.now().year -1 ),
                                         lastDate: DateTime(DateTime.now().year + 30),
                                         builder: (context, child) {
                                             return Theme(
                                                data: Theme.of(context).copyWith(
                                                   colorScheme: ColorScheme.light(
                                                      primary: MyColorsSample.rckapp, // <-- SEE HERE
                                                      //onPrimary: Colors.redAccent, // <-- SEE HERE
                                                      //onSurface: Colors.blueAccent, // <-- SEE HERE
                                                   ),
                                                   textButtonTheme: TextButtonThemeData(
                                                      style: TextButton.styleFrom(
                                                        //primary: Colors.red, // button text color
                                                      ),
                                                   ),
                                                ),
                                                child: child!,
                                             );
                                         },
                                    );
                                    if (pickedDate != null) {
                                        //DateTime dataFinal = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                        //DateTime dataSelec = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                        //if(dataFinal.compareTo(dataSelec) > 0){
                                        //_showToast(context, "Data selecionada é inválida", 2, false);
                                        //    return;
                                        //}
                                        dataFinConrtroller.text = DateFormat('dd/MM/yyyy').format(pickedDate).toString(); //set o
                                        dataFinal = DateFormat('yyyy-MM-dd').format(pickedDate).toString();
                                    }
                                 }

                             )
                          ),
                        ]
                    )
                )
            ),
                ),
                     Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    items: menuModeloDocumento,
                    isExpanded: true,
                    //value: prazoSelecionado,
                    hint: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Selecione",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    onChanged: (String? value) {
                      modeloSelecionado = value;
                      setState(() {});
                    },
                    style: MyTextSample.medium(context)
                        .copyWith(
                      color: MyColorsSample.grey_80,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Modelo de documemto',
                    ),
                  ),
                     )
                ])
            ),
            Visibility(
                visible: typeDevice <= 2 ? true : false,
                child: Column(
                    children: <Widget>[
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                          Expanded(
                          flex: 1,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 00.0,
                              color: Colors.white,
                              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                  decoration: BoxDecoration(color: MyColorsSample.white),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            //constraints: BoxConstraints.expand(
                                            //    height: 100.0, width: 130.0),
                                            child: TextFormField(
                                                controller: dataIniConrtroller,
                                                decoration: InputDecoration(
                                                    icon: Icon(Icons.calendar_today),
                                                    //icon of text field
                                                    labelStyle: TextStyle(
                                                      color: MyColorsSample.black,
                                                    ),
                                                    labelText: "Data inicial" //label text of field
                                                ),
                                                readOnly: true,
                                                style: MyTextSample.medium(context).copyWith(color: MyColorsSample.grey_80,),
                                                //set it true, so that user will not able to edit text
                                                onTap: () async {
                                                  DateTime? pickedDate = await showDatePicker(
                                                      cancelText: "Cancelar",
                                                      confirmText: "Confirmar",
                                                      fieldLabelText: "Informe a data inicial",
                                                      context: context,
                                                      //locale: Locale('pt', 'BR'),//locale: const Locale("pt", "PT"),
                                                      initialDate: DateTime.now(),
                                                      firstDate: DateTime(DateTime.now().year - 6),
                                                      lastDate: DateTime(DateTime.now().year + 30),
                                                      builder: (context, child) {
                                                         return Theme(
                                                            data: Theme.of(context).copyWith(
                                                                colorScheme: ColorScheme.light(
                                                                   primary: MyColorsSample.rckapp, // <-- SEE HERE
                                                                   //onPrimary: Colors.redAccent, // <-- SEE HERE
                                                                   //onSurface: Colors.blueAccent, // <-- SEE HERE
                                                                ),
                                                                textButtonTheme: TextButtonThemeData(
                                                                    style: TextButton.styleFrom(
                                                              //primary: Colors.red, // button text color
                                                                    ),
                                                                ),
                                                            ),
                                                            child: child!,
                                                         );
                                                      },
                                                  );
                                                  if (pickedDate != null) {
                                                    //DateTime dataFinal = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                                    //DateTime dataSelec = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                                    //if(dataFinal.compareTo(dataSelec) > 0){
                                                    //_showToast(context, "Data selecionada é inválida", 2, false);
                                                    //return;
                                                    //}
                                                    dataIniConrtroller.text = typeDevice == 1 ? DateFormat('dd/MM/yy').format(pickedDate).toString() : DateFormat('dd/MM/yyyy').format(pickedDate).toString(); //set o
                                                    dataInicial = DateFormat('yyyy-MM-dd').format(pickedDate).toString();
                                                  }
                                                }

                                            )
                                        ),
                                      ]
                                  )
                              )
                          )),
                          Expanded(
                        flex: 1,
                        child:Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 00.0,
                            color: Colors.white,
                            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Container(
                                decoration: BoxDecoration(color: MyColorsSample.white),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          //constraints: BoxConstraints.expand(
                                          //    height: 100.0, width: 130.0),
                                          child: TextFormField(
                                              controller: dataFinConrtroller,
                                              decoration: InputDecoration(
                                                  icon: Icon(Icons.calendar_today),
                                                  //icon of text field
                                                  labelStyle: TextStyle(
                                                    color: MyColorsSample.black,
                                                  ),
                                                  labelText: "Data final" //label text of field
                                              ),
                                              readOnly: true,
                                              style: MyTextSample.medium(context).copyWith(color: MyColorsSample.grey_80,),
                                              //set it true, so that user will not able to edit text
                                              onTap: () async {
                                                DateTime? pickedDate = await showDatePicker(
                                                    cancelText: "Cancelar",
                                                    confirmText: "Confirmar",
                                                    fieldLabelText: "Informe a data final",
                                                    context: context,
                                                    //locale: Locale('pt', 'BR'),//locale: const Locale("pt", "PT"),
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(DateTime.now().year -6 ),
                                                    lastDate: DateTime(DateTime.now().year + 30),
                                                    builder: (context, child) {
                                                       return Theme(
                                                           data: Theme.of(context).copyWith(
                                                              colorScheme: ColorScheme.light(
                                                                 primary: MyColorsSample.rckapp, // <-- SEE HERE
                                                              //onPrimary: Colors.redAccent, // <-- SEE HERE
                                                              //onSurface: Colors.blueAccent, // <-- SEE HERE
                                                               ),
                                                             textButtonTheme: TextButtonThemeData(
                                                             style: TextButton.styleFrom(
                                                                 //primary: Colors.red, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                           child: child!,
                                                       );
                                                    },
                                                );
                                                if (pickedDate != null) {
                                                  //DateTime dataFinal = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                                  //DateTime dataSelec = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                                  //if(dataFinal.compareTo(dataSelec) > 0){
                                                  //_showToast(context, "Data selecionada é inválida", 2, false);
                                                  //    return;
                                                  //}
                                                  dataFinConrtroller.text = typeDevice == 1 ? DateFormat('dd/MM/yy').format(pickedDate).toString() : DateFormat('dd/MM/yyyy').format(pickedDate).toString(); //set o
                                                  dataFinal = DateFormat('yyyy-MM-dd').format(pickedDate).toString();
                                                }
                                              }

                                          )
                                      ),
                                    ]
                                )
                            )
                        ),
                      ),
                      ]),
                      Container( height: 4,),
                      DropdownButtonFormField<String>(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        items: menuModeloDocumento,
                        isExpanded: true,
                        //value: prazoSelecionado,
                        hint: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Selecione",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        onChanged: (String? value) {
                          modeloSelecionado = value;
                          setState(() {});
                        },
                        style: MyTextSample.medium(context)
                            .copyWith(
                          color: MyColorsSample.grey_80,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Modelo de documemto',
                        ),
                      ),
                    ])
            ),
            Container(height: typeDevice <= 2 ? 16 : 24,),
            *//*
            Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Checkbox(
                                value: true,
                                onChanged: (bool? selected) {

                                }),
                            const Text("Contigencia"),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Switch(
                                value: check1,
                                onChanged: (bool? selected) {
                                  ///Your logic here
                                }),
                            const Text("Primeiro n° do mes"),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Checkbox(
                                value: false,
                                onChanged: (bool? selected) {
                                  ///Your logic here
                                }),
                            const Text("Status desconhecido"),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Checkbox(
                                value: false,
                                onChanged: (bool? selected) {
                                  ///Your logic here
                                }),
                            const Text("Sequencia númerica"),
                          ],
                        ),
                      ),
                    ]),

             *//*
            Container(
              alignment: Alignment.bottomCenter,
              margin: new EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                  color: MyColorsSample.rckapp,
                  borderRadius: BorderRadius.circular(4)),
              child: TextButton(
                onPressed: () async {
                  //await _getWebAnaliseArquivoXml(webCliente, codModelo, dataInicial, dataFinal, idPeriodo)
                  _showResultAnaliseXml(webCliente, modeloSelecionado);
                },
                child: Text(
                  'Analisar',
                  style: TextStyle(
                      color: MyColorsSample.white, fontSize: 16),
                ),
              ),
            ),
            Container(
                 alignment: Alignment.bottomCenter,
                 margin: new EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                  color: MyColorsSample.white,
                  borderRadius: BorderRadius.circular(4)),
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                      color: MyColorsSample.grey_80, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }*/

  /*Future<void> _showResultAnaliseXml( WebCliente webCliente, String codModelo) async {
    emailClienteContador.text = webCliente.email_principal;
    emailSuporteTecnico.text = webCliente.email_financeiro;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6))),
            icon: Icon(
                Icons.check),
            title: Text('Atenção!',style: TextStyle(color: Colors.black87, fontSize: typeDevice == 1 ? 12 : 16)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                   Text('Resultado da analise!',  style: TextStyle(color: Colors.black87, fontSize: typeDevice == 1 ? 12 : 16)),
                ],
              ),
            ),
            actions: <Widget>[
              createResultCardAnalise(webCliente ),
            ]
        );
      },
    );
  }*/

  /*Future<void> _showResultExportaXml( WebCliente webCliente, String codModelo) async {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6))),
            icon: Icon(
                Icons.check),
            title: Text('Atenção!',style: TextStyle(color: Colors.black87, fontSize: typeDevice == 1 ? 12 : 16)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Resultado da exportação!',  style: TextStyle(color: Colors.black87, fontSize: typeDevice == 1 ? 12 : 16)),
                ],
              ),
            ),
            actions: <Widget>[
              createResultCardExporta( webCliente),
            ]
        );
      },
    );
  }*/


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
    if (  diagonal > 1100.0 && diagonal < 2100.0) {
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
}


