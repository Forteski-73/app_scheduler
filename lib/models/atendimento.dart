class Atendimento {
  int? id;
  int clienteId;
  int agendaId;
  DateTime dataHoraInicio;
  bool compareceu;
  bool pagou;
  double? valorPago;
  DateTime? dataHoraFim;
  String descricao;
  bool realizado;
  String nomeCliente;  // Novo campo para armazenar o nome do cliente

  Atendimento({
    this.id,
    required this.clienteId,
    required this.agendaId,
    required this.dataHoraInicio,
    required this.compareceu,
    required this.pagou,
    this.valorPago,
    this.dataHoraFim,
    required this.descricao,
    required this.realizado,
    required this.nomeCliente,  // Inicializando nomeCliente
  });

  factory Atendimento.fromMap(Map<String, dynamic> map) {
    return Atendimento(
      id: map['id'],
      clienteId: map['cliente_id'],
      agendaId: map['agenda_id'],
      dataHoraInicio: DateTime.parse(map['data_hora_inicio']),
      compareceu: map['compareceu'] == 1,
      pagou: map['pagou'] == 1,
      valorPago: map['valor_pago']?.toDouble(),
      dataHoraFim: map['data_hora_fim'] != null
          ? DateTime.parse(map['data_hora_fim'])
          : null,
      descricao: map['descricao'],
      realizado: map['realizado'] == 1,
      nomeCliente: map['nome_cliente'] ?? '',  // Atribuindo uma string vazia caso seja nulo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'agenda_id': agendaId,
      'data_hora_inicio': dataHoraInicio.toIso8601String(),
      'compareceu': compareceu ? 1 : 0,
      'pagou': pagou ? 1 : 0,
      'valor_pago': valorPago,
      'data_hora_fim': dataHoraFim?.toIso8601String(),
      'descricao': descricao,
      'realizado': realizado ? 1 : 0,
      'nome_cliente': nomeCliente,  // Salvando o nome do cliente
    };
  }
}