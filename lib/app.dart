import 'package:flutter/material.dart';

import 'package:app_previsao_tempo/features/previsao/presentation/screens/tela_busca.dart';

class AppPrevisaoTempo extends StatelessWidget {
  const AppPrevisaoTempo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Previsão do Tempo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const TelaBusca(),
    );
  }
}
