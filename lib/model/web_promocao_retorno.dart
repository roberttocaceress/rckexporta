class WebPromocaoRetorno {
  String nomePromocao;
  double valorDesconto;
  WebPromocaoRetorno({
     required this.nomePromocao,
     required this.valorDesconto
  });
  factory WebPromocaoRetorno.fromJson(Map<String, dynamic> json) {
    return WebPromocaoRetorno(
      nomePromocao: json['nomePromocao'] ?? "",
      valorDesconto: json['valorDesconto'] ?? "0.00",
    );
  }

  static List<WebPromocaoRetorno> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebPromocaoRetorno>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebPromocaoRetorno.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

}