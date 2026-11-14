import 'package:xml/xml.dart';

import 'package:app_previsao_tempo/features/previsao/models/cidade.dart';
import 'package:app_previsao_tempo/features/previsao/models/previsao_cidade.dart';
import 'package:app_previsao_tempo/features/previsao/models/previsao_dia.dart';
import 'package:app_previsao_tempo/features/previsao/services/erro_consulta.dart';

// Converte o XML do CPTEC/INPE em objetos Dart.
class LeitorXmlCptec {
  // Resposta de listaCidades:
  // <cidades><cidade><nome>Jacareí</nome><uf>SP</uf><id>2710</id></cidade></cidades>
  static List<Cidade> lerCidades(String xml) {
    final documento = _abrir(xml);
    final raiz = documento.rootElement;

    if (raiz.name.local != 'cidades') {
      throw const ErroConsulta('O serviço retornou uma resposta inválida.');
    }

    final cidades = <Cidade>[];

    for (final elemento in raiz.findElements('cidade')) {
      final id = int.tryParse(_texto(elemento, 'id') ?? '');
      final nome = _texto(elemento, 'nome');

      // Sem código ou sem nome a cidade não pode ser consultada: é ignorada.
      if (id == null || nome == null) continue;

      cidades.add(Cidade(id: id, nome: nome, uf: _texto(elemento, 'uf') ?? '--'));
    }

    return cidades;
  }

  // Resposta de cidade/{codigo}/previsao.xml:
  // <cidade><nome/><uf/><atualizacao>2026-11-14</atualizacao>
  //   <previsao><dia/><tempo/><maxima/><minima/><iuv/></previsao> ...
  // </cidade>
  static PrevisaoCidade lerPrevisao(String xml) {
    final documento = _abrir(xml);
    final raiz = documento.rootElement;

    if (raiz.name.local != 'cidade') {
      throw const ErroConsulta('O serviço retornou uma resposta inválida.');
    }

    final dias = <PrevisaoDia>[];

    for (final elemento in raiz.findElements('previsao')) {
      final dia = PrevisaoDia(
        data: DateTime.tryParse(_texto(elemento, 'dia') ?? ''),
        sigla: _texto(elemento, 'tempo'),
        maxima: int.tryParse(_texto(elemento, 'maxima') ?? ''),
        minima: int.tryParse(_texto(elemento, 'minima') ?? ''),
        indiceUv: double.tryParse(_texto(elemento, 'iuv') ?? ''),
      );

      // Um dia sem data, condição e temperaturas não tem o que mostrar.
      final vazio = dia.data == null &&
          dia.sigla == null &&
          dia.maxima == null &&
          dia.minima == null;
      if (!vazio) dias.add(dia);
    }

    return PrevisaoCidade(
      nome: _texto(raiz, 'nome') ?? 'Cidade não informada',
      uf: _texto(raiz, 'uf') ?? '--',
      atualizacao: DateTime.tryParse(_texto(raiz, 'atualizacao') ?? ''),
      dias: dias,
    );
  }

  static XmlDocument _abrir(String xml) {
    try {
      return XmlDocument.parse(xml);
    } on XmlException {
      // Texto que não é XML (página de erro, resposta cortada etc.).
      throw const ErroConsulta('O serviço retornou uma resposta inválida.');
    }
  }

  // Lê o texto de uma tag filha. Devolve null se a tag faltar, estiver
  // vazia ou vier com o texto "null" (o CPTEC faz isso às vezes).
  static String? _texto(XmlElement pai, String tag) {
    final texto = pai.getElement(tag)?.innerText.trim();

    if (texto == null || texto.isEmpty || texto.toLowerCase() == 'null') {
      return null;
    }

    return texto;
  }
}
