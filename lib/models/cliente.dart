class Cliente {
  int? id;
  String nome;
  String email;
  String telefone;
  String? cidade;
  String? uf;
  double? precoAtendimento;
  DateTime? dataCadastro;

  Cliente({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.cidade,
    this.uf,
    this.precoAtendimento,
    this.dataCadastro,
  });

  // Converte um mapa (resultado do banco de dados) para um objeto Cliente
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      telefone: map['telefone'],
      cidade: map['cidade'],
      uf: map['uf'],
      precoAtendimento: (map['preco_atendimento'] as num?)?.toDouble(),
      dataCadastro: map['data_cadastro'] != null
          ? DateTime.parse(map['data_cadastro'])
          : null,
    );
  }

  // Converte um objeto Cliente para um mapa (para salvar no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cidade': cidade,
      'uf': uf,
      'preco_atendimento': precoAtendimento,
      'data_cadastro': dataCadastro?.toIso8601String(),
    };
  }
}
