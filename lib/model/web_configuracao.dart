class WebConfiguracao {
  String id;
  String usuario;
  String senha;
  String trabalha_com_campanhas;
  String trabalha_com_dscto_reais;
  String trabalha_com_limite_cred;
  String trabalha_com_pre_pedido;
  String pesquisa_produto_por_linha_grupo; //G Grupo L Linha
  String trabalha_com_confirmacao_prazo;
  String trabalha_com_unidade_manut_estoque;
  String trabalha_com_paginacao_dados;
  String layout_venda_erp;
  String id_con_pgto_default_app;
  String trabalha_com_cobranca;
  String trabalha_com_icms_st;
  String trabalha_com_desc_auto_app; //Desconto automatico ao incluir item no app
  String sincronia_automatica_app;
  String trabalha_com_verba_pedido;
  String lista_todos_pedidos;
  String cadastra_cliente_app;
  String visual_hist_fin_pedido_app;
  String visual_prazo_pgto_pedido_app;
  String visual_estoque_produto_app;
  String ordem_lista_cliente;
  String qtde_maior_estoque;


  WebConfiguracao({
    required this.id,
    required this.usuario,
    required this.senha,
    required this.trabalha_com_campanhas,
    required this.trabalha_com_dscto_reais,
    required this.trabalha_com_limite_cred,
    required this.trabalha_com_pre_pedido,
    required this.pesquisa_produto_por_linha_grupo, //G Grupo L Linha
    required this.trabalha_com_confirmacao_prazo,
    required this.trabalha_com_unidade_manut_estoque,
    required this.trabalha_com_paginacao_dados,
    required this.layout_venda_erp,
    required this.id_con_pgto_default_app,
    required this.trabalha_com_cobranca,
    required this.trabalha_com_icms_st,
    required this.trabalha_com_desc_auto_app, //Desconto automatico ao incluir item no app
    required this.sincronia_automatica_app,
    required this.trabalha_com_verba_pedido,
    required this.lista_todos_pedidos,
    required this.cadastra_cliente_app,
    required this.visual_hist_fin_pedido_app,
    required this.visual_prazo_pgto_pedido_app,
    required this.visual_estoque_produto_app,
    required this.ordem_lista_cliente,
    required this.qtde_maior_estoque,

  });

  factory WebConfiguracao.fromJson(Map<String, dynamic> json) {
    return WebConfiguracao(
      id: json['id'] ?? "",
      usuario: json['usuario'] ?? "",
      senha: json['senha'] ?? "",
      trabalha_com_campanhas: json['trabalha_com_campanhas'] ?? "N",
      trabalha_com_dscto_reais: json['trabalha_com_dscto_reais'] ?? "N",
      trabalha_com_limite_cred: json['trabalha_com_limite_cred'] ?? "N",
      trabalha_com_pre_pedido: json['trabalha_com_pre_pedido'] ?? "N",
      pesquisa_produto_por_linha_grupo: json['pesquisa_produto_por_linha_grupo'] ?? "",
      trabalha_com_confirmacao_prazo: json['trabalha_com_confirmacao_prazo'] ?? "N",
      trabalha_com_unidade_manut_estoque: json['trabalha_com_unidade_manut_estoque'] ?? "N",
      trabalha_com_paginacao_dados: json['trabalha_com_paginacao_dados'] ?? "N",
      layout_venda_erp: json['layout_venda_erp'] ?? "",
      id_con_pgto_default_app: json['id_con_pgto_default_app'] ?? "",
      trabalha_com_cobranca: json['trabalha_com_cobranca'] ?? "N",
      trabalha_com_icms_st: json['trabalha_com_icms_st'] ?? "N",
      trabalha_com_desc_auto_app: json['trabalha_com_desc_auto_app'] ?? "N",
      //Desconto automatico ao incluir item no app
      sincronia_automatica_app: json['sincronia_automatica_app'] ?? "N",
      trabalha_com_verba_pedido: json['trabalha_com_verba_pedido'] ?? "N",
      lista_todos_pedidos: json['lista_todos_pedidos'] ?? "",
      cadastra_cliente_app: json['cadastra_cliente_app'] ?? "N",
      visual_hist_fin_pedido_app: json['visual_hist_fin_pedido_app'] ?? "",
      visual_prazo_pgto_pedido_app: json['visual_prazo_pgto_pedido_app'] ?? "",
      visual_estoque_produto_app: json['visual_estoque_produto_app'] ?? "",
      ordem_lista_cliente: json['ordem_lista_cliente'] ?? "",
      qtde_maior_estoque: json['qtde_maior_estoque'] ?? "N",
    );
  }

  static List<WebConfiguracao> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebConfiguracao>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebConfiguracao.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

  Map<String, dynamic> toJson() => {

  'id': id,
  'usuario': usuario,
  'senha': senha,
  'trabalha_com_campanhas': trabalha_com_campanhas,
  'trabalha_com_dscto_reais': trabalha_com_dscto_reais,
  'trabalha_com_limite_cred': trabalha_com_limite_cred,
  'trabalha_com_pre_pedido': trabalha_com_pre_pedido,
  'pesquisa_produto_por_linha_grupo': pesquisa_produto_por_linha_grupo,  //G Grupo L Linha
  'trabalha_com_confirmacao_prazo': trabalha_com_confirmacao_prazo,
  'trabalha_com_unidade_manut_estoque': trabalha_com_unidade_manut_estoque,
  'trabalha_com_paginacao_dados': trabalha_com_paginacao_dados,
  'layout_venda_erp': layout_venda_erp,
  'id_con_pgto_default_app': id_con_pgto_default_app,
  'trabalha_com_cobranca': trabalha_com_cobranca,
  'trabalha_com_icms_st': trabalha_com_icms_st,
  'trabalha_com_desc_auto_app': trabalha_com_desc_auto_app,  //Desconto automatico ao incluir item no app
  'sincronia_automatica_app': sincronia_automatica_app,
  'trabalha_com_verba_pedido': trabalha_com_verba_pedido,
  'lista_todos_pedidos': lista_todos_pedidos,
  'cadastra_cliente_app': cadastra_cliente_app,
  'visual_hist_fin_pedido_app': visual_hist_fin_pedido_app,
  'visual_prazo_pgto_pedido_app': visual_prazo_pgto_pedido_app,
  'visual_estoque_produto_app': visual_estoque_produto_app,
  'ordem_lista_cliente': ordem_lista_cliente,
};
}
