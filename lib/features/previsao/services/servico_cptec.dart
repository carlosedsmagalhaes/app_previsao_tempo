import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:app_previsao_tempo/features/previsao/models/cidade.dart';
import 'package:app_previsao_tempo/features/previsao/services/erro_consulta.dart';
import 'package:app_previsao_tempo/features/previsao/services/leitor_xml_cptec.dart';

// Faz as requisições HTTP ao serviço XML do CPTEC/INPE.
class ServicoCptec {
  static const _host = 'servicos.cptec.inpe.br';
  static const _tempoLimite = Duration(seconds: 15);

  const ServicoCptec();

  // GET /XML/listaCidades?city=nome
  Future<List<Cidade>> buscarCidades(String nome) async {
    // A documentação pede o nome sem acentos.
    final termo = Uri.encodeComponent(removerAcentos(nome.trim()));
    final xml = await _baixar('/XML/listaCidades?city=$termo');

    return LeitorXmlCptec.lerCidades(xml);
  }

  // GET /XML/cidade/{codigo}/previsao.xml (previsão para 4 dias).
  // Devolve o XML como texto para que ele possa ser salvo no SQLite.
  Future<String> baixarPrevisao(int codigo) {
    return _baixar('/XML/cidade/$codigo/previsao.xml');
  }

  Future<String> _baixar(String caminho) async {
    final resposta = await _requisitar(caminho);

    if (resposta.statusCode != 200) {
      throw ErroConsulta(
        'O serviço do CPTEC/INPE está indisponível '
        '(código ${resposta.statusCode}). Tente novamente mais tarde.',
      );
    }

    return _decodificar(resposta.bodyBytes);
  }

  Future<http.Response> _requisitar(String caminho) async {
    try {
      // Tenta primeiro o endereço seguro (HTTPS).
      return await _get('https', caminho);
    } on TimeoutException {
      throw const ErroConsulta(
        'O serviço demorou para responder. Tente novamente.',
      );
    } catch (_) {
      // Se o HTTPS falhar, tenta HTTP, liberado só para este domínio
      // em android/app/src/main/res/xml/network_security_config.xml.
      try {
        return await _get('http', caminho);
      } on TimeoutException {
        throw const ErroConsulta(
          'O serviço demorou para responder. Tente novamente.',
        );
      } catch (_) {
        throw const ErroConsulta(
          'Sem conexão com o serviço. Verifique a internet e tente novamente.',
        );
      }
    }
  }

  Future<http.Response> _get(String esquema, String caminho) {
    return http.get(Uri.parse('$esquema://$_host$caminho')).timeout(_tempoLimite);
  }

  // O XML do CPTEC declara sua codificação no início, por exemplo:
  // <?xml version="1.0" encoding="ISO-8859-1"?>
  // Ler os bytes com a codificação certa evita "SÃ£o Paulo" na tela.
  String _decodificar(List<int> bytes) {
    final inicio = latin1.decode(bytes.take(100).toList()).toLowerCase();

    if (inicio.contains('iso-8859-1')) {
      return latin1.decode(bytes);
    }

    return utf8.decode(bytes, allowMalformed: true);
  }
}

// "São José" -> "Sao Jose"
String removerAcentos(String texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';

  final resultado = StringBuffer();

  for (final letra in texto.split('')) {
    final posicao = comAcento.indexOf(letra);
    resultado.write(posicao == -1 ? letra : semAcento[posicao]);
  }

  return resultado.toString();
}
