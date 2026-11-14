import 'package:sqflite/sqflite.dart';

import 'package:app_previsao_tempo/features/previsao/data/database/banco_previsoes.dart';
import 'package:app_previsao_tempo/features/previsao/models/cidade.dart';
import 'package:app_previsao_tempo/features/previsao/models/previsao_salva.dart';

// Único ponto do app que executa operações na tabela previsoes_salvas.
class RepositorioPrevisoes {
  static const _tabela = 'previsoes_salvas';

  const RepositorioPrevisoes();

  // Salva (ou substitui) a última previsão recebida da cidade.
  Future<void> salvar(Cidade cidade, String xml) async {
    final banco = await BancoPrevisoes.obter();
    final registro = PrevisaoSalva(
      cidade: cidade,
      xml: xml,
      salvoEm: DateTime.now(),
    );

    // replace: se a cidade já existe (mesmo cidade_id), a linha é trocada.
    await banco.insert(
      _tabela,
      registro.paraMapa(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca a previsão salva de uma cidade, usada quando não há conexão.
  Future<PrevisaoSalva?> buscar(int cidadeId) async {
    final banco = await BancoPrevisoes.obter();
    final registros = await banco.query(
      _tabela,
      where: 'cidade_id = ?',
      whereArgs: [cidadeId],
    );

    if (registros.isEmpty) return null;
    return PrevisaoSalva.deMapa(registros.first);
  }

  // Cidades consultadas recentemente, da mais nova para a mais antiga.
  Future<List<PrevisaoSalva>> listarRecentes({int limite = 10}) async {
    final banco = await BancoPrevisoes.obter();
    final registros = await banco.query(
      _tabela,
      orderBy: 'salvo_em DESC',
      limit: limite,
    );

    return registros.map((registro) => PrevisaoSalva.deMapa(registro)).toList();
  }
}
