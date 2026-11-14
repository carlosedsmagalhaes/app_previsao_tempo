import 'package:flutter/material.dart';

// Converte as siglas do CPTEC/INPE em descrição e ícone.
// Tabela da documentação oficial: https://servicos.cptec.inpe.br/XML/
class CondicaoTempo {
  final String descricao;
  final IconData icone;
  final Color cor;

  const CondicaoTempo({
    required this.descricao,
    required this.icone,
    required this.cor,
  });

  static const Map<String, String> _descricoes = {
    'ec': 'Encoberto com Chuvas Isoladas',
    'ci': 'Chuvas Isoladas',
    'c': 'Chuva',
    'in': 'Instável',
    'pp': 'Possibilidade de Pancadas de Chuva',
    'cm': 'Chuva pela Manhã',
    'cn': 'Chuva à Noite',
    'pt': 'Pancadas de Chuva à Tarde',
    'pm': 'Pancadas de Chuva pela Manhã',
    'np': 'Nublado e Pancadas de Chuva',
    'pc': 'Pancadas de Chuva',
    'pn': 'Parcialmente Nublado',
    'cv': 'Chuvisco',
    'ch': 'Chuvoso',
    't': 'Tempestade',
    'ps': 'Predomínio de Sol',
    'e': 'Encoberto',
    'n': 'Nublado',
    'cl': 'Céu Claro',
    'nv': 'Nevoeiro',
    'g': 'Geada',
    'ne': 'Neve',
    'nd': 'Não Definido',
    'pnt': 'Pancadas de Chuva à Noite',
    'psc': 'Possibilidade de Chuva',
    'pcm': 'Possibilidade de Chuva pela Manhã',
    'pct': 'Possibilidade de Chuva à Tarde',
    'pcn': 'Possibilidade de Chuva à Noite',
    'npt': 'Nublado com Pancadas à Tarde',
    'npn': 'Nublado com Pancadas à Noite',
    'ncn': 'Nublado com Possibilidade de Chuva à Noite',
    'nct': 'Nublado com Possibilidade de Chuva à Tarde',
    'ncm': 'Nublado com Possibilidade de Chuva pela Manhã',
    'npm': 'Nublado com Pancadas pela Manhã',
    'npp': 'Nublado com Possibilidade de Chuva',
    'vn': 'Variação de Nebulosidade',
    'ct': 'Chuva à Tarde',
    'ppn': 'Possibilidade de Pancadas de Chuva à Noite',
    'ppt': 'Possibilidade de Pancadas de Chuva à Tarde',
    'ppm': 'Possibilidade de Pancadas de Chuva pela Manhã',
  };

  // Grupos de siglas que usam o mesmo ícone.
  static const _sol = {'cl', 'ps'};
  static const _nuvens = {'pn', 'vn', 'n', 'e'};
  static const _pancadas = {
    'pp', 'pt', 'pm', 'np', 'pc', 'pnt', 'npt', 'npn', 'npm', 'ppn', 'ppt',
    'ppm', 't', 'in',
  };
  static const _frio = {'g', 'ne'};

  static CondicaoTempo daSigla(String? sigla) {
    final chave = sigla?.trim().toLowerCase() ?? '';
    final descricao = _descricoes[chave];

    // Sigla ausente ou fora da tabela: não encerra o app, só avisa.
    if (descricao == null) {
      return const CondicaoTempo(
        descricao: 'Condição não informada',
        icone: Icons.help_outline,
        cor: Colors.grey,
      );
    }

    if (_sol.contains(chave)) {
      return CondicaoTempo(
        descricao: descricao,
        icone: Icons.wb_sunny,
        cor: Colors.orange,
      );
    }
    if (_nuvens.contains(chave)) {
      return CondicaoTempo(
        descricao: descricao,
        icone: Icons.cloud,
        cor: Colors.blueGrey,
      );
    }
    if (_pancadas.contains(chave)) {
      return CondicaoTempo(
        descricao: descricao,
        icone: Icons.thunderstorm,
        cor: Colors.indigo,
      );
    }
    if (_frio.contains(chave)) {
      return CondicaoTempo(
        descricao: descricao,
        icone: Icons.ac_unit,
        cor: Colors.cyan,
      );
    }
    if (chave == 'nv') {
      return CondicaoTempo(
        descricao: descricao,
        icone: Icons.foggy,
        cor: Colors.blueGrey,
      );
    }
    if (chave == 'nd') {
      return CondicaoTempo(
        descricao: descricao,
        icone: Icons.help_outline,
        cor: Colors.grey,
      );
    }

    // Demais siglas são de chuva.
    return CondicaoTempo(
      descricao: descricao,
      icone: Icons.umbrella,
      cor: Colors.blue,
    );
  }
}
