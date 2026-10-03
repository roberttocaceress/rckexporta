class WebCodigoStatusDoc {
   String id;
   String codigo;

   WebCodigoStatusDoc({
     required this.id,
     required this.codigo,
   });

   factory WebCodigoStatusDoc.fromJson(Map<String, dynamic> json) {
     return WebCodigoStatusDoc(
       id: json['id'] ?? "",
       codigo: json['codigo'] ?? "");
   }

   static List<WebCodigoStatusDoc> fromJsonList(dynamic jsonList) {
     final transactionDetailsList = <WebCodigoStatusDoc>[];
     if (jsonList == null) return transactionDetailsList;

     if (jsonList is List<dynamic>) {
       for (final json in jsonList) {
         transactionDetailsList.add(
           WebCodigoStatusDoc.fromJson(json),
         );
       }
     }
     return transactionDetailsList;
   }

   Map<String, dynamic> toJoson() => {
     id: id,
     codigo: codigo,
   };
}