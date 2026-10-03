import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_produto.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';

class WebPedido{
  String id_web_pedido;
  String id_web_cliente;
  String id_empresa;
  WebCliente cliente;
  //List<WebCliente> clientes;
  String id_vendedor;
  String id_outro_vendedor;
  String id_condicao_pagamento;
  String id_operacao;
  String id_tabela;
  String nome_extenso;
  String data_emissao;
  String valor_produtos;
  String valor_desconto;
  String valor_desconto_add;
  String desconto_per;
  String desconto_per_add;
  String valor_total;
  String excluido;
  String excluido_usuario_id;
  String excluido_usuario_nome;
  String excluido_usuario_data;
  String justificativa_exclusao;
  String usuario_lancamento_id;
  String usuario_lancamento_nome;
  String usuario_lancamento_data;
  String observacoes;
  String status;
  String id_pedido_venda;
  String id_nota_fiscal;
  String id_tabela_preco_faixa;
  String pontos_total;
  String pontos_coeficiente;
  String pontos_cor;
  String comissao_percentual;
  String comissao_valor;
  String id_faixa_final;
  String valor_bonus_credor;
  String perc_bonus_credor;
  String origem;
  String id_web_pedido_servidor;
  String data_prev_entrega;
  //List<WebPedidoItens> webPedidoItens;
  String pedido_enviado;
  String finalizado;

  String web_importado_data;
  String analise_credito;
  String analise_usuario_id;
  String analise_usuario_nome;
  String analise_usuario_data;
  String ordem_carregamento;
  String id_ordem_carregamento;
  String id_transportadora;
  String nome_transportadora;
  String numero_nota_fiscal;
  String data_nota_fiscal;

  /*String id_nota_fiscal;
      String excluido;
      String excluido_usuario_id;
      String EXCLUIDO_USUARIO_NOME;
      String EXCLUIDO_USUARIO_DATA;
      String JUSTIFICATIVA_EXCLUSAO;
    */
  String especie;
  String volumes;
  String web_valor_total;
  String expedicao_status;
  String id_pedido;
  String valor_faturado;
  String id_moeda_padrao;
  String descontoIndevido;
  String id_pedido_app;
  String prazo_confirmado;
  String valor_recibo;
  String valor_desconto_adic;
  String perc_desconto_adic;
  String cliente_novo;
  String valor_icms_st;
  String qtde_itens;
  String faturado;

  WebPedido({
    required this.id_web_pedido,
    required this.id_web_cliente,
    required this.id_empresa,
    required this.cliente,
    required this.id_vendedor,
    required this.id_outro_vendedor,
    required this.id_condicao_pagamento,
    required this.id_operacao,
    required this.id_tabela,
    required this.nome_extenso,
    required this.data_emissao,
    required this.valor_produtos,
    required this.valor_desconto,
    required this.valor_desconto_add,
    required this.desconto_per,
    required this.desconto_per_add,
    required this.valor_total,
    required this.excluido,
    required this.excluido_usuario_id,
    required this.excluido_usuario_nome,
    required this.excluido_usuario_data,
    required this.justificativa_exclusao,
    required this.usuario_lancamento_id,
    required this.usuario_lancamento_nome,
    required this.usuario_lancamento_data,
    required this.observacoes,
    required this.status,
    required this.id_pedido_venda,
    required this.id_nota_fiscal,
    required this.id_tabela_preco_faixa,
    required this.pontos_total,
    required this.pontos_coeficiente,
    required this.pontos_cor,
    required this.comissao_percentual,
    required this.comissao_valor,
    required this.id_faixa_final,
    required this.valor_bonus_credor,
    required this.perc_bonus_credor,
    required this.origem,
    required this.id_web_pedido_servidor,
    required this.data_prev_entrega,
    //List<WebPedidoItens> webPedidoItens,
    required this.pedido_enviado,
    required this.finalizado,

    required this.web_importado_data,
    required this.analise_credito,
    required this.analise_usuario_id,
    required this.analise_usuario_nome,
    required this.analise_usuario_data,
    required this.ordem_carregamento,
    required this.id_ordem_carregamento,
    required this.id_transportadora,
    required this.nome_transportadora,
    required this.numero_nota_fiscal,
    required this.data_nota_fiscal,

    required this.especie,
    required this.volumes,
    required this.web_valor_total,
    required this.expedicao_status,
    required this.id_pedido,
    required this.valor_faturado,
    required this.id_moeda_padrao,
    required this.descontoIndevido,
    required this.id_pedido_app,
    required this.prazo_confirmado,
    required this.valor_recibo,
    required this.valor_desconto_adic,
    required this.perc_desconto_adic,
    required this.cliente_novo,
    required this.valor_icms_st,
    required this.qtde_itens,
    required this.faturado,

  });

  factory WebPedido.fromJson(Map<String, dynamic> json) {
    return WebPedido(
      id_empresa: json['id_empresa'],
      id_vendedor: json['id_vendedor'],
      id_web_pedido: json['id_web_pedido'] ?? "",
      id_web_cliente: json['id_web_cliente'] ?? "",
      cliente: WebCliente.fromJson(json['cliente']) ,
      //clientes: [],
      id_outro_vendedor: json['id_outro_vendedor'] ?? "",
      id_condicao_pagamento: json['id_condicao_pagamento'] ?? "",
      id_operacao: json['id_operacao'] ?? "",
      id_tabela: json['id_tabela'] ?? "",
      nome_extenso: json['nome_extenso'] ?? "",
      data_emissao: json['data_emissao'] ?? "",
      valor_produtos: json['valor_produtos'] ?? "",
      valor_desconto: json['valor_desconto'] ?? "",
      valor_desconto_add: json['valor_desconto_add'] ?? "",
      desconto_per: json['desconto_per'] ?? "",
      desconto_per_add: json['desconto_per_add'] ?? "",
      valor_total: json['valor_total'] ?? "",
      excluido: json['excluido'] ?? "",
      excluido_usuario_id: json['excluido_usuario_id'] ?? "",
      excluido_usuario_nome: json['excluido_usuario_nome'] ?? "",
      excluido_usuario_data: json['excluido_usuario_data'] ?? "",
      justificativa_exclusao: json['justificativa_exclusao'] ?? "",
      usuario_lancamento_id: json['usuario_lancamento_id'] ?? "",
      usuario_lancamento_nome: json['usuario_lancamento_nome'] ?? "",
      usuario_lancamento_data: json['usuario_lancamento_data'] ?? "",
      observacoes: json['observacoes'] ?? "",
      status: json['status'] ?? "",
      id_pedido_venda: json['id_pedido_venda'] ?? "",
      id_nota_fiscal: json['id_nota_fiscal'] ?? "",
      id_tabela_preco_faixa: json['id_tabela_preco_faixa'] ?? "",
      pontos_total: json['pontos_total'] ?? "",
      pontos_coeficiente: json['pontos_coeficiente'] ?? "",
      pontos_cor: json['pontos_cor'] ?? "",
      comissao_percentual: json['comissao_percentual'] ?? "",
      comissao_valor: json['comissao_valor'] ?? "",
      id_faixa_final: json['id_faixa_final'] ?? "",
      valor_bonus_credor: json['valor_bonus_credor'] ?? "",
      perc_bonus_credor: json['perc_bonus_credor'] ?? "",
      origem: json['origem'] ?? "",
      id_web_pedido_servidor:  json['id_web_pedido_servidor'] ?? "",
      data_prev_entrega: json['data_prev_entrega'] ?? "",
      //List<WebPedidoItens> webPedidoItens:
      pedido_enviado: json['pedido_enviado'] ?? "",
      finalizado: json['finalizado'] ?? "",

      web_importado_data: json['web_importado_data'] ?? "",
      analise_credito: json['analise_credito'] ?? "",
      analise_usuario_id: json['analise_usuario_id'] ?? "",
      analise_usuario_nome: json['analise_usuario_nome'] ?? "",
      analise_usuario_data: json['analise_usuario_data'] ?? "",
      ordem_carregamento: json['ordem_carregamento'] ?? "",
      id_ordem_carregamento: json['id_ordem_carregamento'] ?? "",
      id_transportadora: json['id_transportadora'] ?? "",
      nome_transportadora: json['nome_transportadora'] ?? "",
      numero_nota_fiscal: json['numero_nota_fiscal'] ?? "",
      data_nota_fiscal: json['data_nota_fiscal'] ?? "",

      especie: json['especie'] ?? "",
      volumes: json['volumes'] ?? "",
      web_valor_total: json['web_valor_total'] ?? "",
      expedicao_status: json['expedicao_status'] ?? "",
      id_pedido: json['id_pedido'] ?? "",
      valor_faturado: json['valor_faturado'] ?? "",
      id_moeda_padrao: json['id_moeda_padrao'] ?? "",
      descontoIndevido: json['descontoIndevido'] ?? "",
      id_pedido_app: json['id_pedido_app'] ?? "",
      prazo_confirmado: json['prazo_confirmado'] ?? "",
      valor_recibo: json['valor_recibo'] ?? "",
      valor_desconto_adic: json['valor_desconto_adic'] ?? "",
      perc_desconto_adic: json['perc_desconto_adic'] ?? "",
      cliente_novo: json['cliente_novo'] ?? "",
      valor_icms_st: json['valor_icms_st'] ?? "",
      qtde_itens: json['qtde_itens'] ?? "",
      faturado:json['faturado'] ?? "" );

  }

  static List<WebPedido> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebPedido>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebPedido.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

  Map<String, dynamic> toJson() => {

  'id_empresa': id_empresa,
  'id_vendedor': id_vendedor,
  'id_web_pedido': id_web_pedido,
  'id_web_cliente': id_web_cliente,
  //'clientes': clientes,
  'id_outro_vendedor': id_outro_vendedor,
  'id_condicao_pagamento': id_condicao_pagamento,
  'id_operacao': id_operacao,
  'id_tabela': id_tabela,
  'nome_extenso': nome_extenso,
  'data_emissao': data_emissao,
  'valor_produtos': valor_produtos,
  'valor_desconto': valor_desconto,
  'valor_desconto_add': valor_desconto_add,
  'desconto_per': desconto_per,
  'desconto_per_add': desconto_per_add,
  'valor_total': valor_total,
  'usuario_lancamento_id': usuario_lancamento_id,
  'usuario_lancamento_nome': usuario_lancamento_nome,
  'usuario_lancamento_data': usuario_lancamento_data,
  'observacoes': observacoes,
  'status': status,
  'id_pedido_venda': id_pedido_venda,
  'id_tabela_preco_faixa': id_tabela_preco_faixa,
  'pontos_total': pontos_total,
  'pontos_coeficiente': pontos_coeficiente,
  'comissao_percentual': comissao_percentual,
  'comissao_valor': comissao_valor,
  'id_faixa_final': id_faixa_final,
  'origem': origem,
  'id_web_pedido_servidor':  id_web_pedido_servidor,
  'data_prev_entrega': data_prev_entrega,
  'pedido_enviado': pedido_enviado,
  'finalizado': finalizado,

  'especie': especie,
  'volumes': volumes,
  'web_valor_total': web_valor_total,
  'expedicao_status': expedicao_status,
  'id_pedido': id_pedido,
  'id_moeda_padrao': id_moeda_padrao,
  'descontoIndevido': descontoIndevido,
  'id_pedido_app': id_pedido_app,
  'prazo_confirmado': prazo_confirmado,
  'valor_recibo': valor_recibo,
  'valor_desconto_adic': valor_desconto_adic,
  'perc_desconto_adic': perc_desconto_adic,
  'cliente_novo': cliente_novo,
  'valor_icms_st': valor_icms_st,
  'qtde_itens': qtde_itens,


  };
}