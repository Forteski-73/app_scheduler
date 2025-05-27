class Agenda {
  int? id;
  int clienteId;
  DateTime dataHora;
  String? observacao;
  String? nomeCliente; // <-- novo campo (não armazenado no banco diretamente)

  Agenda({
    this.id,
    required this.clienteId,
    required this.dataHora,
    this.observacao,
    this.nomeCliente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'data_hora': dataHora.toIso8601String(),
      'observacao': observacao,
      // 'nomeCliente' não é salvo no banco
    };
  }

  factory Agenda.fromMap(Map<String, dynamic> map) {
    return Agenda(
      id: map['id'],
      clienteId: map['cliente_id'],
      dataHora: DateTime.parse(map['data_hora']),
      observacao: map['observacao'],
      nomeCliente: map['nome_cliente'], // <-- precisa vir de um JOIN
    );
  }
}
