class WebCampanhaComercialCab{
  String ativo;
  int idCampanha;
  int idTipoCampanha;
  int idBaseCampanha;
  int idEmpresa;
  String dataInicio;
  String dataFim;
  String nomeCampanha;
  String descricaoCampanha;
  WebCampanhaComercialCab({
    required this.ativo,
    required this.idCampanha,
    required this.idTipoCampanha,
    required this.idBaseCampanha,
    required this.idEmpresa,
    required this.dataInicio,
    required this.dataFim,
    required this.nomeCampanha,
    required this.descricaoCampanha,
   });
  factory WebCampanhaComercialCab.fromJson(Map<String, dynamic> json) {
    return WebCampanhaComercialCab(
      ativo: json['ativo'] ?? "N",
      idCampanha: json['idCampanha'] ?? 0,
      idTipoCampanha: json['idTipoCampanha'] ?? 0,
      idBaseCampanha: json['idBaseCampanha'] ?? 0,
      idEmpresa: json['idEmpresa'] ?? 0,
      dataInicio: json['dataInicio'] ?? "",
      dataFim: json['dataFim'] ?? "",
      nomeCampanha: json['nomeCampanha'] ?? "",
      descricaoCampanha: json['descricaoCampanha'] ?? "");
  }

  static List<WebCampanhaComercialCab> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebCampanhaComercialCab>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebCampanhaComercialCab.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

}