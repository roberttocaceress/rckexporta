import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rck_painel_tarefa/model/web_vendedor.dart';
import 'package:rck_painel_tarefa/model/web_tarefa.dart';
import 'package:rck_painel_tarefa/screens/cliente_tarefa_consulta_route.dart';
import 'package:rck_painel_tarefa/util/DeviceDetector.dart';
import 'package:rck_painel_tarefa/util/MyColorSample.dart';
import 'package:rck_painel_tarefa/util/MyTextSample.dart';

class VendedorConsultaRoute extends StatelessWidget {
  final String tokenUsuario;
  final String idUsuario;
  const VendedorConsultaRoute(
      {super.key, required this.idUsuario, required this.tokenUsuario});

  @override
  Widget build(BuildContext context) {
    return VendedorHomePage(idUsuario: idUsuario, tokenUsuario: tokenUsuario,);
  }
}

class VendedorHomePage extends StatefulWidget {
  final String idUsuario;
  final String tokenUsuario;
  const VendedorHomePage({super.key, required this.idUsuario, required this.tokenUsuario});
  @override
  State<VendedorHomePage> createState() => _VendedorHomePageState();
}

class _VendedorHomePageState extends State<VendedorHomePage> {
  late List<WebVendedor> listaVendedores = [];
  bool isLoading = false;
  bool isobscureText = false;
  final int typeDevice = DeviceDetector().typeDevice1(MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.single));
  ScrollController scrollController = ScrollController();
  late Stream<QuerySnapshot> _vendedorStream;

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

  @override
  void initState() {
    super.initState();
    _vendedorStream = FirebaseFirestore.instance.collection('vendedores').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyColorsSample.white,
          shadowColor: MyColorsSample.white,
          surfaceTintColor: MyColorsSample.white,
          title: const Text('Consulta de Vendedores')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vendedorStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          listaVendedores = snapshot.data!.docs
              .map((doc) => WebVendedor.fromFirestore(doc))
              .toList();

          // DADOS FICTÍCIOS TEMPORÁRIOS PARA TESTE VISUAL
          if (listaVendedores.isEmpty) {
            listaVendedores = [
              WebVendedor(
                id_vendedor: "1",
                nome_vendedor: "Vendedor de Teste 01",
                empresa: "Empresa Exemplo A",
                versao_aplicativo: "2.5.0",
                ultima_sincronizacao: "20/05/2024 14:30",
                status: "Ativo",
              ),
              WebVendedor(
                id_vendedor: "2",
                nome_vendedor: "Vendedor de Teste 02",
                empresa: "Empresa Exemplo B",
                versao_aplicativo: "2.4.8",
                ultima_sincronizacao: "19/05/2024 09:15",
                status: "Inativo",
              ),
              WebVendedor(
                id_vendedor: "3",
                nome_vendedor: "Vendedor de Teste 03",
                empresa: "Empresa Exemplo A",
                versao_aplicativo: "2.5.0",
                ultima_sincronizacao: "20/05/2024 16:45",
                status: "Ativo",
              ),
            ];
          }

          return Container(
            color: MyColorsSample.white,
            child: OrientationBuilder(
              builder: (context, orientation) {
                return listContainer();
              },
            ),
          );
        },
      ),
    );
  }

  Widget listContainer() {
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
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: typeDevice <= 2 ? 1 : typeDevice == 3 ? 2 : 4,
                childAspectRatio: typeDevice == 1 ? 2.5 : typeDevice == 2 ? 3.5 : 4.0),
            itemCount: listaVendedores.length,
            controller: scrollController,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return makeCard(listaVendedores[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSummaryCard({
    required String title,
    required String total,
    required String emAberto,
    required String realizadas,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onLongPress,
    required String periodo,
  }) {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubMetric("Abertas", emAberto, Colors.blue, () {
                    _navigateToFilteredList(periodo, 3);
                  }),
                  _buildSubMetric("Realizadas", realizadas, Colors.green, () {
                    _navigateToFilteredList(periodo, 2);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFilteredList(String periodo, int idxTipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteConsultaTarefasRoute(
          idUsuario: widget.idUsuario,
          periodoInicial: periodo,
          periodoFinal: periodo,
          idxTipo: idxTipo,
          isobscureText: isobscureText,
          tokenUsuario: widget.tokenUsuario,
          cnpjCliente: '',
        ),
      ),
    );
  }

  Widget _buildSubMetric(String label, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
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

  Widget makeCard(WebVendedor vendedor) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4.0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vendedor.nome_vendedor,
                    style: MyTextSample.medium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: MyColorsSample.grey_80,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: vendedor.status == "Ativo" ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vendedor.status,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const Divider(),
            _infoRow(Icons.business, "Empresa: ${vendedor.empresa}"),
            const SizedBox(height: 4),
            _infoRow(Icons.info_outline, "Versão: ${vendedor.versao_aplicativo}"),
            const SizedBox(height: 4),
            _infoRow(Icons.sync, "Sincronização: ${vendedor.ultima_sincronizacao}"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: MyColorsSample.grey_60),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: MyTextSample.small2(context).copyWith(color: MyColorsSample.grey_80),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
