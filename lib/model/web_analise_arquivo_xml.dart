class WebAnaliseArquivoXml {
  String id;
  bool sucesso;
  String mensagem;
  String modelo;

  int qtde_autorizadas;
  int qtde_canceladas;
  int qtde_contigencia;
  int qtde_cte;
  int qtde_emitidas;
  int qtde_inutilizadas;
  int qtde_nfe;
  int qtde_nfce;
  int qtde_terc;
  int qtde_outras;

  String status_exportacao;
  String data_exportacao;
  String hora_exportacao;
  String email_exportacao_1;
  String email_exportacao_2;

  String data_agendamento;



  WebAnaliseArquivoXml({
     required this.id,
     required this.mensagem,
     required this.sucesso,
     required this.modelo,

    required this.qtde_autorizadas,
    required this.qtde_canceladas,
    required this.qtde_contigencia,
    required this.qtde_cte,
    required this.qtde_emitidas,
    required this.qtde_inutilizadas,
    required this.qtde_nfe,
    required this.qtde_nfce,
    required this.qtde_terc,
    required this.qtde_outras,

    required this.status_exportacao,
    required this.data_exportacao,
    required this.hora_exportacao,
    required this.email_exportacao_1,
    required this.email_exportacao_2,
    required this.data_agendamento,
   });

   factory WebAnaliseArquivoXml.fromJson(Map<String, dynamic> json) {
     return WebAnaliseArquivoXml(
        id: json['id'] ?? '0',
        mensagem: json['mensagem'] ?? "",
        sucesso: json['sucesso'] ?? false,
        modelo: json['modelo'] ?? "",

       qtde_autorizadas: json['qtde_autorizadas'] ?? 0,
       qtde_canceladas: json['qtde_canceladas'] ?? 0,
       qtde_contigencia: json['qtde_contigencia'] ?? 0,
       qtde_cte: json['qtde_cte'] ?? 0,
       qtde_emitidas: json['qtde_emitidas'] ?? 0,
       qtde_inutilizadas: json['qtde_inutilizadas'] ?? 0,
       qtde_nfe: json['qtde_nfe'] ?? 0,
       qtde_nfce: json['qtde_nfce'] ?? 0,
       qtde_terc: json['qtde_terc'] ?? 0,
       qtde_outras: json['qtde_outras'] ?? 0,

       status_exportacao: json['status_exportacao'] ?? "",
       data_exportacao: json['data_exportacao'] ?? "",
       hora_exportacao: json['hora_exportacao'] ?? "",
       email_exportacao_1: json['email_exportacao_1'] ?? "",
       email_exportacao_2: json['email_exportacao_2'] ?? "",
       data_agendamento: json['data_agendamento'] ?? "",

     );
  }

   static List<WebAnaliseArquivoXml> fromJsonList(dynamic jsonList) {
     final transactionDetailsList = <WebAnaliseArquivoXml>[];
     if (jsonList == null) return transactionDetailsList;

     if (jsonList is List<dynamic>) {
       for (final json in jsonList) {
         transactionDetailsList.add(
           WebAnaliseArquivoXml.fromJson(json),
         );
       }
     }
     return transactionDetailsList;
   }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sucesso': sucesso,
        'mensagem': mensagem,
        'modelo': modelo,
        'qtde_autorizadas': qtde_autorizadas,
        'qtde_canceladas': qtde_canceladas,
        'qtde_contigencia': qtde_contigencia,
        'qtde_cte': qtde_cte,
        'qtde_emitidas': qtde_emitidas,
        'qtde_inutilizadas': qtde_inutilizadas,
        'qtde_nfe': qtde_nfe,
        'qtde_nfce': qtde_nfce,
        'qtde_terc': qtde_terc,
        'qtde_outras': qtde_outras,
        'status_exportacao': status_exportacao,
        'data_exportacao': data_exportacao,
        'hora_exportacao': hora_exportacao,
        'email_exportacao_1': email_exportacao_1,
        'email_exportacao_2': email_exportacao_2,
        'data_agendamento': data_agendamento,
      };
}