class Pagamento {
  int? id;
  int clienteId;
  int atendimentoId;
  double? valorCobrado;
  double? valorPago;
  String? tipoPgto; // Pix, Dinheiro, Cartão, Crédito Antecipado
  String? data;
  String? hora;
  String? observacao;

  Pagamento({
    this.id,
    required this.clienteId,
    required this.atendimentoId,
    this.valorCobrado,
    this.valorPago,
    this.tipoPgto,
    this.data,
    this.hora,
    this.observacao,
  });

  factory Pagamento.fromMap(Map<String, dynamic> map) {
    return Pagamento(
      id: map['id'],
      clienteId: map['cliente_id'],
      atendimentoId: map['atendimento_id'],
      valorCobrado: (map['valor_cobrado'] as num?)?.toDouble(),
      valorPago: (map['valor_pago'] as num?)?.toDouble(),
      tipoPgto: map['tipo_pgto'],
      data: map['data'],
      hora: map['hora'],
      observacao: map['observacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'atendimento_id': atendimentoId,
      'valor_cobrado': valorCobrado,
      'valor_pago': valorPago,
      'tipo_pgto': tipoPgto,
      'data': data,
      'hora': hora,
      'observacao': observacao,
    };
  }
}