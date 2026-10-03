import 'package:rck_painel_tarefa/model/web_produto_detalhe.dart';

class WebProduto {
  String ativo;
  String id_produto;
  String nome_produto;
  String unidade;
  String tipo_cadastro;
  String id_entidade;
  String ncm;
  String id_grupo;
  String id_sub_grupo;
  String peso_bruto;
  String peso_liquido;
  String codigo_em_barras;
  String movimenta_estoque;
  String nome_da_marca;
  String id_empresa;
  String id_origem;
  String custo_produto;
  String custo_per_ipi;
  String custo_ipi;
  String custo_per_frete;
  String custo_frete;
  String custo_per_icms;
  String custo_icms;
  String custo_per_fin;
  String custo_fin;
  String custo_per_subst;
  String custo_subt;
  String custo_per_outros;
  String custo_outros;
  String valor_custo;
  String excluido;
  String excluido_por;
  String excluido_por_data;
  String excluido_codigo_novo;
  String ajuste_preco_data;
  String ajuste_preco_nfe;
  String ajuste_preco_usuario;
  String total_custo;
  String total_credito;
  String valor_custo_estoque;
  String custo_data_inicial;
  String custo_valor_inicial;
  String produto_venda;
  String produto_insumo;
  String produto_consumo;
  String produto_producao;
  String venda_perc_comissao;
  String venda_preco;
  String venda_perc_comissao_dois;
  String descricao;
  String nome_sub_grupo;
  String nome_grupo;
  String produto_materia_prima;
  String produto_tercerizacao;
  double saldo_estoque;
  String travar_fat_sem_estoque;
  String utiliza_tabela_preco;
  String produto_edita_preco;

  double produto_st_aliquota;
  String produto_suj_icms_st;


  int idLinhaColecao;
  String produto_referencia;
  String desc_maximo_a_vista;
  String base64;
  String id_web_item_pedido;
  List<WebProdutoDetalhe> webProdutoDetalhe;


  WebProduto({
    required this.ativo,
    required this.id_produto,
    required this.nome_produto,
    required this.unidade,
    required this.tipo_cadastro,
    required this.id_entidade,
    required this.ncm,
    required this.id_grupo,
    required this.id_sub_grupo,
    required this.peso_bruto,
    required this.peso_liquido,
    required this.codigo_em_barras,
    required this.movimenta_estoque,
    required this.nome_da_marca,
    required this.id_empresa,
    required this.id_origem,
    required this.custo_produto,
    required this.custo_per_ipi,
    required this.custo_ipi,
    required this.custo_per_frete,
    required this.custo_frete,
    required this.custo_per_icms,
    required this.custo_icms,
    required this.custo_per_fin,
    required this.custo_fin,
    required this.custo_per_subst,
    required this.custo_subt,
    required this.custo_per_outros,
    required this.custo_outros,
    required this.valor_custo,
    required this.excluido,
    required this.excluido_por,
    required this.excluido_por_data,
    required this.excluido_codigo_novo,
    required this.ajuste_preco_data,
    required this.ajuste_preco_nfe,
    required this.ajuste_preco_usuario,
    required this.total_custo,
    required this.total_credito,
    required this.valor_custo_estoque,
    required this.custo_data_inicial,
    required this.custo_valor_inicial,
    required this.produto_venda,
    required this.produto_insumo,
    required this.produto_consumo,
    required this.produto_producao,
    required this.venda_perc_comissao,
    required this.venda_preco,
    required this.venda_perc_comissao_dois,
    required this.descricao,
    required this.nome_sub_grupo,
    required this.nome_grupo,
    required this.produto_materia_prima,
    required this.produto_tercerizacao,
    required this.saldo_estoque,
    required this.travar_fat_sem_estoque,
    required this.utiliza_tabela_preco,
    required this.produto_edita_preco,
    required this.produto_st_aliquota,
    required this.produto_suj_icms_st,
    required this.idLinhaColecao,
    required this.produto_referencia,
    required this.desc_maximo_a_vista,
    required this.base64,
    required this.id_web_item_pedido,
    required this.webProdutoDetalhe,

  });

  factory WebProduto.fromJson(Map<String, dynamic> json) {
    return WebProduto(
        ativo: json['ativo'] ?? "",
        id_produto: json['id_produto'] ?? "",
        nome_produto: json['nome_produto'] ?? "",
        unidade: json['unidade'] ?? "",
        tipo_cadastro: json['tipo_cadastro'] ?? "",
        id_entidade: json['id_entidade'] ?? "",
        ncm: json['ncm'] ?? "",
        id_grupo: json['id_grupo' ]?? "",
        id_sub_grupo: json['id_sub_grupo'] ?? "",
        peso_bruto: json['peso_bruto'] ?? "",
        peso_liquido: json['peso_liquido'] ?? "",
        codigo_em_barras: json['codigo_em_barras'] ?? "",
        movimenta_estoque: json['movimenta_estoque'] ?? "",
        nome_da_marca: json['nome_da_marca'] ?? "",
        id_empresa: json['id_empresa'] ?? "",
        id_origem: json['id_origem'] ?? "",
        custo_produto: json['custo_produto'] ?? "",
        custo_per_ipi: json['custo_per_ipi'] ?? "",
        custo_ipi: json['custo_ipi'] ?? "",

        custo_per_frete: json['custo_per_frete'] ?? "",
        custo_frete: json['custo_frete'] ?? "",
        custo_per_icms: json['custo_per_icms'] ?? "",
        custo_icms: json['custo_icms'] ?? "",
        custo_per_fin: json['custo_per_fin'] ?? "",
        custo_fin: json['custo_fin'] ?? "",
        custo_per_subst: json['custo_per_subst'] ?? "",
        custo_subt: json['custo_subt'] ?? "",
        custo_per_outros: json['custo_per_outros'] ?? "",
        custo_outros: json['custo_outros'] ?? "",
        valor_custo: json['valor_custo'] ?? "",
        excluido: json['excluido'] ?? "",
        excluido_por: json['excluido_por'] ?? "",
        excluido_por_data: json['excluido_por_data'] ?? "",
        excluido_codigo_novo: json['excluido_codigo_novo'] ?? "",
        ajuste_preco_data: json['ajuste_preco_data'] ?? "",
        ajuste_preco_nfe: json['ajuste_preco_nfe'] ?? "",
        ajuste_preco_usuario: json['ajuste_preco_usuario'] ?? "",
        total_custo: json['total_custo'] ?? "",
        total_credito: json['total_credito'] ?? "",
        valor_custo_estoque: json['valor_custo_estoque'] ?? "",
        custo_data_inicial: json['custo_data_inicial'] ?? "",
        custo_valor_inicial: json['custo_valor_inicial'] ?? "",
        produto_venda: json['produto_venda'] ?? "",
        produto_insumo: json['produto_insumo'] ?? "",
        produto_consumo: json['produto_consumo'] ?? "",
        produto_producao: json['produto_producao'] ?? "",
        venda_perc_comissao: json['venda_perc_comissao'] ?? "",
        venda_preco: json['venda_preco'] ?? "",
        venda_perc_comissao_dois: json['venda_perc_comissao_dois'] ?? "",
        descricao: json['descricao'] ?? "",
        nome_sub_grupo: json['nome_sub_grupo']  ?? "",
        nome_grupo: json['nome_grupo'] ?? "",
        produto_materia_prima: json['produto_materia_prima'] ?? "",
        produto_tercerizacao: json['produto_tercerizacao'] ?? "",
        saldo_estoque: json['saldo_estoque'] ?? "",
        travar_fat_sem_estoque: json['travar_fat_sem_estoque'] ?? "",
        utiliza_tabela_preco: json['utiliza_tabela_preco'] ?? "",
        produto_edita_preco: json['produto_edita_preco'] ?? "",
        produto_st_aliquota: json['produto_st_aliquota'] ?? 0.00,
        produto_suj_icms_st: json['produto_suj_icms_st'] ?? "",
        idLinhaColecao: json['idLinhaColecao'] ?? 0,
        produto_referencia: json['produto_referencia'] ?? "",
        desc_maximo_a_vista: json['desc_maximo_a_vista'] ?? "",
        base64: json['base64'] ?? "",
        id_web_item_pedido: json['id_web_item_pedido'] ?? "0",
        webProdutoDetalhe: WebProdutoDetalhe.fromJsonList(json['web_produto_detalhe']) ,);
  }

  static List<WebProduto> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebProduto>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebProduto.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

  static List<WebProdutoDetalhe> fromJsonListDet(dynamic jsonList) {
    final transactionDetailsList = <WebProdutoDetalhe>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebProdutoDetalhe.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }
}