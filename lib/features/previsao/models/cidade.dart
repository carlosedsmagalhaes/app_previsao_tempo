// Uma localidade retornada pela busca do CPTEC/INPE.
class Cidade {
  // Código da localidade no CPTEC; é ele que vai na URL da previsão.
  final int id;
  final String nome;
  final String uf;

  const Cidade({required this.id, required this.nome, required this.uf});
}
