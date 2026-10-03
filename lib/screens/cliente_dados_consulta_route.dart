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
import 'package:rck_painel_tarefa/main.dart';
import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';
import 'package:rck_painel_tarefa/util/Mascaras.dart';

import '../../api/web_api_exporta.dart';
import '../../model/web_tarefa.dart';
import '../model/web_analise_arquivo_xml.dart';
import '../model/web_status_exportacao.dart';
import '../util/DeviceDetector.dart';
class ClienteConsultaDadosRoute extends StatelessWidget {
  final String cnpjCliente;

  const ClienteConsultaDadosRoute(
      {super.key, required this.cnpjCliente});

  @override
  Widget build(BuildContext context) {
    return MyHomePage( cnpjCliente: cnpjCliente);
  }
}

class MyHomePage extends StatefulWidget {

  final String cnpjCliente;
  const MyHomePage({super.key,  required this.cnpjCliente});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<WebCliente>> _fWebCliente;
  late List<WebCliente> listaClientes = [];
  bool isLoading = false;
  final int typeDevice = DeviceDetector().typeDevice1(MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.single));
  late int idxClicado;
  var clienteAtivoController = TextEditingController();
  var emailAtivoController    = TextEditingController();
  var emailDest1Controller    = TextEditingController();
  var emailDest2Controller    = TextEditingController();
  var diaEnvioController      = TextEditingController();
  var horaEnvioController     = TextEditingController();
  var tempoEnvioController    = TextEditingController();
  var fusoHorarioController   = TextEditingController();

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
    _fWebCliente  = _getWebCliente();
  }

  @override
  void dispose() {
    clienteAtivoController.dispose();
    emailAtivoController.dispose();
    emailDest1Controller.dispose();
    emailDest2Controller.dispose();
    diaEnvioController.dispose();
    horaEnvioController.dispose();
    tempoEnvioController.dispose();
    fusoHorarioController.dispose();
    super.dispose();
  }

  Future<List<WebCliente>> _getWebCliente( ) async {
      final webClientes = FirebaseFirestore.instance
          .collection('clientes').doc(widget.cnpjCliente)
          .withConverter<WebCliente>(
        fromFirestore: (snapshot, _) => WebCliente.fromFirestore(snapshot),
        toFirestore: (webCliente, _) => webCliente.toFirestore(),
      );
      final queryCliente = await webClientes.get();
      final WebCliente? cliente = queryCliente.data();
      clienteAtivoController.text = cliente!.ativo;
      emailAtivoController.text    = cliente.email_envio_ativo;
      emailDest1Controller.text    = cliente.email_exportacao_1;
      emailDest2Controller.text    = cliente.email_exportacao_2;
      diaEnvioController.text      = cliente.data_exportacao_1;
      horaEnvioController.text     = cliente.hora_exportacao_1;
      tempoEnvioController.text    = cliente.tempo_status_api;
      fusoHorarioController.text   = cliente.fuso_horario;

      List<WebCliente> lista = [];
      lista.add(cliente);
      setState(() {
        listaClientes.addAll(lista);
      });
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
          title: Text(  "Dados do cliente",
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
              child: CircularProgressIndicator(color: MyColorsSample.rckapp, semanticsLabel: 'Aguarde...',),
            );
          }
        },
      ),
    );
  }

  Card makeCard(WebCliente cliente) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        cliente.nome_cadastro,
                        style: MyTextSample.subhead(context)?.copyWith(
                          color: MyColorsSample.grey_90,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
              ],
            ),
            const SizedBox(height: 0.0),
            const Divider(),
            const SizedBox(height: 0),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo das colunas no topo
              children: [
                // Expanded garante que a coluna ocupe o espaço disponível.
                Expanded(
                  // Usamos um Flexible para que o conteúdo não seja forçado a ter a mesma altura.
                  child: _buildCampoDropdownSimNao(
                      icone: Icons.check_circle_outline,
                      titulo: "Cliente ativo" ,
                      value: clienteAtivoController.text == 'S' ? true : false,
                      isEditing: true,
                      onChanged: (novoValor) {
                      // Este callback é essencial para atualizar a UI em tempo real no modo de edição.
                      // O setState reconstrói a tela com a nova seleção do dropdown.
                      if (novoValor != null) {
                        setState(() {
                          clienteAtivoController.text = novoValor ? "S" : "N";
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCampoDropdownSimNao(
                    icone: Icons.check_circle_outline,
                    titulo: "Email ativo" ,
                    value: emailAtivoController.text == 'S' ? true : false,
                    isEditing: true,
                    onChanged: (novoValor) {
                      if (novoValor != null) {
                        setState(() {
                           emailAtivoController.text = novoValor ? "S" : "N";
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo das colunas no topo
              children: [
                // Expanded garante que a coluna ocupe o espaço disponível.
                Expanded(
                  // Usamos um Flexible para que o conteúdo não seja forçado a ter a mesma altura.
                  child: _buildCampoDeDados(
                    icone: Icons.email_outlined,
                    titulo: 'E-mail',
                    value: cliente.email_exportacao_1,
                    isEditing: true,
                    textController: emailDest1Controller,
                    keyboardType: TextInputType.emailAddress// Ex: "contato@empresa.com"
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCampoDeDados(
                    icone: Icons.email_outlined,
                    titulo: 'E-mail',
                    value: cliente.email_exportacao_2,
                    isEditing: true,
                    textController: emailDest2Controller,
                    keyboardType: TextInputType.emailAddress// Ex: "financeiro@empresa.com"
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo das colunas no topo
              children: [
                // --- COLUNA 1 (ESQUERDA) ---
                // Expanded garante que a coluna ocupe o espaço disponível.
                Expanded(
                  // Usamos um Flexible para que o conteúdo não seja forçado a ter a mesma altura.
                  child: _buildCampoDeDados(
                      icone: Icons.access_time_outlined,
                      titulo: "Hora da exportação",
                      value: cliente.hora_exportacao_1,
                      isEditing: true,
                      textController: horaEnvioController,
                      keyboardType: TextInputType.number,
                      inputFormatters:   [
                         FilteringTextInputFormatter.digitsOnly,
                      ]
                  ),
                ),

                // Espaçamento horizontal entre as duas colunas
                const SizedBox(width: 16),

                // --- COLUNA 2 (DIREITA) ---
                Expanded(
                  child: _buildCampoDeDados(
                    icone: Icons.calendar_month_outlined,
                    titulo: "Dia da exportação",
                    value: cliente.data_exportacao_1,
                    isEditing: true,
                    textController: diaEnvioController,
                      keyboardType: TextInputType.number,
                      inputFormatters:   [
                        FilteringTextInputFormatter.digitsOnly,
                      ]
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha o conteúdo das colunas no topo
              children: [
                // --- COLUNA 1 (ESQUERDA) ---
                // Expanded garante que a coluna ocupe o espaço disponível.
                Expanded(
                  // Usamos um Flexible para que o conteúdo não seja forçado a ter a mesma altura.
                  child: _buildCampoDeDados(
                      icone: Icons.gps_fixed_rounded,
                      titulo: "Fuso horario",
                      value: cliente.fuso_horario,
                      isEditing: true,
                      textController: fusoHorarioController,
                      keyboardType: TextInputType.text,

                  ),
                ),

                // Espaçamento horizontal entre as duas colunas
                const SizedBox(width: 16),

                // --- COLUNA 2 (DIREITA) ---
                Expanded(
                  child: _buildCampoDeDados(
                      icone: Icons.access_time_outlined,
                      titulo: "Tempo para sincronização",
                      value: cliente.tempo_status_api,
                      isEditing: true,
                      textController: tempoEnvioController,
                      keyboardType: TextInputType.number,
                      inputFormatters:   [
                        FilteringTextInputFormatter.digitsOnly,
                      ]
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Expanded(
              flex: 1,
              // Usamos um Flexible para que o conteúdo não seja forçado a ter a mesma altura.
              child:
                 SizedBox(
              height: 30,
                   width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  elevation: 4, // Adiciona uma leve sombra
                ),
                // Desabilita o botão durante o carregamento
                //onPressed: null,//_salvarCadastro(cliente),
                onPressed: () {
                  _salvarCadastro(cliente);// Handle button press
                },
                child: const Text(
                  'SALVAR',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCampoDeDados({
    required String value,
    required String titulo,
    required IconData? icone, // Ícone é opcional a
    required bool isEditing,// gora
    required  TextEditingController textController,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator, // Validação opcional
    TextInputType keyboard = TextInputType.text, // Tipo de teclado padrão

    // Parâmetro para salvar o valor (opcional)
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),

        // --- A LÓGICA PRINCIPAL: RENDERIZAÇÃO CONDICIONAL ---
        isEditing
        ? TextFormField(
          controller: textController,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,/*[
             FilteringTextInputFormatter.digitsOnly,
          ],*/
          //onSaved: onSaved, // Conecta ao .save() do formulário
          style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_80),
          enabled: true,
          decoration: InputDecoration(
            prefixIcon: icone != null ? Icon(icone, size: 20) : null,
            isDense: true, // Deixa o campo mais compacto
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
          onChanged: (novoValor) {
           // Este callback é essencial para atualizar a UI em tempo real no modo de edição.
           // O setState reconstrói a tela com a nova seleção do dropdown.
           if (novoValor != null) {
             setState(() {
               textController.text = novoValor;
               _moveCursorToEnd(textController);
             });
           }
         },
        ) : Row(
          // ...
        )
        // MODO DE VISUALIZAÇÃO: Retorna o Row com Text (como antes)

      ],
    );
  }

  void _moveCursorToEnd(TextEditingController controller) {
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }
  Widget _buildCampoDropdownSimNao({
    required String titulo,
    required IconData icone,
    required bool isEditing,
    required bool value, // O valor booleano atual (true para Sim, false para Não)
    required void Function(bool?)? onChanged, // Callback para atualizar o estado
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        isEditing
            ? DropdownButtonFormField<bool>(
          value: value, // O valor atualmente selecionado
          items: [
            // Opção "Sim"
            DropdownMenuItem<bool>(
              value: true,
              child: Text('SIM', style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_80)),
            ),
            // Opção "Não"
            DropdownMenuItem<bool>(
              value: false,
              child: Text('NAO', style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_80)),
            ),
          ],
          onChanged: onChanged, // Chama a função para atualizar o estado no widget pai
          decoration: InputDecoration(
            prefixIcon: Icon(icone, size: 20),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
          // Validação opcional (garante que uma opção seja selecionada)
          validator: (selectedValue) {
            if (selectedValue == null) {
              return 'Por favor, selecione uma opção.';
            }
            return null;
          },
        )
        // MODO DE VISUALIZAÇÃO: Retorna o Row com Text
            : Row(
          children: [
            Icon(icone, size: 20, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              value ? "SIM" : "NAO", // Converte o booleano para a string correspondente
              style: MyTextSample.body1(context)?.copyWith(color: MyColorsSample.grey_80)
            ),
          ],
        ),
      ],
    );
  }


  _salvarCadastro(WebCliente cliente)  {
    cliente.ativo              = clienteAtivoController.text.toString().isEmpty ? "S" : clienteAtivoController.text.toString().trim() == "S" ? "S" : "N";
    cliente.email_envio_ativo  = emailAtivoController.text.toString().isEmpty ? "S" : emailAtivoController.text.toString().trim() == "S" ? "S" : "N";
    cliente.email_exportacao_1 = emailDest1Controller.text.toString() ;
    cliente.email_exportacao_2 = emailDest2Controller.text.toString();
    cliente.data_exportacao_1  = diaEnvioController.text.toString().isEmpty    ? "01" : diaEnvioController.text.toString().trim().length == 1 ? "0${diaEnvioController.text.toString().trim()}" : diaEnvioController.text.toString().trim();
    cliente.hora_exportacao_1  = horaEnvioController.text.toString().isEmpty   ? "08" : horaEnvioController.text.toString().trim().length == 1 ? "0${horaEnvioController.text.toString().trim()}" : horaEnvioController.text.toString().trim();
    cliente.tempo_status_api   = tempoEnvioController.text.toString().isEmpty  ? "30" : tempoEnvioController.text.toString();
    cliente.fuso_horario       = fusoHorarioController.text.toString().isEmpty ? "America/Cuiaba"
                                                                           : fusoHorarioController.text.toString().trim();
    if ( emailDest1Controller.text.isEmpty ) {
      return;
    }
    try {
    final db = FirebaseFirestore.instance;
    final dadosCliente = {
      'ativo': cliente.ativo.trim(),
      'data_exportacao_1': cliente.data_exportacao_1.trim(),
      'email_exportacao_1': cliente.email_exportacao_1.trim(),
      'email_exportacao_2': cliente.email_exportacao_2.trim(),
      'hora_exportacao_1': cliente.hora_exportacao_1.trim(),
      'data_exportacao_1': cliente.data_exportacao_1.trim(),
      'tempo_atualiza_status_api': cliente.tempo_status_api.trim(),
      'email_envio_ativo': cliente.email_envio_ativo.trim(),
      'versao_api': "001",
      'time_zone': cliente.fuso_horario,
    };
     String cnpj_cpf = cliente.cpf_cnpj;
     db.collection('clientes').doc(cnpj_cpf).update(dadosCliente);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados atualizado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      print("Erro do Firebase ao salvar: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      print("Erro inesperado: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          //Fechar o formulario
        });
      }
    }
  }

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
                        crossAxisCount:   typeDevice   <= 2  ? 1 : 2,//typeDevice == 3 ? 3 : 5 ,
                        childAspectRatio: typeDevice == 1 ? 1 : typeDevice == 2 ?  1.4 :  2),
                    itemCount: listaClientes.length,
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

}





