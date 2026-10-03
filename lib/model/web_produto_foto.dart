class WebProdutoFoto {
  String ativo;
  String id_produto;
  String id_foto;
  String foto_arquivo; //  BLOB
  String foto_miniatura; // BLOB
  String foto_principal;
  String fbase64;

  WebProdutoFoto({
      required this.ativo,
      required this.id_produto,
      required this.id_foto,
      required this.foto_arquivo, //  BLOB
      required this.foto_miniatura, // BLOB
      required this.foto_principal,
      required this.fbase64
  });

  factory WebProdutoFoto.fromJson(Map<String, dynamic> json) {
    return WebProdutoFoto(
        ativo: json['ativo'] ?? "",
        id_produto: json['id_produto'] ?? "",
        id_foto: json['id_foto'] ?? "",
        foto_arquivo: json['foto_arquivo'] ?? "",
        foto_miniatura: json['foto_miniatura'] ?? "",
        foto_principal: json['foto_principal'] ?? "",
        fbase64: json['fbase64'] ?? "");
  }

  static List<WebProdutoFoto> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebProdutoFoto>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebProdutoFoto.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }
}
