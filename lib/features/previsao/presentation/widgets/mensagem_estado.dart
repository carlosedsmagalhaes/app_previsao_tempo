import 'package:flutter/material.dart';

// Mensagem centralizada para os estados de vazio e de erro,
// com um botão opcional (ex.: "Tentar novamente").
class MensagemEstado extends StatelessWidget {
  final IconData icone;
  final String texto;
  final String? textoBotao;
  final VoidCallback? aoPressionar;

  const MensagemEstado({
    super.key,
    required this.icone,
    required this.texto,
    this.textoBotao,
    this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    final botao = textoBotao;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
            if (botao != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: aoPressionar, child: Text(botao)),
            ],
          ],
        ),
      ),
    );
  }
}
