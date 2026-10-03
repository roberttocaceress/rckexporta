import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Mascaras {
   String mascaraCnpj(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) {
      return '';
    }
    final String apenasDigitos = cnpj.replaceAll(RegExp(r'\D'), '');
    if (apenasDigitos.length != 14) {
      return apenasDigitos; // Ou pode retornar a string original `cnpj` se preferir.
    }
    return apenasDigitos.replaceAllMapped(
      RegExp(r'^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$'),
          (Match m) => '${m[1]}.${m[2]}.${m[3]}/${m[4]}-${m[5]}',
    );
  }

   String mascaraCpf(String cpf) {
     String valorLimpo = cpf.trim().replaceAll("[^0-9]", "");
     if (!valorLimpo.isEmpty && valorLimpo.length == 11) {
       cpf = valorLimpo.substring(0, 3) +
           "." +
           valorLimpo.substring(3, 6) +
           "." +
           valorLimpo.substring(6, 9) +
           "-" +
           valorLimpo.substring(9, 11);
     }
     return cpf;
   }

   String mascaraDataHora(String dataString) {
     if (dataString.isEmpty) {
       return "";
     }
     try {
       final dateTime = DateTime.parse(dataString);
       return DateFormat('dd/MM/yy HH:mm').format(dateTime);
     } catch (e) {
       print("Erro ao formatar data: $e. String original: '$dataString'");
       return "           "; // Ou poderia ser "Data inválida"
     }
   }
   String mascaraData1(String? dataString) {
     // 1. Verificação de segurança: checa se a string é nula ou vazia.
     if (dataString == null || dataString.isEmpty) {
       return ''; // Ou 'Data indisponível', dependendo da sua regra de negócio.
     }

     try {
       // 2. ANÁLISE (PARSE): Converte a string "yyyy-MM-dd" em um objeto DateTime.
       // O método DateTime.parse lida nativamente com este formato.
       final DateTime dataObjeto = DateTime.parse(dataString);

       // 3. FORMATAÇÃO: Converte o objeto DateTime para a string "dd/MM/yyyy".
       return DateFormat('dd/MM/yy', 'pt_BR').format(dataObjeto);
     } catch (e) {
       // 4. TRATAMENTO DE ERRO: Se a string não estiver no formato esperado,
       // o DateTime.parse vai gerar uma exceção.
       print('Erro ao formatar a data: $dataString. Erro: $e');
       return dataString; // Retorna a string original ou uma mensagem de erro
     }
   }
   String mascaraData2( String data, String separador, int tamanho) {
     if ( data == null || data.isEmpty) {
       return "";
     }
     if ( separador == "-") {
       data = data.substring(6,10) + separador + data.substring(3,5) + separador + data.substring(0,2);
     } else {
       if (tamanho == 10)
         data = data.substring(8, 10) + separador + data.substring(5, 7) + separador + data.substring(0, 4);
       else
         data = data.substring(8, 10) + separador + data.substring(5, 7) + separador + data.substring(2, 4);
     }
     return data;
   }
   String mascaraMesAno( String data, String separador, int tamanho) {
     if ( data == null || data.isEmpty) {
       return "";
     }
     if ( separador == "-") {
       data = data.substring(6,10) + separador + data.substring(3,5) + separador + data.substring(0,2);
     } else {
       if (tamanho == 10)
         data =  data.substring(5, 7) + separador + data.substring(0, 4);
       else
         data =  data.substring(5, 7) + separador + data.substring(2, 4);
     }
     return data;
   }
   String mascaraTelefone(String telefone) {
     telefone = telefone.trim().replaceAll("[^0-9]", "");
     if (telefone.length == 10) {
       telefone = "(" + telefone.substring(0, 2) + ") " + telefone.substring(2, 6) + "-" + telefone.substring(6, 10);
     } else if (telefone.length == 11) {
       telefone = "(" + telefone.substring(0, 2) + ") " + telefone.substring(2, 7) + "-" + telefone.substring(7, 11);
     } else if (telefone.length == 9 && !telefone.contains("-")) {
       telefone = telefone.substring(0, 5) + "-" + telefone.substring(5, 9);
     } else if (telefone.length == 8) {
       telefone = telefone.substring(0, 4) + "-" + telefone.substring(4, 8);
     } else {
       telefone= telefone;
     }
     return telefone;
   }


}