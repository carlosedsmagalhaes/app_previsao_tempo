import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:app_previsao_tempo/features/previsao/models/previsao_dia.dart';
import 'package:app_previsao_tempo/features/previsao/presentation/formatacao.dart';

// Gráfico de linhas com as temperaturas máximas e mínimas de cada dia.
class GraficoTemperaturas extends StatelessWidget {
  final List<PrevisaoDia> dias;

  const GraficoTemperaturas({super.key, required this.dias});

  @override
  Widget build(BuildContext context) {
    // Cada ponto (FlSpot) é (x = posição do dia, y = temperatura).
    // Dias sem temperatura ficam de fora, sem quebrar o gráfico.
    final pontosMaxima = <FlSpot>[];
    final pontosMinima = <FlSpot>[];

    for (var i = 0; i < dias.length; i++) {
      final maxima = dias[i].maxima;
      final minima = dias[i].minima;
      if (maxima != null) pontosMaxima.add(FlSpot(i.toDouble(), maxima.toDouble()));
      if (minima != null) pontosMinima.add(FlSpot(i.toDouble(), minima.toDouble()));
    }

    final todos = [...pontosMaxima, ...pontosMinima];

    if (todos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Sem temperaturas para montar o gráfico.'),
        ),
      );
    }

    // Limites do eixo Y arredondados para múltiplos de 5, com folga.
    final menor = todos.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maior = todos.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final minY = ((menor - 2) / 5).floor() * 5.0;
    final maxY = ((maior + 2) / 5).ceil() * 5.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                'Temperaturas (°C)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  // Com um dia só, minX e maxX seriam iguais e o gráfico
                  // não teria largura; por isso o mínimo é 1.
                  maxX: dias.length > 1 ? (dias.length - 1).toDouble() : 1.0,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: pontosMaxima,
                      color: Colors.red,
                      barWidth: 3,
                    ),
                    LineChartBarData(
                      spots: pontosMinima,
                      color: Colors.blue,
                      barWidth: 3,
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 36,
                        getTitlesWidget: (valor, meta) {
                          return Text(
                            '${valor.toInt()}°',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (valor, meta) {
                          final indice = valor.toInt();
                          if (indice < 0 || indice >= dias.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatarDiaMes(dias[indice].data),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 10, color: Colors.red),
                SizedBox(width: 4),
                Text('Máxima'),
                SizedBox(width: 16),
                Icon(Icons.circle, size: 10, color: Colors.blue),
                SizedBox(width: 4),
                Text('Mínima'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
