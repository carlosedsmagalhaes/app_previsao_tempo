import 'package:flutter/material.dart';

import 'package:app_previsao_tempo/features/previsao/models/previsao_dia.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/formatacao.dart';
import 'package:app_previsao_tempo/features/previsao/services/condicoes_tempo.dart';

// Um cartão com a previsão de um dia.
class ItemDia extends StatelessWidget {
  final PrevisaoDia dia;

  const ItemDia({super.key, required this.dia});

  @override
  Widget build(BuildContext context) {
    final condicao = CondicaoTempo.daSigla(dia.sigla);
    final uv = dia.indiceUv;

    // O índice UV só aparece quando o serviço informa um valor válido.
    final textoUv = uv != null && uv > 0
        ? '\nÍndice UV: ${uv.toStringAsFixed(1)} (${classificarUv(uv)})'
        : '';

    return Card(
      child: ListTile(
        leading: Icon(condicao.icone, color: condicao.cor, size: 36),
        title: Text(
          formatarDiaCurto(dia.data),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${condicao.descricao}$textoUv'),
        isThreeLine: textoUv.isNotEmpty,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'máx ${formatarTemperatura(dia.maxima)}',
              style: const TextStyle(color: Colors.red),
            ),
            Text(
              'mín ${formatarTemperatura(dia.minima)}',
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
