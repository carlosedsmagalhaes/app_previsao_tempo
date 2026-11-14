// Erro com uma mensagem pronta para mostrar ao usuário.
class ErroConsulta implements Exception {
  final String mensagem;

  const ErroConsulta(this.mensagem);

  @override
  String toString() => mensagem;
}
