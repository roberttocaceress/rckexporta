class WebTabelaPrecoItens {
  String id_item;
  String id_tabela;
  String perc_desc_inicial;
  String perc_desc_final;
  String verba_perc;
  String utiliza_verba;
  String desconto_verba_max;
  int idCategoria;
  String valor_unitario;
  String id_produto;
  WebTabelaPrecoItens(
  {required this.id_item,
  required this.id_tabela,
  required this.perc_desc_inicial,
  required this.perc_desc_final,
  required this.verba_perc,
  required this.utiliza_verba,
  required this.desconto_verba_max,
  required this.idCategoria,
  required this.valor_unitario,
  required this.id_produto});

  factory WebTabelaPrecoItens.fromJson(Map<String, dynamic> json) {
    return WebTabelaPrecoItens(
      id_item: json['id_item'] ?? "",
      id_tabela: json['id_tabela'] ?? "",
      perc_desc_inicial: json['perc_desc_inicial'] ?? "0.00",
      perc_desc_final: json['perc_desc_final'] ?? "0.00",
      verba_perc: json['verba_perc'] ?? "0.00",
      utiliza_verba: json['utiliza_verba'] ?? "",
      desconto_verba_max: json['desconto_verba_max']  ?? "",
      idCategoria: json['idCategoria'] ?? "0",
      valor_unitario: json['valor_unitario'] ?? "",
      id_produto: json['id_produto']  ?? "",
    );
  }

  static List<WebTabelaPrecoItens> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebTabelaPrecoItens>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebTabelaPrecoItens.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

  Map<String, dynamic> toJson() => {
        'id_item': id_item,
        'id_tabela': id_tabela,
        'perc_desc_inicial': perc_desc_inicial,
        'perc_desc_final': perc_desc_final,
        'verba_perc': verba_perc,
        'utiliza_verba': utiliza_verba,
        'desconto_verba_max': desconto_verba_max,
        'idCategoria': idCategoria,
        'valor_unitario': valor_unitario,
        'id_produto': id_produto,
      };
}