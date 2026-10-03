class WebProdutoDetalhe {
  String id_produto;
  String id_grupo;
  String nome_grupo;
  String id_sub_grupo;
  String nome_sub_grupo;
  String ean_produto;
  bool isExpanded = false;


  WebProdutoDetalhe({
    required this.id_produto,
    required this.id_grupo,
    required this.nome_grupo,
    required this.id_sub_grupo,
    required this.nome_sub_grupo,
    required this.ean_produto,
    required this.isExpanded,

  });

  factory WebProdutoDetalhe.fromJson(Map<String, dynamic> json) {
    return WebProdutoDetalhe(
        id_produto: json['id_produto'] ?? "",
        id_grupo: json['id_grupo' ]?? "",
        id_sub_grupo: json['id_sub_grupo'] ?? "",
        nome_sub_grupo: json['nome_sub_grupo']  ?? "",
        nome_grupo: json['nome_grupo'] ?? "",
        ean_produto: json['ean_produto'] ?? "-",
        isExpanded: false,
    );
  }

  static List<WebProdutoDetalhe> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebProdutoDetalhe>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebProdutoDetalhe.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }
}