class WebPrazo {
  String ativo;
  String id_condicao;
  String nome_condicao;
  String numero_parcelas;
  String intervalo_dias;
  String tipo_condicao;
  String publicar_na_web;
  String aceita_desconto;
  String desconto_perc;
  WebPrazo({

    required this.ativo,
    required this.id_condicao,
    required this.nome_condicao,
    required this.numero_parcelas,
    required this.intervalo_dias,
    required this.tipo_condicao,
    required this.publicar_na_web,
    required this.aceita_desconto,
    required this.desconto_perc
  });
  factory WebPrazo.fromJson(Map<String, dynamic> json) {
    return WebPrazo(
      ativo: json['ativo'] ?? "",
      id_condicao: json['id_condicao'] ?? "",
      nome_condicao: json['nome_condicao'] ?? "",
      numero_parcelas: json['numero_parcelas'] ?? "",
      intervalo_dias: json['intervalo_dias'] ?? "",
      tipo_condicao: json['tipo_condicao'] ?? "",
      publicar_na_web: json['publicar_na_web'] ?? "",
      aceita_desconto: json['aceita_desconto'] ?? "",
      desconto_perc: json['desconto_perc'] ?? "",
    );
  }

  static List<WebPrazo> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebPrazo>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebPrazo.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }
}