import 'package:cloud_firestore/cloud_firestore.dart';
class WebTarefa {
  int id_tarefa;
  int qtde_nao_agendada;
  int qtde_agendada;
  int qtde_executada;
  int qtde_pendente;
  String periodo_inicial;
  String periodo_final;
  String data_hora_atualizado;

  WebTarefa({
     required this.id_tarefa,
     required this.qtde_nao_agendada,
     required this.qtde_agendada,
     required this.qtde_executada,
     required this.qtde_pendente,
     required this.periodo_inicial,
     required this.periodo_final,
     required this.data_hora_atualizado,
   });


  factory WebTarefa.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WebTarefa(
      id_tarefa: data['id_tarefa'] ?? '',
      qtde_nao_agendada: data['qtde_nao_agendada'] ?? 0,
      qtde_agendada: data['qtde_agendada'] ?? 0,
      qtde_executada: data['qtde_executada'] ?? 0,
      qtde_pendente: data['qtde_pendente'] ?? 0,
      periodo_inicial: data['periodo_inicial'] ?? "",
      periodo_final: data['periodo_final'] ?? "",
      data_hora_atualizado: data['data_hora_atualizado'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_tarefa' :id_tarefa,
      'qtde_nao_agendada': qtde_nao_agendada,
      'qtde_agendada': qtde_agendada,
      'qtde_executada' : qtde_executada,
      'qtde_pendente' : qtde_pendente,
      'periodo_inicial' : periodo_inicial,
      'periodo_final' : periodo_final,
      'data_hora_atualizado' : data_hora_atualizado,
    };
  }



  factory WebTarefa.fromJson(Map<String, dynamic> json) {
    return WebTarefa(
      id_tarefa: json['id_tarefa'] ?? 0,
      qtde_nao_agendada: json['qtde_nao_agendada'] ?? 0,
      qtde_agendada: json['qtde_agendada'] ?? 0,
      qtde_executada: json['qtde_executada'] ?? 0,
      qtde_pendente: json['qtde_pendente'] ?? 0,
      periodo_inicial: json['periodo_inicial'] ?? "",
      periodo_final: json['periodo_final'] ?? "",
      data_hora_atualizado: json['data_hora_atualizado'] ?? "",

    );
  }

  static List<WebTarefa> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebTarefa>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebTarefa.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

}