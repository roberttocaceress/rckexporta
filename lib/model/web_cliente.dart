import 'package:rck_painel_tarefa/model/web_analise_arquivo_xml.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';
import 'package:rck_painel_tarefa/model/web_status_exportacao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class WebCliente {
  String ativo;
  String id_cadastro;
  String nome_cadastro;
  String nome_fantasia;
  String cpf_cnpj;
  /*
  String inscri_estadual;
  String endereco;
  String endereco_bairro;
  String endereco_numero;
  String endereco_complemento;
  String endereco_uf;
  String nome_municipio;
  String endereco_cep;
  String usuario_id;
  String usuario_nome;
  String usuario_data;
  String f_cliente;
  String f_fornecedor;
  String f_funcionario;
  String f_vendedor;
  String f_transportador;
  String data_ultima_compra;
  String nome_vendedor;
  String f_id_cliente;
  String id_entidade;
  String f_id_fornecedor;
  String f_id_vendedor;
  String f_id_transportador;
  String telefone_principal;
  String email_principal;
  String id_pais;
  String f_id_funcionario;
  String avisar_com_dias;
  String observacoes;
  String padrao_id_c_custo;
  String padrao_id_c_gerenciadora;
  String padrao_id_c_analitica;
  String cob_endereco;
  String cob_endereco_bairro;
  String cob_endereco_numero;
  String cob_endereco_complemento;
  String cob_endereco_uf;
  String nome_cob_municipio;
  String cob_endereco_cep;
  String cob_endereco_id_pais;
  String limite_credito;
  String limite_disponivel;
  String pessoa_contato_financeiro;
  String email_financeiro;
  String observacoes_faturamento;
  String observacoes_financeiro;
  String telefone_dois;
  String telefone_tres;
  String pessoa_contato_principal;
  String ind_da_ie_destinatario;
  String comissao_percentual;
  String id_setor;
  String nfe_email_enviar;
  String nfe_email_um;
  String nfe_email_dois;
  String nfe_email_tres;
  String nfe_email_quatro;
  String nfe_email_cinco;
  String id_grupo_vendedor;
  String vendedor_usa_portal;
  String vendedor_id_user_portal;
  String f_tarifa;
  String f_id_tarifa;
  String f_produtor;
  String rg_numero;
  String rg_ssp;
  String conta_contabil;
  String motorista;
  String f_id_motorista;
  String habilitacao_numero;
  String habilitacao_categoria;
  String habilitacao_vencimento;
  String mot_id_transportadora;
  String local_cadastro;
  int idCategoria;
  int id_vendedor;
  String id_prospect;
  String alterado;

  String situacaoPredio;
  String finalizado;
  String id_tabela_preco;
  String nome_tabela_preco;

  String utiliza_tabela_preco;
  String tipo_tabela_preco;
  String financeiro_vencido;
  String financeiro_vencendo;
  String pedido_analise;
  String latitude;
  String longitude;
  String id_promocao;
  int id_regiao;
  int id_bairro;
  int rota_sequencia;
  String nome_categoria;

   */
  String url_api;
  String url_api_on_line;
  WebStatusApi webStatusApi;
  WebStatusExportacao webStatusExportacao;

  WebStatusExportacao webStatusErroAddArquivo ;

  WebStatusExportacao webStatusDadosInvalido;
  //WebAnaliseArquivoXml webAnaliseArquivoXml;

  String data_exportacao_1;
  String data_exportacao_2;
  String status_exportacao_1;
  String status_exportacao_2;

  String hora_exportacao_1;
  String hora_exportacao_2;
  String fuso_horario;
  String tempo_status_api;
  String email_exportacao_1;
  String email_exportacao_2;
  String email_envio_ativo;

  String notas_com_erro ;
  String exportacao_com_erro;
  String data_online;

  WebCliente(
      {required this.ativo,
      //required this.id_empresa,
      required this.id_cadastro,
      //required this.id_cadastro_servidor,
      //required this.pessoa_f_j,
      //required this.data_aniversario,
      required this.nome_cadastro,
      required this.nome_fantasia,
      required this.cpf_cnpj,
      /*
        required this.inscri_estadual,
      required this.endereco,
      required this.endereco_bairro,
      required this.endereco_numero,
      required this.endereco_complemento,
      required this.endereco_uf,
      required this.nome_municipio,
      required this.endereco_cep,
      required this.usuario_id,
      required this.usuario_nome,
      required this.usuario_data,
      required this.f_cliente,
      required this.f_fornecedor,
      required this.f_funcionario,
      required this.f_vendedor,
      required this.f_transportador,
      required this.data_ultima_compra,
      required this.nome_vendedor,
      required this.f_id_cliente,
      required this.id_entidade,
      required this.f_id_fornecedor,
      required this.f_id_vendedor,
      required this.f_id_transportador,
      required this.telefone_principal,
      required this.email_principal,
      required this.id_pais,
      required this.f_id_funcionario,
      required this.avisar_com_dias,
      required this.observacoes,
      required this.padrao_id_c_custo,
      required this.padrao_id_c_gerenciadora,
      required this.padrao_id_c_analitica,
      required this.cob_endereco,
      required this.cob_endereco_bairro,
      required this.cob_endereco_numero,
      required this.cob_endereco_complemento,
      required this.cob_endereco_uf,
      required this.nome_cob_municipio,
      required this.cob_endereco_cep,
      required this.cob_endereco_id_pais,
      required this.limite_credito,
      required this.limite_disponivel,
      required this.pessoa_contato_financeiro,
      required this.email_financeiro,
      required this.observacoes_faturamento,
      required this.observacoes_financeiro,
      required this.telefone_dois,
      required this.telefone_tres,
      required this.pessoa_contato_principal,
      required this.ind_da_ie_destinatario,
      required this.comissao_percentual,
      required this.id_setor,
      required this.nfe_email_enviar,
      required this.nfe_email_um,
      required this.nfe_email_dois,
      required this.nfe_email_tres,
      required this.nfe_email_quatro,
      required this.nfe_email_cinco,
      required this.id_grupo_vendedor,
      required this.vendedor_usa_portal,
      required this.vendedor_id_user_portal,
      required this.f_tarifa,
      required this.f_id_tarifa,
      required this.f_produtor,
      required this.rg_numero,
      required this.rg_ssp,
      required this.conta_contabil,
      required this.motorista,
      required this.f_id_motorista,
      required this.habilitacao_numero,
      required this.habilitacao_categoria,
      required this.habilitacao_vencimento,
      required this.mot_id_transportadora,
      required this.local_cadastro,
      required this.idCategoria,
      required this.id_vendedor,
      required this.id_prospect,
      required this.alterado,
      //List<CadastroAnexo> listaCadastroAnexo = new ArrayList<>(),
      required this.situacaoPredio,
      required this.finalizado,
      required this.id_tabela_preco,
      required this.nome_tabela_preco,
      required this.utiliza_tabela_preco,
      required this.tipo_tabela_preco,
      required this.financeiro_vencido,
      required this.financeiro_vencendo,
      required this.pedido_analise,
      required this.latitude,
      required this.longitude,
      required this.id_promocao,
      required this.id_regiao,
      required this.id_bairro,
      required this.rota_sequencia,
      required this.nome_categoria,

       */
      required this.url_api,
      required this.url_api_on_line,

      required this.webStatusApi,
      required this.webStatusExportacao,
      required this.webStatusErroAddArquivo,
      required this.webStatusDadosInvalido,
      //required this.webAnaliseArquivoXml,

      required this.data_exportacao_1,
      required this.data_exportacao_2,
      required this.status_exportacao_1,
      required this.status_exportacao_2,

      required this.hora_exportacao_1,
      required this.hora_exportacao_2,
      required this.fuso_horario,
      required this.tempo_status_api,
      required this.email_exportacao_1,
      required this.email_exportacao_2,
      required this.email_envio_ativo,
      required this.notas_com_erro,
      required this.exportacao_com_erro,
      required this.data_online,
      /*required this.status_api*/});

  factory WebCliente.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WebCliente(
        ativo: data['ativo'] ?? "N",
        //id_empresa: data['id_empresa'] ?? "",
        id_cadastro: data['id_cadastro'] ?? "",
        //id_cadastro_servidor: data['id_cadastro_servidor'] ?? "",
        //pessoa_f_j: data['pessoa_f_j'] ?? "",
        //data_aniversario: data['data_aniversario'] ?? "",
        nome_cadastro: data['nome_cadastro'] ?? data['razao_social'],
        nome_fantasia: data['nome_fantasia'] ?? "",
        cpf_cnpj: data['cpf_cnpj'] ?? data['cnpj_cpf'],
        /*
        inscri_estadual: data['inscri_estadual'] ?? "",
        endereco: data['endereco'] ?? "",
        endereco_bairro: data['endereco_bairro'] ?? "",
        endereco_numero: data['endereco_numero'] ?? "",
        endereco_complemento: data['endereco_complemento'] ?? "",
        endereco_uf: data['endereco_uf'] ?? "",
        nome_municipio: data['nome_municipio'] ?? "",
        endereco_cep: data['endereco_cep'] ?? "",
        usuario_id: data['usuario_id'] ?? "",
        usuario_nome: data['usuario_nome'] ?? "",
        usuario_data: data['usuario_data'] ?? "",
        f_cliente: data['f_cliente'] ?? "",
        f_fornecedor: data['f_fornecedor'] ?? "",
        f_funcionario: data['f_funcionario'] ?? "",
        f_vendedor: data['f_vendedor'] ?? "",
        f_transportador: data['f_transportador'] ?? "",
        data_ultima_compra: data['data_ultima_compra'] ?? "",
        nome_vendedor: data['nome_vendedor'] ?? "",
        f_id_cliente: data['f_id_cliente'] ?? "",
        id_entidade: data['id_entidade'] ?? "",
        f_id_fornecedor: data['f_id_fornecedor'] ?? "",
        f_id_vendedor: data['f_id_vendedor'] ?? "",
        f_id_transportador: data['f_id_transportador'] ?? "",
        telefone_principal: data['telefone_principal'] ?? "",
        email_principal: data['email_principal'] ?? "",
        id_pais: data['id_web_pedido'] ?? "",
        f_id_funcionario: data['id_web_pedido'] ?? "",
        avisar_com_dias: data['id_web_pedido'] ?? "",
        observacoes: data['id_web_pedido'] ?? "",
        padrao_id_c_custo: data['id_web_pedido'] ?? "",
        padrao_id_c_gerenciadora: data['id_web_pedido'] ?? "",
        padrao_id_c_analitica: data['id_web_pedido'] ?? "",
        cob_endereco: data['cob_endereco'] ?? "",
        cob_endereco_bairro: data['cob_endereco_bairro'] ?? "",
        cob_endereco_numero: data['cob_endereco_numero'] ?? "",
        cob_endereco_complemento: data['cob_endereco_complemento'] ?? "",
        cob_endereco_uf: data['cob_endereco_uf'] ?? "",
        nome_cob_municipio: data['nome_cob_municipio'] ?? "",
        cob_endereco_cep: data['cob_endereco_cep'] ?? "",
        cob_endereco_id_pais: data['cob_endereco_id_pais'] ?? "",

        limite_credito: data['limite_credito'] ?? "0.00",
        limite_disponivel: data['limite_disponivel'] ?? "0.00",
        pessoa_contato_financeiro: data['pessoa_contato_financeiro'] ?? "",
        email_financeiro: data['email_financeiro'] ?? "",
        observacoes_faturamento: data['observacoes_faturamento'] ?? "",
        observacoes_financeiro: data['observacoes_financeiro'] ?? "",
        telefone_dois: data['telefone_dois'] ?? "",
        telefone_tres: data['telefone_tres'] ?? "",
        pessoa_contato_principal: data['pessoa_contato_principal'] ?? "",
        ind_da_ie_destinatario: data['ind_da_ie_destinatario'] ?? "",
        comissao_percentual: data['comissao_percentual'] ?? "",
        id_setor: data['id_setor'] ?? "",

        nfe_email_enviar: data['nfe_email_enviar'] ?? "",
        nfe_email_um: data['nfe_email_um'] ?? "",
        nfe_email_dois: data['nfe_email_dois'] ?? "",
        nfe_email_tres: data['nfe_email_tres'] ?? "",
        nfe_email_quatro: data['nfe_email_quatro'] ?? "",
        nfe_email_cinco: data['nfe_email_cinco'] ?? "",
        id_grupo_vendedor: data['id_grupo_vendedor'] ?? "",

        vendedor_usa_portal: data['vendedor_usa_portal'] ?? "",
        vendedor_id_user_portal: data['vendedor_id_user_portal'] ?? "",
        f_tarifa: data['f_tarifa'] ?? "",
        f_id_tarifa: data['f_id_tarifa'] ?? "",
        f_produtor: data['f_produtor'] ?? "",
        rg_numero: data['rg_numero'] ?? "",
        rg_ssp: data['rg_ssp'] ?? "",
        conta_contabil: data['conta_contabil'] ?? "",

        motorista: data['motorista'] ?? "",
        f_id_motorista: data['f_id_motorista'] ?? "",
        habilitacao_numero: data['habilitacao_numero'] ?? "",
        habilitacao_categoria: data['habilitacao_categoria'] ?? "",
        habilitacao_vencimento: data['habilitacao_vencimento'] ?? "",
        mot_id_transportadora: data['mot_id_transportadora'] ?? "",
        local_cadastro: data['local_cadastro'] ?? "",
        idCategoria: data['idCategoria'] ?? 0,
        id_vendedor: data['id_vendedor'] ?? 0,
        id_prospect: data['id_prospect'] ?? "0",
        alterado: data['alterado'] ?? "",
        //List<CadastroAnexo> listaCadastroAnexo = new ArrayList<>(): data['id_web_pedido'] == null ? "" :  data['id_web_pedido'] ,
        situacaoPredio: data['situacaoPredio'] ?? "",
        finalizado: data['finalizado'] ?? "",
        id_tabela_preco: data['id_tabela_preco'] ?? "",
        nome_tabela_preco: data['nome_tabela_preco'] ?? "",

        utiliza_tabela_preco: data['utiliza_tabela_preco'] ?? "",
        //Dados vindo da empresa(TBL_EMPRESA_PARAMETROS
        tipo_tabela_preco: data['tipo_tabela_preco'] ?? "",
        //Dados vindo da empresa(TBL_EMPRESA_PARAMETROS  4 Categoria   6 Tabela de preço
        financeiro_vencido: data['financeiro_vencido'] ?? "0.00",
        //Pendencia financeira quando titulo ´ja vencido
        financeiro_vencendo: data['financeiro_vencendo'] ?? "0.00",
        //Pendencia financeira quando titulo vence na data atual
        pedido_analise: data['pedido_analise'] ?? "",
        //Pedidos em analise no sistema RCL
        latitude: data['latitude'] ?? "",
        longitude: data['longitude'] ?? "",
        id_promocao: data['id_promocao'] ?? "",
        id_regiao: data['id_regiao'] ?? 0,
        id_bairro: data['id_bairro'] ?? 0,
        rota_sequencia: data['rota_sequencia'] ?? 0,
        nome_categoria: data['nome_categoria'] ?? "",

         */
        url_api: data['url_api'] ?? "",
        url_api_on_line:  "N",

        webStatusApi: data['statusApi'] != null ? WebStatusApi.fromJson(data['statusApi']) :
        WebStatusApi( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true),

        webStatusExportacao: data['statusExportacao'] != null ? WebStatusExportacao.fromJson(data['statusExportacao']) :
        WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
            email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: ""),

        webStatusErroAddArquivo: data['statusErroAddArquivo'] != null ? WebStatusExportacao.fromJson(data['statusErroAddArquivo']) :
        WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
            email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: ""),

        webStatusDadosInvalido: data['statusDadosInvalido'] != null ? WebStatusExportacao.fromJson(data['statusDadosInvalido']) :
        WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
            email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: ""),


        /*webAnaliseArquivoXml: WebAnaliseArquivoXml(id: "0", mensagem: "", sucesso: false, modelo: "", qtde_autorizadas: 0,
          qtde_canceladas: 0, qtde_contigencia: 0, qtde_cte: 0, qtde_emitidas: 0, qtde_inutilizadas: 0, qtde_nfe: 0,
          qtde_nfce: 0, qtde_terc: 0, qtde_outras: 0, status_exportacao: "", data_exportacao: "",
          hora_exportacao: "", email_exportacao_1: "", email_exportacao_2: "", data_agendamento: ""),*/

        data_exportacao_1:   data['data_exportacao_1'] ?? "",
        data_exportacao_2:   data['data_exportacao_2'] ?? "",
        status_exportacao_1: data['status_exportacao_1'] ?? "",
        status_exportacao_2: data['status_exportacao_1'] ?? "",
        hora_exportacao_1: data['hora_exportacao_1'] ?? "",
        hora_exportacao_2: data['hora_exportacao_2'] ?? "",
        fuso_horario:      data['time_zone'] ?? "",
        tempo_status_api:  data['tempo_atualiza_status_api'] ?? "",
        email_exportacao_1: data['email_exportacao_1'] ?? "",
        email_exportacao_2: data['email_exportacao_2'] ?? "",
        email_envio_ativo: data['email_envio_ativo'] ?? "",
        notas_com_erro: "N",
        exportacao_com_erro : "N",
        data_online: "",

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ativo': ativo
    };
  }



  factory WebCliente.fromJson(Map<String, dynamic> json) {
    return WebCliente(
      ativo: json['ativo'] ?? "N",
      //id_empresa: json['id_empresa'] ?? "",
      id_cadastro: json['id_cadastro'] ?? "",
      //id_cadastro_servidor: json['id_cadastro_servidor'] ?? "",
      //pessoa_f_j: json['pessoa_f_j'] ?? "",
      //data_aniversario: json['data_aniversario'] ?? "",
      nome_cadastro: json['nome_cadastro'] ?? json['razao_social'],
      nome_fantasia: json['nome_fantasia'] ?? "",
      cpf_cnpj: json['cpf_cnpj'] ?? json['cnpj_cpf'],
      /*
        inscri_estadual: json['inscri_estadual'] ?? "",
      endereco: json['endereco'] ?? "",
      endereco_bairro: json['endereco_bairro'] ?? "",
      endereco_numero: json['endereco_numero'] ?? "",
      endereco_complemento: json['endereco_complemento'] ?? "",
      endereco_uf: json['endereco_uf'] ?? "",
      nome_municipio: json['nome_municipio'] ?? "",
      endereco_cep: json['endereco_cep'] ?? "",
      usuario_id: json['usuario_id'] ?? "",
      usuario_nome: json['usuario_nome'] ?? "",
      usuario_data: json['usuario_data'] ?? "",
      f_cliente: json['f_cliente'] ?? "",
      f_fornecedor: json['f_fornecedor'] ?? "",
      f_funcionario: json['f_funcionario'] ?? "",
      f_vendedor: json['f_vendedor'] ?? "",
      f_transportador: json['f_transportador'] ?? "",
      data_ultima_compra: json['data_ultima_compra'] ?? "",
      nome_vendedor: json['nome_vendedor'] ?? "",
      f_id_cliente: json['f_id_cliente'] ?? "",
      id_entidade: json['id_entidade'] ?? "",
      f_id_fornecedor: json['f_id_fornecedor'] ?? "",
      f_id_vendedor: json['f_id_vendedor'] ?? "",
      f_id_transportador: json['f_id_transportador'] ?? "",
      telefone_principal: json['telefone_principal'] ?? "",
      email_principal: json['email_principal'] ?? "",
      id_pais: json['id_web_pedido'] ?? "",
      f_id_funcionario: json['id_web_pedido'] ?? "",
      avisar_com_dias: json['id_web_pedido'] ?? "",
      observacoes: json['id_web_pedido'] ?? "",
      padrao_id_c_custo: json['id_web_pedido'] ?? "",
      padrao_id_c_gerenciadora: json['id_web_pedido'] ?? "",
      padrao_id_c_analitica: json['id_web_pedido'] ?? "",
      cob_endereco: json['cob_endereco'] ?? "",
      cob_endereco_bairro: json['cob_endereco_bairro'] ?? "",
      cob_endereco_numero: json['cob_endereco_numero'] ?? "",
      cob_endereco_complemento: json['cob_endereco_complemento'] ?? "",
      cob_endereco_uf: json['cob_endereco_uf'] ?? "",
      nome_cob_municipio: json['nome_cob_municipio'] ?? "",
      cob_endereco_cep: json['cob_endereco_cep'] ?? "",
      cob_endereco_id_pais: json['cob_endereco_id_pais'] ?? "",

      limite_credito: json['limite_credito'] ?? "0.00",
      limite_disponivel: json['limite_disponivel'] ?? "0.00",
      pessoa_contato_financeiro: json['pessoa_contato_financeiro'] ?? "",
      email_financeiro: json['email_financeiro'] ?? "",
      observacoes_faturamento: json['observacoes_faturamento'] ?? "",
      observacoes_financeiro: json['observacoes_financeiro'] ?? "",
      telefone_dois: json['telefone_dois'] ?? "",
      telefone_tres: json['telefone_tres'] ?? "",
      pessoa_contato_principal: json['pessoa_contato_principal'] ?? "",
      ind_da_ie_destinatario: json['ind_da_ie_destinatario'] ?? "",
      comissao_percentual: json['comissao_percentual'] ?? "",
      id_setor: json['id_setor'] ?? "",

      nfe_email_enviar: json['nfe_email_enviar'] ?? "",
      nfe_email_um: json['nfe_email_um'] ?? "",
      nfe_email_dois: json['nfe_email_dois'] ?? "",
      nfe_email_tres: json['nfe_email_tres'] ?? "",
      nfe_email_quatro: json['nfe_email_quatro'] ?? "",
      nfe_email_cinco: json['nfe_email_cinco'] ?? "",
      id_grupo_vendedor: json['id_grupo_vendedor'] ?? "",

      vendedor_usa_portal: json['vendedor_usa_portal'] ?? "",
      vendedor_id_user_portal: json['vendedor_id_user_portal'] ?? "",
      f_tarifa: json['f_tarifa'] ?? "",
      f_id_tarifa: json['f_id_tarifa'] ?? "",
      f_produtor: json['f_produtor'] ?? "",
      rg_numero: json['rg_numero'] ?? "",
      rg_ssp: json['rg_ssp'] ?? "",
      conta_contabil: json['conta_contabil'] ?? "",

      motorista: json['motorista'] ?? "",
      f_id_motorista: json['f_id_motorista'] ?? "",
      habilitacao_numero: json['habilitacao_numero'] ?? "",
      habilitacao_categoria: json['habilitacao_categoria'] ?? "",
      habilitacao_vencimento: json['habilitacao_vencimento'] ?? "",
      mot_id_transportadora: json['mot_id_transportadora'] ?? "",
      local_cadastro: json['local_cadastro'] ?? "",
      idCategoria: json['idCategoria'] ?? 0,
      id_vendedor: json['id_vendedor'] ?? 0,
      id_prospect: json['id_prospect'] ?? "0",
      alterado: json['alterado'] ?? "",
      //List<CadastroAnexo> listaCadastroAnexo = new ArrayList<>(): json['id_web_pedido'] == null ? "" :  json['id_web_pedido'] ,
      situacaoPredio: json['situacaoPredio'] ?? "",
      finalizado: json['finalizado'] ?? "",
      id_tabela_preco: json['id_tabela_preco'] ?? "",
      nome_tabela_preco: json['nome_tabela_preco'] ?? "",

      utiliza_tabela_preco: json['utiliza_tabela_preco'] ?? "",
      //Dados vindo da empresa(TBL_EMPRESA_PARAMETROS
      tipo_tabela_preco: json['tipo_tabela_preco'] ?? "",
      //Dados vindo da empresa(TBL_EMPRESA_PARAMETROS  4 Categoria   6 Tabela de preço
      financeiro_vencido: json['financeiro_vencido'] ?? "0.00",
      //Pendencia financeira quando titulo ´ja vencido
      financeiro_vencendo: json['financeiro_vencendo'] ?? "0.00",
      //Pendencia financeira quando titulo vence na data atual
      pedido_analise: json['pedido_analise'] ?? "",
      //Pedidos em analise no sistema RCL
      latitude: json['latitude'] ?? "",
      longitude: json['longitude'] ?? "",
      id_promocao: json['id_promocao'] ?? "",
      id_regiao: json['id_regiao'] ?? 0,
      id_bairro: json['id_bairro'] ?? 0,
      rota_sequencia: json['rota_sequencia'] ?? 0,
      nome_categoria: json['nome_categoria'] ?? "",

       */
      url_api: json['url_api'] ?? "",
      url_api_on_line:  "N",

      webStatusApi: json['statusApi'] != null ? WebStatusApi.fromJson(json['statusApi']) :
          WebStatusApi( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
             qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
             qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
             qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
             qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
             sequenciaNumericaNFCe: true, primeiraNotaNFCe: true),

      webStatusExportacao: json['statusExportacao'] != null ? WebStatusExportacao.fromJson(json['statusExportacao']) :
          WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
             qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
             qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
             qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
             qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
             sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
             email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: ""),

     webStatusErroAddArquivo: json['statusErroAddArquivo'] != null ? WebStatusExportacao.fromJson(json['statusErroAddArquivo']) :
        WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
            email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: ""),

     webStatusDadosInvalido: json['statusDadosInvalido'] != null ? WebStatusExportacao.fromJson(json['statusDadosInvalido']) :
        WebStatusExportacao( cnpj: "", mensagem: "", sucesso: false, dataHora: "",
            qtdeNfeEmitida: 0, qtdeNfeAutorizada: 0, qtdeNfeContigencia: 0, qtdeNfeCancelada: 0,
            qtdeNfceEmitida: 0, qtdeNfceAutorizada: 0, qtdeNfceContigencia: 0, qtdeNfceCancelada: 0,
            qtdeNfeInutilizada: 0, qtdeNfceInutilizada: 0,
            qtdeNotaOutras: 0, qtdeNotaTerceiros: 0, sequenciaNumericaNFe: true, primeiraNotaNFe: true,
            sequenciaNumericaNFCe: true, primeiraNotaNFCe: true, data_agendamento: "", data_exportacao: "",
            email_exportacao_1: "", email_exportacao_2: "", hora_exportacao: ""),


      /*webAnaliseArquivoXml: WebAnaliseArquivoXml(id: "0", mensagem: "", sucesso: false, modelo: "", qtde_autorizadas: 0,
          qtde_canceladas: 0, qtde_contigencia: 0, qtde_cte: 0, qtde_emitidas: 0, qtde_inutilizadas: 0, qtde_nfe: 0,
          qtde_nfce: 0, qtde_terc: 0, qtde_outras: 0, status_exportacao: "", data_exportacao: "",
          hora_exportacao: "", email_exportacao_1: "", email_exportacao_2: "", data_agendamento: ""),*/

      data_exportacao_1: json['data_exportacao_1'] ?? "",
      data_exportacao_2: json['data_exportacao_2'] ?? "",
      status_exportacao_1: json['status_exportacao_1'] ?? "",
      status_exportacao_2: json['status_exportacao_1'] ?? "",
      hora_exportacao_1: json['hora_exportacao_1'] ?? "",
      hora_exportacao_2: json['hora_exportacao_2'] ?? "",
      fuso_horario:      json['time_zone'] ?? "",
      tempo_status_api:  json['tempo_atualiza_status_api'] ?? "",
      email_exportacao_1: json['email_exportacao_1'] ?? "",
      email_exportacao_2: json['email_exportacao_2'] ?? "",
      email_envio_ativo: json['email_envio_ativo'] ?? "",
      notas_com_erro: "",
      exportacao_com_erro : "",
      data_online: "",

    );
  }

  static List<WebCliente> fromJsonList(dynamic jsonList) {
    final transactionDetailsList = <WebCliente>[];
    if (jsonList == null) return transactionDetailsList;

    if (jsonList is List<dynamic>) {
      for (final json in jsonList) {
        transactionDetailsList.add(
          WebCliente.fromJson(json),
        );
      }
    }
    return transactionDetailsList;
  }

  Map<String, dynamic> toJson() => {
  'ativo': ativo,
  //'id_empresa': id_empresa,
  'id_cadastro': id_cadastro,
  //'id_cadastro_servidor': id_cadastro_servidor,
 // 'pessoa_f_j': pessoa_f_j,
 // 'data_aniversario': data_aniversario,
  'nome_cadastro': nome_cadastro,
  'nome_fantasia': nome_fantasia,
  'cpf_cnpj': cpf_cnpj,
  /*
    'inscri_estadual': inscri_estadual,
  'endereco': endereco,
  'endereco_bairro': endereco_bairro,
  'endereco_numero': endereco_numero,
  'endereco_complemento': endereco_complemento,
  'endereco_uf': endereco_uf,
  'nome_municipio': nome_municipio,
  'endereco_cep': endereco_cep,
  'usuario_id': usuario_id,
  'usuario_nome': usuario_nome,
  'usuario_data': usuario_data,
  'f_cliente': f_cliente,
  'f_fornecedor': f_fornecedor,
  'f_funcionario': f_funcionario,
  'f_vendedor': f_vendedor,
  'f_transportador': f_transportador,
  'data_ultima_compra': data_ultima_compra,
  'nome_vendedor': nome_vendedor,
  'f_id_cliente': f_id_cliente,
  'id_entidade': id_entidade,
  'f_id_fornecedor': f_id_fornecedor,
  'f_id_vendedor': f_id_vendedor,
  'f_id_transportador': f_id_transportador,
  'telefone_principal': telefone_principal,
  'email_principal': email_principal,
  'id_pais': id_pais,
  'f_id_funcionario': f_id_funcionario,
  'avisar_com_dias': avisar_com_dias,
  'observacoes': observacoes,
  'padrao_id_c_custo': padrao_id_c_custo,
  'padrao_id_c_gerenciadora': padrao_id_c_gerenciadora,
  'padrao_id_c_analitica': padrao_id_c_analitica,

  'limite_credito': limite_credito,
  'limite_disponivel': limite_disponivel,
  'pessoa_contato_financeiro': pessoa_contato_financeiro,
  'email_financeiro': email_financeiro,
  'observacoes_faturamento': observacoes_faturamento,
  'observacoes_financeiro': observacoes_financeiro,
  'telefone_dois': telefone_dois,
  'telefone_tres': telefone_tres,
  'pessoa_contato_principal': pessoa_contato_principal,
  'ind_da_ie_destinatario': ind_da_ie_destinatario,
  'comissao_percentual': comissao_percentual,
  'id_setor': id_setor,
  'nfe_email_enviar': nfe_email_enviar,
  'nfe_email_um': nfe_email_um,
  'nfe_email_dois': nfe_email_dois,
  'nfe_email_tres': nfe_email_tres,
  'nfe_email_quatro': nfe_email_quatro,
  'nfe_email_cinco': nfe_email_cinco,
  'id_grupo_vendedor': id_grupo_vendedor,
  'vendedor_usa_portal': vendedor_usa_portal,
  'vendedor_id_user_portal': vendedor_id_user_portal,

  'idCategoria': idCategoria,
  'id_vendedor': id_vendedor,
  'id_prospect': id_prospect,
  'alterado': alterado,
  'situacaoPredio': situacaoPredio,
  'finalizado': finalizado,
  'id_tabela_preco': id_tabela_preco,
  'nome_tabela_preco': nome_tabela_preco,
  'utiliza_tabela_preco': utiliza_tabela_preco,
  'tipo_tabela_preco': tipo_tabela_preco,
  'financeiro_vencido': financeiro_vencido,
  'financeiro_vencendo': financeiro_vencendo,
  'pedido_analise': pedido_analise,
  'latitude': latitude,
  'longitude': longitude,
  'id_promocao': id_promocao,
  'id_regiao': id_regiao,
  'id_bairro': id_bairro,
  'rota_sequencia': rota_sequencia,
  'nome_categoria': nome_categoria,

   */
  };
}
