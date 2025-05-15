class Municipio {
  final String nome;
  final String codigoIbge;

  Municipio({required this.nome, required this.codigoIbge});

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      nome: json['nome'],
      codigoIbge: json['codigo_ibge'],
    );
  }
}