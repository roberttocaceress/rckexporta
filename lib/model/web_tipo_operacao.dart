class WebTipoOperacao {
   String ativo;
   String id_operacao;
   String nome_operacao;
   String natureza_operacao;

   WebTipoOperacao({
     required this.ativo,
     required this.id_operacao,
     required this.nome_operacao,
     required this.natureza_operacao,
   });

   factory WebTipoOperacao.fromJson(Map<String, dynamic> json) {
     return WebTipoOperacao(
       ativo: json['ativo'] ?? "",
       id_operacao: json['id_operacao'] ?? "",
       nome_operacao: json['nome_operacao'] ?? "",
       natureza_operacao: json['natureza_operacao'] ?? "");
   }

   static List<WebTipoOperacao> fromJsonList(dynamic jsonList) {
     final transactionDetailsList = <WebTipoOperacao>[];
     if (jsonList == null) return transactionDetailsList;

     if (jsonList is List<dynamic>) {
       for (final json in jsonList) {
         transactionDetailsList.add(
           WebTipoOperacao.fromJson(json),
         );
       }
     }
     return transactionDetailsList;
   }

   Map<String, dynamic> toJoson() => {
     ativo: ativo,
     id_operacao: id_operacao,
     nome_operacao: nome_operacao,
     natureza_operacao: natureza_operacao,
   };
}