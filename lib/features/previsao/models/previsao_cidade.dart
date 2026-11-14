import 'package:app_previsao_tempo/features/previsao/models/previsao_dia.dart';

// A resposta completa do serviço de previsão para quatro dias.
class PrevisaoCidade {
  final String nome;
  final String uf;
  final DateTime? atualizacao; // Data de atualização informada pelo serviço
  final List<PrevisaoDia> dias;

  const PrevisaoCidade({
    required this.nome,
    required this.uf,
    required this.atualizacao,
    required this.dias,
  });
}
