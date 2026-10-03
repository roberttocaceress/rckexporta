import 'package:rck_painel_tarefa/model/web_produto.dart';

class WebPedidoItens{
  String id_web_item;
  String id_pedido;
  String id_item_pedido;
  String quantidade;
  String valor_unitario;
  String valor_bruto;
  String valor_desconto_per;
  String valor_desconto_real;
  String valor_desconto_per_add;
  String valor_desconto_real_add;
  String valor_total;
  String data_movimentacao;
  String usuario_lancamento_id;
  String usuario_lancamento_data;
  WebProduto cadastro;

  String id_item_desconto;
  String id_tabela_preco;
  String valor_desconto_per_orig;
  String valor_desconto_real_orig;
  String valor_desconto_per_add_orig;
  String valor_desconto_real_add_orig;
  String id_tabela_preco_faixa_orig;
  String valor_total_orig;
  String valor_preco_pago;
  String id_web_item_servidor;
  String tipoDesconto;
  int idCampanha;
  String nomeCampanha;
  String descontoIndevido;
  String produtoBase;
  String campanhaIndevida;
  bool produtoAtivo;
  String produto_edita_valor;
  String produto_preco_editado;
  String valor_desconto_adic;
  String perc_desconto_adic;
  String icms_st_valor;
  String icms_st_percentual;
  String icms_st_calcula;


  WebPedidoItens({
    required this.id_web_item,
    required this.id_pedido,
    required this.id_item_pedido,
    required this.quantidade,
    required this.valor_unitario,
    required this.valor_bruto,
    required this.valor_desconto_per,
    required this.valor_desconto_real,
    required this.valor_desconto_per_add,
    required this.valor_desconto_real_add,
    required this.valor_total,
    required this.data_movimentacao,
    required this.usuario_lancamento_id,
    required this.usuario_lancamento_data,
    required this.cadastro,


    required this.id_item_desconto,
    required this.id_tabela_preco,
    required this.valor_desconto_per_orig,
    required this.valor_desconto_real_orig,
    required this.valor_desconto_per_add_orig,
    required this.valor_desconto_real_add_orig,
    required this.id_tabela_preco_faixa_orig,
    required this.valor_total_orig,
    required this.valor_preco_pago,
    required this.id_web_item_servidor,
    required this.tipoDesconto,
    required this.idCampanha,
    required this.nomeCampanha,
    required this.descontoIndevido,
    required this.produtoBase,
    required this.campanhaIndevida,
    required this.produtoAtivo,
    required this.produto_edita_valor,
    required this.produto_preco_editado,
    required this.valor_desconto_adic,
    required this.perc_desconto_adic,
    required this.icms_st_valor,
    required this.icms_st_percentual,
    required this.icms_st_calcula


  });

  factory WebPedidoItens.fromJson(Map<String, dynamic> json) {
    return WebPedidoItens(
        id_web_item: json['id_web_item'] ?? "",
        id_pedido: json['id_pedido'] ?? "",
        id_item_pedido: json['id_produto'] ?? "",
        quantidade: json['quantidade'] ?? "",
        valor_unitario: json['valor_unitario'] ?? "",
        valor_bruto: json['valor_bruto'] ?? "",
        valor_desconto_per: json['valor_desconto_per'] ?? "",
        valor_desconto_real: json['valor_desconto_real'] ?? "",
        valor_desconto_per_add: json['valor_desconto_per_add'] ?? "",
        valor_desconto_real_add: json['valor_desconto_real_add'] ?? "",
        valor_total: json['valor_total'] ?? "",
        data_movimentacao: json['data_movimentacao'] ?? "",
        usuario_lancamento_id: json['usuario_lancamento_id'] ?? "",
        usuario_lancamento_data: json['usuario_lancamento_data'] ?? "",
        cadastro: WebProduto.fromJson(json['cadastro']) ,

        id_item_desconto: json['id_item_desconto'] ?? "",
        id_tabela_preco: json['id_tabela_preco'] ?? "",
        valor_desconto_per_orig: json['valor_desconto_per_orig'] ?? "",
        valor_desconto_real_orig: json['valor_desconto_real_orig'] ?? "",
        valor_desconto_per_add_orig: json['valor_desconto_per_add_orig'] ?? "",
        valor_desconto_real_add_orig: json['valor_desconto_real_add_orig'] ?? "",
        id_tabela_preco_faixa_orig: json['id_tabela_preco_faixa_orig'] ?? "",
        valor_total_orig: json['valor_total_orig'] ?? "",
        valor_preco_pago: json['valor_preco_pago'] ?? "",
        id_web_item_servidor: json['id_web_item_servidor'] ?? "",
        tipoDesconto: json['tipoDesconto'] ?? "",
        idCampanha: json['idCampanha'] ?? "",
        nomeCampanha: json['nomeCampanha'] ?? "",
        descontoIndevido: json['descontoIndevido'] ?? "",
        produtoBase: json['produtoBase'] ?? "",
        campanhaIndevida: json['campanhaIndevida'] ?? "",
        produtoAtivo: json['produtoAtivo'] ?? "",
        produto_edita_valor: json['produto_edita_valor'] ?? "",
        produto_preco_editado: json['produto_preco_editado'] ?? "",
        valor_desconto_adic: json['valor_desconto_adic'] ?? "",
        perc_desconto_adic: json['perc_desconto_adic'] ?? "",
        icms_st_valor: json['icms_st_valor'] ?? "",
        icms_st_percentual: json['icms_st_percentual'] ?? "",
        icms_st_calcula: json['icms_st_calcula'] ?? "" );
  }

  static List<WebPedidoItens> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebPedidoItens>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebPedidoItens.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

  Map<String, dynamic> toJson() => {
    'id_web_item': id_web_item ,
    'id_pedido': id_pedido ,
    'id_item_pedido': id_item_pedido ,
    'quantidade': quantidade ,
    'valor_unitario': valor_unitario ,
    'valor_bruto': valor_bruto ,
    'valor_desconto_per': valor_desconto_per ,
    'valor_desconto_real': valor_desconto_real ,
    'valor_desconto_per_add': valor_desconto_per_add ,
    'valor_desconto_real_add': valor_desconto_real_add ,
    'valor_total': valor_total ,
    'data_movimentacao': data_movimentacao ,
    'usuario_lancamento_id': usuario_lancamento_id ,
    'usuario_lancamento_data': usuario_lancamento_data ,

    'id_item_desconto': id_item_desconto,
    'id_tabela_preco': id_tabela_preco,
    'valor_desconto_per_orig': valor_desconto_per_orig,
    'valor_desconto_real_orig': valor_desconto_real_orig,
    'valor_desconto_per_add_orig': valor_desconto_per_add_orig,
    'valor_desconto_real_add_orig': valor_desconto_real_add_orig,
    'id_tabela_preco_faixa_orig': id_tabela_preco_faixa_orig,
    'valor_total_orig': valor_total_orig,
    'valor_preco_pago': valor_preco_pago,
    'id_web_item_servidor': id_web_item_servidor,
    'tipoDesconto': tipoDesconto,
    'idCampanha': idCampanha,
    'nomeCampanha': nomeCampanha,
    'descontoIndevido': descontoIndevido,
    'produtoBase': produtoBase,
    'campanhaIndevida': campanhaIndevida,
    'produtoAtivo': produtoAtivo,
    'produto_edita_valor': produto_edita_valor,
    'produto_preco_editado': produto_preco_editado,
    'valor_desconto_adic': valor_desconto_adic,
    'perc_desconto_adic': perc_desconto_adic,
    'icms_st_valor': icms_st_valor,
    'icms_st_percentual': icms_st_percentual,
    'icms_st_calcula': icms_st_calcula
  };
}