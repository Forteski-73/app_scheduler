import 'package:flutter/material.dart';
import '../models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class ClienteEditar extends StatefulWidget {
  final Cliente cliente;

  const ClienteEditar({super.key, required this.cliente});

  @override
  State<ClienteEditar> createState() => _ClienteEditarState();
}

class _ClienteEditarState extends State<ClienteEditar> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TextEditingController cidadeController;
  late TextEditingController ufController;
  late MoneyMaskedTextController precoController;

  final List<String> estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) ##### ####',
    filter: { "#": RegExp(r'[0-9]') },
  );

  late String? ufSelecionada;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.cliente.nome);
    emailController = TextEditingController(text: widget.cliente.email);
    telefoneController = TextEditingController(text: widget.cliente.telefone);
    cidadeController = TextEditingController(text: widget.cliente.cidade);
    ufController = TextEditingController(text: widget.cliente.uf);
    precoController = MoneyMaskedTextController (
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue: 0.0,
    );
    ufController = TextEditingController(text: widget.cliente.uf);
    ufSelecionada = (widget.cliente.uf != null && widget.cliente.uf!.isNotEmpty)
        ? widget.cliente.uf!.toUpperCase()
        : null;
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    cidadeController.dispose();
    ufController.dispose();
    precoController.dispose();
    super.dispose();
  }

  void salvar() async {
    if (_formKey.currentState!.validate()) {

      String precoTexto = precoController.text.trim();
      precoTexto = precoTexto.replaceAll('.', '').replaceAll(',', '.');

      double preco = double.tryParse(precoTexto) ?? 0.0;

      final clienteEditado = Cliente(
        id: widget.cliente.id,
        nome: nomeController.text,
        email: emailController.text,
        telefone: telefoneController.text,
        cidade: cidadeController.text,
        uf: ufController.text,
        precoAtendimento: preco,
        dataCadastro: widget.cliente.dataCadastro,
      );

      final db = DatabaseService();
      await db.atualizarCliente(clienteEditado);

      Navigator.of(context).pop(clienteEditado); // opcional: retorne o cliente atualizado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Cliente",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back,
              color: Colors.purple,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 16),
              TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.number,
                inputFormatters: [telefoneFormatter],
              ),
              const SizedBox(height: 16),
              TextFormField(controller: cidadeController, decoration: const InputDecoration(labelText: 'Cidade')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: ufSelecionada,
                decoration: const InputDecoration(labelText: 'UF'),
                items: estados.map((uf) {
                  return DropdownMenuItem<String>(
                    value: uf,
                    child: Text(uf),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    ufSelecionada = valor;
                    ufController.text = valor ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione uma UF';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: precoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Preço do Atendimento"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () {
                          precoController.updateValue(
                            precoController.numberValue + 1,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          final novoValor = (precoController.numberValue - 1).clamp(0.0, double.infinity);
                          precoController.updateValue(novoValor);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
