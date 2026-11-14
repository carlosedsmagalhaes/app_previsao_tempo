import 'package:flutter/material.dart';

// Identificação obrigatória da fonte dos dados.
class FonteDados extends StatelessWidget {
  const FonteDados({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'Fonte dos dados: CPTEC/INPE',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
