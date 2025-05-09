class Agenda {
  int? id;
  int clienteId;
  DateTime dataHora;
  String? observacoes;
  String? nomeCliente; // <-- novo campo (não armazenado no banco diretamente)

  Agenda({
    this.id,
    required this.clienteId,
    required this.dataHora,
    this.observacoes,
    this.nomeCliente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'data_hora': dataHora.toIso8601String(),
      'observacoes': observacoes,
      // 'nomeCliente' não é salvo no banco
    };
  }

  factory Agenda.fromMap(Map<String, dynamic> map) {
    return Agenda(
      id: map['id'],
      clienteId: map['cliente_id'],
      dataHora: DateTime.parse(map['data_hora']),
      observacoes: map['observacoes'],
      nomeCliente: map['nome_cliente'], // <-- precisa vir de um JOIN
    );
  }
}
