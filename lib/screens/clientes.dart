import 'package:flutter/material.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';

class Clientes extends StatefulWidget {
  @override
  _ClientesState createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Cliente> _todosClientes = [];
  List<Cliente> clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarClientes();

    _searchController.addListener(() {
      _filtrarClientes(_searchController.text);
    });
  }

  Future<void> _carregarClientes() async {
    final lista = await _dbService.listarClientes();
    setState(() {
      _todosClientes = lista;
      clientes = lista;
    });
  }

  void _filtrarClientes(String query) {
    if (query.length < 3) {
      setState(() {
        clientes = List.from(_todosClientes);
      });
    } else {
      final filtro = query.toLowerCase();
      final listaFiltrada = _todosClientes.where((cliente) {
        return cliente.nome.toLowerCase().contains(filtro);
      }).toList();

      setState(() {
        clientes = listaFiltrada;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Clientes Cadastrados",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar cliente',
                prefixIcon: Icon(Icons.search, color: Colors.purple),
                border: InputBorder.none, // Sem borda
                filled: true,
                fillColor: Colors.grey[200],
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: clientes.isEmpty
                ? const Center(child: Text("Nenhum cliente cadastrado"))
                : ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      return ListTile(
                        title: Text(cliente.nome),
                        subtitle: Text(cliente.email),
                        onTap: () async {
                          final clienteEditado = await Navigator.pushNamed(
                            context,
                            '/cliente_editar',
                            arguments: cliente,
                          ) as Cliente?;

                          if (clienteEditado != null) {
                            setState(() {
                              clientes[index] = clienteEditado;
                              // Também atualizar _todosClientes para manter consistência
                              final idx = _todosClientes.indexWhere((c) => c.id == clienteEditado.id);
                              if (idx != -1) {
                                _todosClientes[idx] = clienteEditado;
                              }
                            });
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Excluir cliente
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.pushNamed(context, '/cliente_adicionar');
          await _carregarClientes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}