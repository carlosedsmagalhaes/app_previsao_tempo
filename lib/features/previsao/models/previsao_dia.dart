// A previsão de um dia. Todos os campos podem faltar na resposta do
// serviço, por isso são anuláveis (?).
class PrevisaoDia {
  final DateTime? data;
  final String? sigla; // Ex.: 'ps' = Predomínio de Sol
  final int? minima; // °C
  final int? maxima; // °C
  final double? indiceUv;

  const PrevisaoDia({
    this.data,
    this.sigla,
    this.minima,
    this.maxima,
    this.indiceUv,
  });
}
