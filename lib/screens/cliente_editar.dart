import 'package:flutter/material.dart';
import '../models/cliente.dart';

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
  late TextEditingController precoController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.cliente.nome);
    emailController = TextEditingController(text: widget.cliente.email);
    telefoneController = TextEditingController(text: widget.cliente.telefone);
    cidadeController = TextEditingController(text: widget.cliente.cidade);
    ufController = TextEditingController(text: widget.cliente.uf);
    precoController = TextEditingController(text: widget.cliente.precoAtendimento.toString());
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

  void salvar() {
    if (_formKey.currentState!.validate()) {
      final clienteEditado = Cliente(
        id: widget.cliente.id,
        nome: nomeController.text,
        email: emailController.text,
        telefone: telefoneController.text,
        cidade: cidadeController.text,
        uf: ufController.text,
        precoAtendimento: double.tryParse(precoController.text) ?? 0.0,
        dataCadastro: widget.cliente.dataCadastro,
      );
      Navigator.of(context).pop(clienteEditado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
              TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(controller: telefoneController, decoration: const InputDecoration(labelText: 'Telefone')),
              TextFormField(controller: cidadeController, decoration: const InputDecoration(labelText: 'Cidade')),
              TextFormField(controller: ufController, decoration: const InputDecoration(labelText: 'UF')),
              TextFormField(controller: precoController, decoration: const InputDecoration(labelText: 'Preço Atendimento')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
