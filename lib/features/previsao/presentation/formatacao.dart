// Funções de apresentação de datas e números.

String _doisDigitos(int numero) => numero.toString().padLeft(2, '0');

const _diasDaSemana = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

// 2026-11-14 -> "14/11/2026"
String formatarData(DateTime? data) {
  if (data == null) return 'Data não informada';
  return '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';
}

// 2026-11-14 -> "14/11"
String formatarDiaMes(DateTime? data) {
  if (data == null) return '--/--';
  return '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}';
}

// 2026-11-14 -> "sex, 14/11/2026"
String formatarDiaCurto(DateTime? data) {
  if (data == null) return 'Data não informada';
  // weekday: 1 = segunda ... 7 = domingo
  final semana = _diasDaSemana[data.weekday - 1];
  return '$semana, ${formatarData(data)}';
}

// Data e hora locais: "14/11/2026 13:57"
String formatarDataHora(DateTime data) {
  final local = data.toLocal();
  return '${formatarData(local)} '
      '${_doisDigitos(local.hour)}:${_doisDigitos(local.minute)}';
}

// null -> "--"; 31 -> "31 °C"
String formatarTemperatura(int? graus) {
  return graus == null ? '-- °C' : '$graus °C';
}

// Classificação do índice UV (escala da OMS).
String classificarUv(double indice) {
  if (indice < 3) return 'baixo';
  if (indice < 6) return 'moderado';
  if (indice < 8) return 'alto';
  if (indice < 11) return 'muito alto';
  return 'extremo';
}
