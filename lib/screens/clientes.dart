import 'package:flutter/material.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';

class Clientes extends StatefulWidget {
  @override
  _ClientesState createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {
  final DatabaseService _dbService = DatabaseService();
  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final lista = await _dbService.listarClientes();
    setState(() {
      clientes = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clientes Cadastrados")),
      body: clientes.isEmpty
          ? Center(child: Text("Nenhum cliente cadastrado"))
          : ListView.builder(
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                return ListTile(
                  title: Text(cliente.nome),
                  subtitle: Text(cliente.email),
                  onTap: () {
                    Navigator.pushNamed(context, '/cliente_editar', arguments: cliente);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Excluir cliente
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cliente_adicionar');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
