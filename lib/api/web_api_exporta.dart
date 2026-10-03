
import 'package:dio/dio.dart';
import 'package:rck_painel_tarefa/model/web_cliente.dart';
import 'package:rck_painel_tarefa/model/web_status_api.dart';
import 'package:rck_painel_tarefa/model/web_status_exportacao.dart';
import 'package:rck_painel_tarefa/model/web_tarefa.dart';
import 'package:rck_painel_tarefa/model/web_usuario.dart';
import 'package:retrofit/retrofit.dart';

import '../model/web_analise_arquivo_xml.dart';
part 'web_api_exporta.g.dart';

class ApisWebApp {
  //static const String usuarios         = '/usuarioweb/login/{idandroid}/{idusuario}/{login}/{senha}/{email}';
  static const String usuarios         = '/usuariofirestore/login/{login}/{senha}';

  static const String nota_analise_xml = '/analisexml/{id}/{datainicial}/{datafinal}/{codmodelo}/{listaStatus}';

  //static const String clientes         = '/cliente/exporta/listar/{id}/{offset}/{linitreg}';
  static const String clientes           = '/clientefirestore/exporta/listar/{id}/{offset}/{linitreg}';
  static const String clientes_add_exportacao  = '/clientefirestore/exporta/add/exportacao';
  static const String clientes_dados_exportacao  = '/clientefirestore/exporta/pesquisar/exportacao/cliente/{id}/{data}';
  static const String web_status_exportacao  = '/clientefirestore/exporta/pesquisar/statusexportacao';




  //static const String tarefas          = '/cliente/exporta/listartarefa/{id}';
  static const String tarefas            = '/tarefafirestore/exporta/listartarefa/{id}';
 // static const String clientes_tarefa  = '/tarefa/consulta/{id}/{offset}/{linitreg}/{dataini}/{datafin}/{idx}';
  static const String clientes_tarefa    = '/tarefafirestore/exporta/consulta/{id}/{offset}/{linitreg}'
      '/{dataini}/{datafin}/{idx}/{cnpjcliente}';


  ///listartarefa/{idusuario}


  static const String status_api       = '/generico/statusapi/';

  //static const String web_status_api   = '/generico/statusapi/{cnpjcpf}';
  static const String web_status_api   =  '/clientefirestore/exporta/pesquisar/statusapi';


  static const String web_tarefa       = '/web/generico/listatarefa/{id}';

  //Constantes q irao utilizar a API exporta
  static const String analise_doc_xml  = '/notafiscal/analisexml/{id}/{datainicial}/{datafinal}/{codmodelo}/{cnpjcpf}/{auto}';
  static const String analise_todos_doc_xml  = '/notafiscal/analisetodosxml/{id}/{datainicial}/{datafinal}/{cnpjcpf}/{auto}';

  static const String exporta_doc_xml  = '/notafiscal/exportaxml/{id}/{datainicial}/{datafinal}/{codmodelo}/{cnpjcpf}/{email1}/{email2}/{auto}';
  static const String exporta_todos_doc_xml  = '/notafiscal/exportatodosxml/{id}/{datainicial}/{datafinal}/{cnpjcpf}/{email1}/{email2}/{auto}';

}


/*@RestApi(baseUrl: '')
abstract class ApiUsuario {
  factory ApiUsuario(Dio dio, {String baseUrl}) = _ApiUsuario;
  @GET(ApisWebApp.usuarios)
  Future<List<WebUsuario>> getUsuario(@Path("idandroid") String idandroid,
                                   @Path("idusuario") String idusuario,
                                   @Path("login") String login,
                                   @Path("senha") String senha,
                                   @Path("email") String email);
}*/

@RestApi(baseUrl: '')
abstract class ApiUsuario {
  factory ApiUsuario(Dio dio, {String baseUrl}) = _ApiUsuario;
  @GET(ApisWebApp.usuarios)
  Future<List<WebUsuario>> getUsuario(
      @Path("login") String login,
      @Path("senha") String senha);
}


@RestApi(baseUrl: '')
abstract class ApiWebCliente {
  factory ApiWebCliente(Dio dio, {String baseUrl}) = _ApiWebCliente;
  @GET(ApisWebApp.clientes)
  Future<List<WebCliente>> getWebCliente(@Path("id") String id,
      @Path("offset") int offSet, @Path("linitreg") int limitReg,
      @Header('Authorization') String token);
}


@RestApi(baseUrl: '')
abstract class ApiWebAnaliseXml {
  factory ApiWebAnaliseXml(Dio dio, {String baseUrl}) = _ApiWebAnaliseXml;

  @GET(ApisWebApp.nota_analise_xml)
  Future<List<String>> getWebAnaliseXml(@Path("id") String id, @Path("dataInicial") String dataInicial,
      @Path("dataFinal") String dataFinal, @Path("codModelo") String codModelo,  @Path("listaStatus") List<String> listaStatus,
      @Header('Authorization') String token);
}

@RestApi(baseUrl: '')
abstract class ApiWebStatusApi {
  factory ApiWebStatusApi(Dio dio, {String baseUrl}) = _ApiWebStatusApi;
  @GET(ApisWebApp.web_status_api)
  Future<List<WebStatusApi>> getWebStatusApi( @Header('Authorization') String token);
}

@RestApi(baseUrl: '')
abstract class ApiWebTarefa {
  factory ApiWebTarefa(Dio dio, {String baseUrl}) = _ApiWebTarefa;

  @GET(ApisWebApp.tarefas)
  Future<List<WebTarefa>> getWebTarefa( @Path("id") String id, @Header('Authorization') String token);
}


@RestApi(baseUrl: '')
abstract class ApiWebClienteTarefa {
  factory ApiWebClienteTarefa(Dio dio, {String baseUrl}) = _ApiWebClienteTarefa;
  @GET(ApisWebApp.clientes_tarefa)
  Future<List<WebCliente>> getWebClienteTarefa(@Path("id") String id,
      @Path("offset") int offSet, @Path("linitreg") int limitReg,
      @Path("dataini") String dataIni, @Path("datafin") String dataFin,
      @Path("idx") int idx, @Path("cnpjcliente") String cnpjcliente,
      @Header('Authorization') String token);
}

@RestApi(baseUrl: '')
abstract class ApiWebExportaAnaliseArquivoXml {
  factory ApiWebExportaAnaliseArquivoXml(Dio dio, {String baseUrl}) = _ApiWebExportaAnaliseArquivoXml;
  @GET(ApisWebApp.analise_doc_xml)
  Future<List<WebAnaliseArquivoXml>> getWebExportaAnaliseArquivoXml(
      @Path("id") String id,
      @Path("datainicial") String dataInicial, @Path("datafinal") String dataFinal,
      @Path("codmodelo") String codModelo,
      @Path("cnpjcpf") String cnpjCpf,
      @Path("auto") String auto,
      @Header('Authorization') String token);
}

@RestApi(baseUrl: '')
abstract class ApiWebExportaAnaliseTodosArquivoXml {
  factory ApiWebExportaAnaliseTodosArquivoXml(Dio dio, {String baseUrl}) = _ApiWebExportaAnaliseTodosArquivoXml;
  @GET(ApisWebApp.analise_todos_doc_xml)
  Future<List<WebAnaliseArquivoXml>> getWebExportaAnaliseTodosArquivoXml(
      @Path("id") String id,
      @Path("datainicial") String dataInicial, @Path("datafinal") String dataFinal,
      @Path("cnpjcpf") String cnpjCpf,
      @Path("auto") String auto,
      @Header('Authorization') String token);
}


@RestApi(baseUrl: '')
abstract class ApiWebExportaZipArquivoXml {
  factory ApiWebExportaZipArquivoXml(Dio dio, {String baseUrl}) = _ApiWebExportaZipArquivoXml;
  @GET(ApisWebApp.exporta_doc_xml)
  Future<List<WebAnaliseArquivoXml>> getWebExportaZipArquivoXml(
      @Path("id") String id,
      @Path("datainicial") String dataInicial,
      @Path("datafinal") String dataFinal,
      @Path("codmodelo") String codModelo,
      @Path("cnpjcpf") String cnpjCpf,
      @Path("email1") String email1,
      @Path("email2") String email2,
      @Path("auto") String auto,
      @Header('Authorization') String token);
}

@RestApi(baseUrl: '')
abstract class ApiWebExportaZipTodosArquivoXml {
  factory ApiWebExportaZipTodosArquivoXml(Dio dio, {String baseUrl}) = _ApiWebExportaZipTodosArquivoXml;
  @GET(ApisWebApp.exporta_todos_doc_xml)
  Future<List<WebAnaliseArquivoXml>> getWebExportaZipTodosArquivoXml(
      @Path("id") String id,
      @Path("datainicial") String dataInicial,
      @Path("datafinal") String dataFinal,
      @Path("cnpjcpf") String cnpjCpf,
      @Path("email1") String email1,
      @Path("email2") String email2,
      @Path("auto") String auto,
      @Header('Authorization') String token);
}


@RestApi(baseUrl: '')
abstract class ApiWebAddExportacaoCliente {
  factory ApiWebAddExportacaoCliente(Dio dio, {String baseUrl}) = _ApiWebAddExportacaoCliente;
  @POST(ApisWebApp.clientes_add_exportacao)
  Future<List<WebAnaliseArquivoXml>> addExportacaoCliente( @Body() List<WebAnaliseArquivoXml> lista,
      @Header('Authorization') String token);
}


/*
@RestApi(baseUrl: '')
abstract class ApiWebDadosExportacao {
  factory ApiWebDadosExportacao(Dio dio, {String baseUrl}) = _ApiWebDadosExportacao;
  @GET(ApisWebApp.clientes_dados_exportacao)
  Future<List<WebAnaliseArquivoXml>> getWebDadosExportacao(@Path("id") String id,
      @Path("data") String data,
      @Header('Authorization') String token);
}
*/

@RestApi(baseUrl: '')
abstract class ApiWebDadosExportacao {
  factory ApiWebDadosExportacao(Dio dio, {String baseUrl}) = _ApiWebDadosExportacao;
  @GET(ApisWebApp.web_status_exportacao)
  Future<List<WebStatusExportacao>> getWebDadosExportacao( @Header('Authorization') String token);
}



