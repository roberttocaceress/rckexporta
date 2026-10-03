import 'package:cloud_firestore/cloud_firestore.dart';
class WebStatusApi {
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

  List<String> nfeContigencia;
  List<String> nfceContigencia;
  List<String> nfeOutras;
  List<String> nfceOutras;

  List<String> nfeCancelada;
  List<String> nfceCancelada;



  WebStatusApi({
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
    required this.qtdeNfceContigencia,
    required this.qtdeNfceCancelada,

    required this.qtdeNfeInutilizada,

    required this.qtdeNfceInutilizada,

    required this.qtdeNotaOutras,
    required this.qtdeNotaTerceiros,

    required this.sequenciaNumericaNFe,
    required this.primeiraNotaNFe,

    required this.sequenciaNumericaNFCe,
    required this.primeiraNotaNFCe,

    this.nfeContigencia = const [],
    this.nfceContigencia = const [],

    this.nfeOutras = const [],
    this.nfceOutras = const [],

    this.nfeCancelada = const [],
    this.nfceCancelada = const [],

  });

  factory WebStatusApi.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WebStatusApi(
      cnpj: data['cnpj'] ?? "",
      mensagem: data['mensagem'] ?? "",
      sucesso: data['sucesso'] ?? false,


      dataHora: data['dataHora'] ?? "0000-00-00",

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
      primeiraNotaNFCe : data['primeiraNotaNFCe'] ?? false,

      nfeContigencia : data['nfeContigencia'] != null ? List<String>.from(data['nfeContigencia']) : [],
      nfceContigencia : data['nfceContigencia'] != null ? List<String>.from(data['nfceContigencia']) : [],

      nfeOutras : data['nfeOutras'] != null ? List<String>.from(data['nfeOutras']) : [],
      nfceOutras : data['nfceOutras'] != null ? List<String>.from(data['nfceOutras']) : [],

      nfeCancelada : data['nfeCancelada'] != null ? List<String>.from(data['nfeCancelada']) : [],
      nfceCancelada : data['nfceCancelada'] != null ? List<String>.from(data['nfceCancelada']) : [],


    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cnpj': cnpj
    };
  }

   factory WebStatusApi.fromJson(Map<String, dynamic> json) {
     return WebStatusApi(
        cnpj: json['cnpj'] ?? "",
        mensagem: json['mensagem'] ?? "",
        sucesso: json['sucesso'] ?? false,


       dataHora: json['dataHora'] ?? "0000-00-00",

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

       nfeContigencia : json['nfeContigencia'] != null ? List<String>.from(json['nfeContigencia']) : [],
       nfceContigencia : json['nfceContigencia'] != null ? List<String>.from(json['nfceContigencia']) : [],

       nfeOutras : json['nfeOutras'] != null ? List<String>.from(json['nfeOutras']) : [],
       nfceOutras : json['nfceOutras'] != null ? List<String>.from(json['nfceOutras']) : [],

       nfeCancelada : json['nfeCancelada'] != null ? List<String>.from(json['nfeCancelada']) : [],
       nfceCancelada : json['nfceCancelada'] != null ? List<String>.from(json['nfceCancelada']) : [],

     );
  }

   static List<WebStatusApi> fromJsonList(dynamic jsonList) {
     final transactionDetailsList = <WebStatusApi>[];
     if (jsonList == null) return transactionDetailsList;

     if (jsonList is List<dynamic>) {
       for (final json in jsonList) {
         transactionDetailsList.add(
           WebStatusApi.fromJson(json),
         );
       }
     }
     return transactionDetailsList;
   }


}