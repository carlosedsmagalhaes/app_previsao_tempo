import 'package:app_previsao_tempo/features/previsao/models/cidade.dart';

// Uma previsão guardada no SQLite: a cidade, o XML recebido e quando foi salva.
class PrevisaoSalva {
  final Cidade cidade;
  final String xml;
  final DateTime salvoEm;

  const PrevisaoSalva({
    required this.cidade,
    required this.xml,
    required this.salvoEm,
  });

  // SQLite -> objeto
  PrevisaoSalva.deMapa(Map<String, Object?> mapa)
    : cidade = Cidade(
        id: mapa['cidade_id'] as int,
        nome: mapa['nome'] as String,
        uf: mapa['uf'] as String,
      ),
      xml = mapa['xml'] as String,
      salvoEm = DateTime.parse(mapa['salvo_em'] as String);

  // objeto -> SQLite
  Map<String, Object?> paraMapa() {
    return {
      'cidade_id': cidade.id,
      'nome': cidade.nome,
      'uf': cidade.uf,
      'xml': xml,
      'salvo_em': salvoEm.toUtc().toIso8601String(),
    };
  }
}
