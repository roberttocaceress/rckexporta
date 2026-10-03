
import 'package:cloud_firestore/cloud_firestore.dart';

class WebUsuario{
  String id_usuario;
  String ativo;
  String nome_usuario;
  String login;
  String senha;
  String token;
  String id_vendedor;
  WebUsuario({
    required this.id_usuario,
    required this.ativo,
    required this.nome_usuario,
    required this.login,
    required this.senha,
    required this.token,
    required this.id_vendedor
  });


  factory WebUsuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WebUsuario(
      id_usuario:  '',
      ativo: data['ativo'] ?? '',
      nome_usuario: data['nome_usuario'] ?? 0,
      login:  data['login'] ?? 0,
      senha:  data['senha'] ?? 0,
      token: data['token'] ?? 0,
      id_vendedor: '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ativo' :ativo,
      'nome_usuario': nome_usuario,
      'login': login,
      'senha' : senha,
      'token' : token,
    };
  }

  factory WebUsuario.fromJson(Map<String, dynamic> json) {
    return WebUsuario(
        id_usuario: json['id_usuario'],
        ativo: json['ativo'],
        nome_usuario: json['nome_usuario'],
        login: json['login'],
        token: json['token'],
        senha: json['senha'],
        id_vendedor: json['id_vendedor' ?? 0]);

  }

  static List<WebUsuario> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebUsuario>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebUsuario.fromJson(json),
        );
      }
    }

    return transactionDetailsList;
  }


/*
  Usuario({required this.id_usuario, required this.ativo, required this.nome_usuario,required this.login});
  factory Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

   */
}
/*
@JsonSerializable()
class ResponseUsuario{
  int code;
  dynamic meta;
  List<dynamic>data;
  ResponseUsuario({required this.code, this.meta, required this.data});
  factory ResponseUsuario.fromJson(Map<String, dynamic> json) => _$ResponseUsuarioFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseUsuarioToJson(this);
}

 */
