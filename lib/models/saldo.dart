class Saldo {
  int? id;
  int clienteId;
  double saldo;
  String? observacao;

  Saldo({
    this.id,
    required this.clienteId,
    required this.saldo,
    this.observacao,
  });

  factory Saldo.fromMap(Map<String, dynamic> map) {
    return Saldo(
      id: map['id'],
      clienteId: map['cliente_id'],
      saldo: (map['saldo'] as num).toDouble(),
      observacao: map['observacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'saldo': saldo,
      'observacao': observacao,
    };
  }
}
