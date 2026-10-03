import 'package:cloud_firestore/cloud_firestore.dart';
class WebStatusExportacao {
  String cnpj;
  String mensagem;
  bool sucesso;

  String dataHora;

  int qtdeNfeEmitida;
  int qtdeNfeAutorizada;
  int qtdeNfeContigencia;
  int qtdeNfeCancelada;

  int qtdeNfceEmitida;
  int qtdeNfceAutorizada;
  int qtdeNfceContigencia;
  int qtdeNfceCancelada;

  int qtdeNfeInutilizada;

  int qtdeNfceInutilizada;

  int qtdeNotaOutras;
  int qtdeNotaTerceiros;

  bool sequenciaNumericaNFe;
  bool primeiraNotaNFe;

  bool sequenciaNumericaNFCe;
   bool primeiraNotaNFCe;

  String data_agendamento;

  String data_exportacao;

  String email_exportacao_1;


  String email_exportacao_2;

  String hora_exportacao;



  WebStatusExportacao({
     required this.cnpj,
     required this.mensagem,
     required this.sucesso,

    required this.dataHora,

    required this.qtdeNfeEmitida,
    required this.qtdeNfeAutorizada,
    required this.qtdeNfeContigencia,
    required this.qtdeNfeCancelada,

    required this.qtdeNfceEmitida,
    required this.qtdeNfceAutorizada,
    required this. qtdeNfceContigencia,
    required this. qtdeNfceCancelada,

    required this.qtdeNfeInutilizada,

    required this.qtdeNfceInutilizada,

    required this.qtdeNotaOutras,
    required this.qtdeNotaTerceiros,

    required this.sequenciaNumericaNFe,
    required this.primeiraNotaNFe,

    required this.sequenciaNumericaNFCe,
    required this.primeiraNotaNFCe,

    required this.data_agendamento,

    required this.data_exportacao,

    required this.email_exportacao_1,


    required this.email_exportacao_2,

    required this.hora_exportacao,



  });

  factory WebStatusExportacao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WebStatusExportacao(
      cnpj: data['cnpj'] ?? "",
      mensagem: data['mensagem'] ?? "",
      sucesso: data['sucesso'] ?? false,
      dataHora: data['dataHora'] ?? "0000-00-00 00:00:00",

      qtdeNfeEmitida: data['qtdeNfeEmitida'] ?? 0,
      qtdeNfeAutorizada: data['qtdeNfeAutorizada'] ?? 0,
      qtdeNfeContigencia: data['qtdeNfeContigencia'] ?? 0,
      qtdeNfeCancelada: data['qtdeNfeCancelada'] ?? 0,

      qtdeNfceEmitida: data['qtdeNfceEmitida'] ?? 0,
      qtdeNfceAutorizada: data['qtdeNfceAutorizada'] ?? 0,
      qtdeNfceContigencia: data['qtdeNfceContigencia'] ?? 0,
      qtdeNfceCancelada: data['qtdeNfceCancelada'] ?? 0,

      qtdeNfeInutilizada: data['qtdeNfeInutilizada'] ?? 0,

      qtdeNfceInutilizada: data['qtdeNfceInutilizada'] ?? 0,

      qtdeNotaOutras: data['qtdeNotaOutras'] ?? 0,
      qtdeNotaTerceiros: data['qtdeNotaTerceiros'] ?? 0,

      sequenciaNumericaNFe: data['sequenciaNumericaNFe'] ?? false,
      primeiraNotaNFe: data['primeiraNotaNFe'] ?? false,

      sequenciaNumericaNFCe: data['sequenciaNumericaNFCe'] ?? false,
      primeiraNotaNFCe :data['primeiraNotaNFCe'] ?? false,

      data_agendamento:  data['data_agendamento'] ?? "",

      data_exportacao:  data['data_exportacao'] ?? "",

      email_exportacao_1:  data['email_exportacao_1'] ?? "",

      email_exportacao_2:  data['email_exportacao_2'] ?? "",

      hora_exportacao :  data['hora_exportacao'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cnpj': cnpj
    };
  }

   factory WebStatusExportacao.fromJson(Map<String, dynamic> json) {
     return WebStatusExportacao(
        cnpj: json['cnpj'] ?? "",
        mensagem: json['mensagem'] ?? "",
        sucesso: json['sucesso'] ?? false,
        dataHora: json['dataHora'] ?? "0000-00-00 00:00:00",

        qtdeNfeEmitida: json['qtdeNfeEmitida'] ?? 0,
        qtdeNfeAutorizada: json['qtdeNfeAutorizada'] ?? 0,
        qtdeNfeContigencia: json['qtdeNfeContigencia'] ?? 0,
        qtdeNfeCancelada: json['qtdeNfeCancelada'] ?? 0,

        qtdeNfceEmitida: json['qtdeNfceEmitida'] ?? 0,
        qtdeNfceAutorizada: json['qtdeNfceAutorizada'] ?? 0,
        qtdeNfceContigencia: json['qtdeNfceContigencia'] ?? 0,
        qtdeNfceCancelada: json['qtdeNfceCancelada'] ?? 0,

        qtdeNfeInutilizada: json['qtdeNfeInutilizada'] ?? 0,

        qtdeNfceInutilizada: json['qtdeNfceInutilizada'] ?? 0,

        qtdeNotaOutras: json['qtdeNotaOutras'] ?? 0,
        qtdeNotaTerceiros: json['qtdeNotaTerceiros'] ?? 0,

        sequenciaNumericaNFe: json['sequenciaNumericaNFe'] ?? false,
        primeiraNotaNFe: json['primeiraNotaNFe'] ?? false,

        sequenciaNumericaNFCe: json['sequenciaNumericaNFCe'] ?? false,
        primeiraNotaNFCe :json['primeiraNotaNFCe'] ?? false,

        data_agendamento:  json['data_agendamento'] ?? "",

        data_exportacao:  json['data_exportacao'] ?? "",

        email_exportacao_1:  json['email_exportacao_1'] ?? "",

        email_exportacao_2:  json['email_exportacao_2'] ?? "",

        hora_exportacao :  json['hora_exportacao'] ?? "",
     );
  }

   static List<WebStatusExportacao> fromJsonList(dynamic jsonList) {
     final transactionDetailsList = <WebStatusExportacao>[];
     if (jsonList == null) return transactionDetailsList;

     if (jsonList is List<dynamic>) {
       for (final json in jsonList) {
         transactionDetailsList.add(
           WebStatusExportacao.fromJson(json),
         );
       }
     }
     return transactionDetailsList;
   }


}