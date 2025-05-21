import 'package:flutter/material.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';

class Pagamentos extends StatefulWidget {
  const Pagamentos({Key? key}) : super(key: key);

  @override
  State<Pagamentos> createState() => _PagamentosState();
}

class _PagamentosState extends State<Pagamentos> {
  final DatabaseService _dbService = DatabaseService();
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _dbService.listarClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado'))
          : ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                return ListTile(
                  title: Text(cliente.nome),
                  subtitle: Text('${cliente.email} • ${cliente.telefone}'),
                  trailing: cliente.precoAtendimento != null
                      ? Text(
                          'R\$ ${cliente.precoAtendimento!.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : const Text('R\$ 0,00'),
                );
              },
            ),
    );
  }
}