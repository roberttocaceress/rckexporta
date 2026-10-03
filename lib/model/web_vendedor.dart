import 'package:cloud_firestore/cloud_firestore.dart';

class WebVendedor {
  String id_vendedor;
  String nome_vendedor;
  String empresa;
  String versao_aplicativo;
  String ultima_sincronizacao;
  String status;

  WebVendedor({
    required this.id_vendedor,
    required this.nome_vendedor,
    required this.empresa,
    required this.versao_aplicativo,
    required this.ultima_sincronizacao,
    required this.status,
  });

  factory WebVendedor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WebVendedor(
      id_vendedor: data['id_vendedor'] ?? "",
      nome_vendedor: data['nome_vendedor'] ?? "",
      empresa: data['empresa'] ?? "",
      versao_aplicativo: data['versao_aplicativo'] ?? "",
      ultima_sincronizacao: data['ultima_sincronizacao'] ?? "",
      status: data['status'] ?? "",
    );
  }

  factory WebVendedor.fromJson(Map<String, dynamic> json) {
    return WebVendedor(
      id_vendedor: json['id_vendedor'] ?? "",
      nome_vendedor: json['nome_vendedor'] ?? "",
      empresa: json['empresa'] ?? "",
      versao_aplicativo: json['versao_aplicativo'] ?? "",
      ultima_sincronizacao: json['ultima_sincronizacao'] ?? "",
      status: json['status'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_vendedor': id_vendedor,
      'nome_vendedor': nome_vendedor,
      'empresa': empresa,
      'versao_aplicativo': versao_aplicativo,
      'ultima_sincronizacao': ultima_sincronizacao,
      'status': status,
    };
  }
}
