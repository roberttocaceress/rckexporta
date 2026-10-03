class WebResult {
   int id;
   String mensagem;
   bool sucesso;

   WebResult({
     required this.id,
     required this.mensagem,
     required this.sucesso
   });

   factory WebResult.fromJson(Map<String, dynamic> json) {
     return WebResult(
       id: json['id'] ?? "-1",
       mensagem: json['mensagem'] ?? "",
       sucesso: json['sucesso'] ?? false);
   }

   static List<WebResult> fromJsonList(dynamic jsonList) {
     final transactionDetailsList = <WebResult>[];
     if (jsonList == null) return transactionDetailsList;

     if (jsonList is List<dynamic>) {
       for (final json in jsonList) {
         transactionDetailsList.add(
           WebResult.fromJson(json),
         );
       }
     }
     return transactionDetailsList;
   }


}