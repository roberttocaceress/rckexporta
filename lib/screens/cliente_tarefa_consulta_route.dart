import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';

import '../main.dart';
import '../model/web_status_exportacao.dart';
import '../util/DeviceDetector.dart';
import '../util/Mascaras.dart';
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
  late Future<List<WebCliente>> _fWebCliente;
  late List<WebCliente> listaClientes = [];
  bool isLoading = false;
  final int typeDevice = DeviceDetector().typeDevice1(MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single));
  GlobalKey btnMenu = GlobalKey();
  late int idxClicado;
  var dataIniConrtroller   = TextEditingController();
  var dataFinConrtroller   = TextEditingController();
  var emailSuporteTecnico  = TextEditingController();
  var emailClienteContador = TextEditingController();
   bool check1 = false;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    _fWebCliente  = _getWebCliente();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<WebCliente>> _getWebCliente( ) async {
    final db = FirebaseFirestore.instance;
    String mesAno  = DateFormat('yyyy-MM').format(DateTime.now());
    if ( widget.idxTipo == 0) {
      final webClientes = db.collection('clientes').doc(widget.cnpjCliente)
          .withConverter<WebCliente>(
        fromFirestore: (snapshot, _) => WebCliente.fromFirestore(snapshot),
        toFirestore: (webCliente, _) => webCliente.toFirestore(),
      );
      final queryCliente = await webClientes.get();
      final WebCliente? webCliente = queryCliente.data();
      if (webCliente == null) return [];
      //Pegar o status da exportacao
      var webExportacao = db.collection('clientes').doc(webCliente.cpf_cnpj).collection("exportacao").doc("$mesAno-${webCliente.data_exportacao_1}")
          .withConverter<WebStatusExportacao>(
        fromFirestore: (snapshot, _) => WebStatusExportacao.fromFirestore(snapshot),
        toFirestore: (webStatusExportao, _) => webStatusExportao.toFirestore(),
      );
      final queryExportacao = await webExportacao.get();
      webCliente.webStatusExportacao = queryExportacao.data()  ?? WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
          qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
          qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
          qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
          qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
          sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
          email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: "");

      if ( !webCliente.webStatusExportacao.sucesso) {
        var webExportacao = db.collection('clientes').doc(webCliente.cpf_cnpj).collection("erro-exportacao-dados-invalidos").doc("$mesAno-${webCliente.data_exportacao_1}")
            .withConverter<WebStatusExportacao>(
          fromFirestore: (snapshot, _) => WebStatusExportacao.fromFirestore(snapshot),
          toFirestore: (webStatusExportao, _) => webStatusExportao.toFirestore(),
        );
        final queryExportacao = await webExportacao.get();
        webCliente.webStatusDadosInvalido = queryExportacao.data()  ?? WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
            email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: "");

      }


      //Pega o status da API
      var webStatus = db.collection('clientes').doc(webCliente.cpf_cnpj).collection("statusapi").doc(widget.cnpjCliente)
          .withConverter<WebStatusApi>(
        fromFirestore: (snapshot, _) => WebStatusApi.fromFirestore(snapshot),
        toFirestore: (webStatusApi, _) => webStatusApi.toFirestore(),
      );
      var queryStatus = await webStatus.get();
      webCliente.webStatusApi = queryStatus.data() ?? WebStatusApi( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
          qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
          qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
          qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
          qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
          sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, nfeContigencia: [], nfceContigencia: [], nfeOutras: [], nfceOutras: [], nfeCancelada: [], nfceCancelada: [] );
      List<WebCliente> lista = [];
      lista.add(webCliente);
      setState(() {
        listaClientes.addAll(lista);
      });
      return listaClientes;
    }
    final webClientes = db
        .collection('clientes').orderBy("razao_social")
        .withConverter<WebCliente>(
      fromFirestore: (snapshot, _) => WebCliente.fromFirestore(snapshot),
      toFirestore: (webCliente, _) => webCliente.toFirestore(),
    );
    final queryWebCliente = await webClientes.get();
    setState(() {
      listaClientes.addAll(queryWebCliente.docs.map((doc) => doc.data()).toList());
    });

    final webStatusExportacao = db
        .collectionGroup('exportacao')
        .where('data_exportacao', isGreaterThanOrEqualTo: mesAno)
        .where('data_exportacao', isLessThanOrEqualTo: '$mesAno\uf8ff')
        .withConverter<WebStatusExportacao>(
      fromFirestore: (snapshot, _) => WebStatusExportacao.fromFirestore(snapshot),
      toFirestore: (webStatusExportacao, _) => webStatusExportacao.toFirestore(),
    );
    final queryWebStatusExportacao = await webStatusExportacao.get();
    final listaStatusExportacao = queryWebStatusExportacao.docs.map((doc) => doc.data()).toList();
//
    final webStatusApi = db
        .collectionGroup('statusapi')
        .withConverter<WebStatusApi>(
      fromFirestore: (snapshot, _) => WebStatusApi.fromFirestore(snapshot),
      toFirestore: (webStatusApi, _) => webStatusApi.toFirestore(),
    );
    final queryWebStatusApi = await webStatusApi.get();
    final listaStatusApi = queryWebStatusApi.docs.map((doc) => doc.data()).toList();

    final webStatusExportacaoDadosInvalidos = db
        .collectionGroup('erro-exportacao-dados-invalidos')
        .where('dataHora', /*isEqualTo: '2026-02-02'*/isGreaterThanOrEqualTo: mesAno)
        .where('dataHora', isLessThanOrEqualTo: '$mesAno\uf8ff')
        .withConverter<WebStatusExportacao>(
      fromFirestore: (snapshot, _) => WebStatusExportacao.fromFirestore(snapshot),
      toFirestore: (webStatusExportacao, _) => webStatusExportacao.toFirestore(),
    );
    final queryWebStatusExportacaoDadosInvalidos = await webStatusExportacaoDadosInvalidos.get();
    final listaStatusExportacaoDadosInvalidos = queryWebStatusExportacaoDadosInvalidos.docs.map((doc) => doc.data()).toList();

    if (widget.idxTipo == 3 || widget.idxTipo == 6) {
     for (WebStatusExportacao webStatusExportacao in listaStatusExportacao) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusExportacao.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes.removeWhere((item) => item.cpf_cnpj == listaClientes[index].cpf_cnpj);
          }
        });
      }

      for (WebStatusApi webStatusApi in listaStatusApi) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusApi.cnpj);
        setState(() {
          if (index != -1) {
             listaClientes[listaClientes.indexWhere((item) =>
             item.cpf_cnpj == webStatusApi.cnpj)].webStatusApi =
                webStatusApi;
          }
        });
      }

      for (WebStatusExportacao webStatusDadosInvalidos in listaStatusExportacaoDadosInvalidos) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusDadosInvalidos.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusDadosInvalidos.cnpj)].webStatusDadosInvalido =
                webStatusDadosInvalidos;
          }
        });
      }
      return listaClientes;
    }
    if (widget.idxTipo == 2 || widget.idxTipo == 5) {
        for (WebCliente webCliente in listaClientes) {
        final index = listaStatusExportacao.indexWhere((item) => item.cnpj == webCliente.cpf_cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webCliente.cpf_cnpj)].webStatusExportacao =  listaStatusExportacao[index];
          } else {
            listaClientes.removeWhere((item) => item.cpf_cnpj == webCliente.cpf_cnpj);
          }
        });
      }
      setState(() {
        listaClientes;
      });
      for (WebStatusApi webStatusApi in listaStatusApi) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusApi.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusApi.cnpj)].webStatusApi =
                webStatusApi;
          }
        });
      }
      for (WebStatusExportacao webStatusDadosInvalidos in listaStatusExportacaoDadosInvalidos) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusDadosInvalidos.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusDadosInvalidos.cnpj)].webStatusDadosInvalido =
                webStatusDadosInvalidos;
          }
        });
      }
      //setState(() {
      //});
      return listaClientes;
    }
    if (widget.idxTipo == 1 || widget.idxTipo == 4) {
      for (WebStatusExportacao webStatusExportacao in listaStatusExportacao) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusExportacao.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusExportacao.cnpj)].webStatusExportacao = webStatusExportacao;
          }
        });
      }
      //setState(() {
      //  listaClientes;
      //});
      for (WebStatusApi webStatusApi in listaStatusApi) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusApi.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusApi.cnpj)].webStatusApi =
                webStatusApi;
          }
        });
      }
      for (WebStatusExportacao webStatusDadosInvalidos in listaStatusExportacaoDadosInvalidos) {
        final index = listaClientes.indexWhere((item) => item.cpf_cnpj == webStatusDadosInvalidos.cnpj);
        setState(() {
          if (index != -1) {
            listaClientes[listaClientes.indexWhere((item) =>
            item.cpf_cnpj == webStatusDadosInvalidos.cnpj)].webStatusDadosInvalido =
                webStatusDadosInvalidos;
          }
        });
      }
      //setState(() {
      //});
      return listaClientes;
    }
    //setState(() {
    //});
    return listaClientes;
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

  Card makeCard(WebCliente cliente) {
    // Garantir que webStatusApi não seja nulo para evitar crashes iniciais
    final statusApi = cliente.webStatusApi;
    
    final bool isOnlineMes = isSameMontYear(statusApi.dataHora);
    if (!isOnlineMes) {
      statusApi.qtdeNfeEmitida = 0;
      statusApi.qtdeNfeAutorizada = 0;
      statusApi.qtdeNfeContigencia = 0;
      statusApi.qtdeNfceEmitida = 0;
      statusApi.qtdeNfceAutorizada = 0;
      statusApi.qtdeNfceContigencia = 0;
    }

    // Função auxiliar para formatar listas de forma segura
    String formatList(dynamic list) {
      if (list == null || list is! Iterable || list.isEmpty) {
        return "0";
      }
      return "Nº (${list.join(", ")})";
    }

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- LINHA 1: CABEÇALHO COM NOME E STATUS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Coluna para Razão Social e Nome Fantasia
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Razão Social com destaque
                      Text(
                        cliente.nome_cadastro,
                        style: MyTextSample.subhead(context)?.copyWith(
                          color: MyColorsSample.grey_90,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Nome Fantasia (se houver)
                      if (cliente.nome_fantasia.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            cliente.nome_fantasia,
                            style: MyTextSample.body1(context)?.copyWith(
                              color: MyColorsSample.grey_60,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      if (cliente.cpf_cnpj.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            Mascaras().mascaraCnpj(cliente.cpf_cnpj),
                            style: MyTextSample.body1(context)?.copyWith(
                              color: MyColorsSample.grey_60,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chip de Status (Ativo/Inativo)
                _buildStatusApi("", cliente),
              ],
            ),
            const SizedBox(height: 0.0),
            const Divider(),
            const SizedBox(height: 0),
            const SizedBox(height: 4.0),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              text: "",
            ),
            const SizedBox(height: 8.0),
            Visibility(
               visible: cliente.webStatusExportacao.sucesso ? false : true,
                child: _buildInfoRow(
                  icon: Icons.error,
                  text: cliente.webStatusDadosInvalido.mensagem ,
              ),
            ),
            Visibility(
              visible: cliente.webStatusExportacao.sucesso ? false : true,
              child: SizedBox(height: 8.0)
            ),

            //),
            _buildInfoRow(
              icon:  cliente.webStatusExportacao.sucesso ? Icons.check_circle : Icons.error,
              text: Mascaras().mascaraDataHora(cliente.webStatusExportacao.dataHora) ,
            ),
            const SizedBox(height: 8.0),
            Visibility(
              visible: cliente.webStatusExportacao.sucesso ? true : false,
              child: _buildInfoRow(
                icon: Icons.email_outlined,
                text: "${cliente.webStatusExportacao.email_exportacao_1} ${cliente.webStatusExportacao.email_exportacao_2}",
              ),
            ),
            Visibility(
                visible: cliente.webStatusExportacao.sucesso ? true : false,
                child: SizedBox(height: 8.0)
            ),

            _buildInfoRow(
              icon: Icons.calendar_month,
              text: "Este Mês",
            ),

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

                          if (typeDevice > 2) 
                            _buildStatusField(
                              label: "NF-e Emitidas",
                              value: statusApi.qtdeNfeEmitida.toString(),
                              valueColor:  statusApi.qtdeNfeEmitida != statusApi.qtdeNfeAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          if (typeDevice > 2)
                            _buildStatusField(
                              label: "NF-e Autorizadas",
                              value: statusApi.qtdeNfeAutorizada.toString(),
                              valueColor:  statusApi.qtdeNfeEmitida != statusApi.qtdeNfeAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          if (typeDevice <= 2)
                            _buildStatusField(
                              label: "NF-e Em./Aut.",
                              value: "${statusApi.qtdeNfeEmitida} / ${statusApi.qtdeNfeAutorizada}",
                              valueColor:  statusApi.qtdeNfeEmitida != statusApi.qtdeNfeAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),

                          _buildStatusField(
                            label: "NF-e Conting.",
                            value: statusApi.qtdeNfeContigencia.toString(),
                            valueColor: statusApi.qtdeNfeContigencia > 0
                                ? Colors.red : MyColorsSample.grey_60,
                          ),
                          if (typeDevice > 2)
                            _buildStatusField(
                              label: "NFC-e Emitidas",
                              value: statusApi.qtdeNfceEmitida.toString(),
                              valueColor:  statusApi.qtdeNfceEmitida != statusApi.qtdeNfceAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          if (typeDevice > 2)
                            _buildStatusField(
                              label: "NFC-e Autorizadas",
                              value: statusApi.qtdeNfceAutorizada.toString(),
                              valueColor:  statusApi.qtdeNfceEmitida != statusApi.qtdeNfceAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),
                          if (typeDevice <= 2)
                            _buildStatusField(
                              label: "NFC-e Em./Aut.",
                              value: "${statusApi.qtdeNfceEmitida} / ${statusApi.qtdeNfceAutorizada}",
                              valueColor:  statusApi.qtdeNfceEmitida != statusApi.qtdeNfceAutorizada
                                  ? Colors.red : MyColorsSample.grey_60,
                            ),

                          _buildStatusField(
                            label: "NFC-e Conting.",
                            value: statusApi.qtdeNfceContigencia.toString(),
                            valueColor: statusApi.qtdeNfceContigencia > 0
                                ? Colors.red : MyColorsSample.grey_60,
                          ),
                          if (typeDevice > 2)
                            _buildStatusField(
                              label: "Seq. NFC-e",
                              value: statusApi.sequenciaNumericaNFCe ? "OK" : "ERRO",
                              valueColor: statusApi.sequenciaNumericaNFCe
                                  ? MyColorsSample.grey_60 : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (typeDevice > 2)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildStatusField(
                      label: "NFC-e canceladas",
                      value: formatList(statusApi.nfceCancelada),
                      valueColor: statusApi.qtdeNfceCancelada > 0
                          ? Colors.red : MyColorsSample.grey_60,
                    ),
                    _buildStatusField(
                      label: "NFC-e Contigencia",
                      value: formatList(statusApi.nfceContigencia),
                      valueColor: statusApi.qtdeNfceContigencia > 0
                          ? Colors.red : MyColorsSample.grey_60,
                    ),
                    _buildStatusField(
                      label: "NFC-e Outras",
                      value: formatList(statusApi.nfceOutras),
                      valueColor: Colors.red,
                    ),
                  ],
                ),
              ),
            if (typeDevice > 2)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildStatusField(
                      label: "NF-e canceladas",
                      value: formatList(statusApi.nfeCancelada),
                      valueColor: statusApi.qtdeNfeCancelada > 0
                          ? Colors.red : MyColorsSample.grey_60,
                    ),
                    _buildStatusField(
                      label: "NF-e Contigencia",
                      value: formatList(statusApi.nfeContigencia),
                      valueColor: statusApi.qtdeNfeContigencia > 0
                          ? Colors.red : MyColorsSample.grey_60,
                    ),
                    _buildStatusField(
                      label: "NF-e Outras",
                      value: formatList(statusApi.nfeOutras),
                      valueColor: Colors.red,
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }

  Widget _buildStatusApi(String status, WebCliente cliente) {
    final bool isApiOk = cliente.webStatusApi.sucesso;
    final IconData apiIcon = isApiOk && isSameDay( cliente.webStatusApi.dataHora) ? Icons.wifi : Icons.wifi_off;
    final Color chipColor = isApiOk ? Colors.blueAccent : Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(apiIcon, color: Colors.white, size: 14),
          const SizedBox(width: 16),
          Text(
              Mascaras().mascaraDataHora(cliente.webStatusExportacao.dataHora),
            style: MyTextSample.caption(context)?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField({
    required String label,
    required String value,
    Color valueColor = MyColorsSample.grey_60,
  }) {
    final styleBase = MyTextSample.small(context);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: styleBase.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: styleBase.copyWith(
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
    final agora = DateTime.now();
    if (dataStatusString.isEmpty) {
      return false;
    }

    try {
      final dataStatus = DateTime.parse(dataStatusString);
      return agora.year  == dataStatus.year &&
          agora.month == dataStatus.month;
    } catch (e) {
      print("Erro ao converter a data do status da API: $e. String recebida: '$dataStatusString'");
      return false;
    }
  }


  Widget _buildInfoRow({required IconData icon, required String text}) {
    // Não renderiza a linha se o texto estiver vazio
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: MyColorsSample.grey_60),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_80),
          ),
        ),
      ],
    );
  }

  /*
  Card makeCardOld(WebCliente webCliente, int pos) =>
      Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4.0 ,
      color: Colors.white,
      //surfaceTintColor: webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red ,
      //shadowColor: webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red ,
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
                                                           labelStyle: typeDevice <= 2 ? MyTextSample.small(context).copyWith( color: MyColorsSample.grey_60,) :
                                                           MyTextSample.small2(context).copyWith( color: MyColorsSample.grey_60,),
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
                                                           style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith(
                                                              color: MyColorsSample.grey_80, ) : MyTextSample.medium(context).copyWith(
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
                                                          style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith( color: MyColorsSample.grey_60/*webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red,*/ )
                                                               : MyTextSample.medium(context).copyWith( color: MyColorsSample.grey_60/*webCliente.webStatusApi.sucesso ? MyColorsSample.rckapp : Colors.red,*/ ),
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
                                                          style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith(
                                                              color: MyColorsSample.grey_60) : MyTextSample.medium(context).copyWith(
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
                                                          style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith(
                                                            color: MyColorsSample.grey_60,
                                                          ) : MyTextSample.medium(context).copyWith(
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
                                                          style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith(
                                                            color: webCliente.webStatusApi.qtdeNfeContigencia <= 0 ? MyColorsSample.grey_60 : Colors.red,
                                                          ) : MyTextSample.medium(context).copyWith(
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
                                                    controller: TextEditingController()..text =   webCliente.webStatusDadosInvalido.cnpj.isEmpty && webCliente.webStatusErroAddArquivo.cnpj.isEmpty ?
                                                       webCliente.webStatusExportacao.mensagem == null || webCliente.webStatusExportacao.mensagem.isEmpty ?  " " : webCliente.webStatusExportacao.mensagem :
                                                          ( (webCliente.webStatusDadosInvalido  == null ? " " : webCliente.webStatusDadosInvalido.mensagem)
                                                         +  (webCliente.webStatusErroAddArquivo == null ? " " : webCliente.webStatusErroAddArquivo.mensagem) ),
                                                    //initialValue: "1",
                                                    style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith(
                                                    color: MyColorsSample.grey_60,) : MyTextSample.medium(context).copyWith(
                                                      color: MyColorsSample.grey_60 ,
                                                    ),
                                                    enabled: false,
                                                    maxLines: 2,
                                                    decoration: InputDecoration(
                                                      labelText:  'Status da exportação',
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
                                                    webCliente.webStatusExportacao.email_exportacao_1 + (webCliente.webStatusExportacao.email_exportacao_2.isEmpty ? " " : "  -  " +webCliente.webStatusExportacao.email_exportacao_2)
                                                    : "-",
                                                    obscureText: widget.isobscureText,
                                                    //initialValue: "1",
                                                    style: typeDevice <= 2 ? MyTextSample.medium0(context).copyWith(
                                                      color: MyColorsSample.grey_60 ,
                                                    ) : MyTextSample.medium(context).copyWith(
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
*/
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
                        crossAxisCount:   typeDevice   <= 2  ? 1 : 2,
                        childAspectRatio: typeDevice == 1 ? 0.8 : typeDevice == 2 ? 5 / 3.2 : 5 / 2.5),
                    itemCount: listaClientes.length,
                    ///controller: _scrollController,
                    //physics: const NeverScrollableScrollPhysics(),//BouncingScrollPhysics() ,//AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return makeCard(listaClientes[index]/*, index*/);
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







