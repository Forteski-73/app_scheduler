import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:oxf_client/services/db_service.dart';

class Atendimentos extends StatefulWidget {
  @override
  _AtendimentosState createState() => _AtendimentosState();
}

class _AtendimentosState extends State<Atendimentos> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Atendimento> _todosAtendimentos = [];
  List<Atendimento> _atendimentosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _carregarAtendimentos();

    _searchController.addListener(() {
      _filtrarAtendimentos(_searchController.text);
    });
  }

  Future<void> _carregarAtendimentos() async {
    final lista = await _dbService.listarAtendimentosRealizados();
    setState(() {
      _todosAtendimentos = lista;
      _atendimentosFiltrados = lista;
    });
  }

  void _filtrarAtendimentos(String query) {
    if (query.length < 3) {
      setState(() {
        _atendimentosFiltrados = List.from(_todosAtendimentos);
      });
    } else {
      final filtro = query.toLowerCase();

      final listaFiltrada = _todosAtendimentos.where((atendimento) {
        final nome = atendimento.nomeCliente?.toLowerCase() ?? '';
        final dataInicioFormatada = DateFormat('dd/MM/yyyy HH:mm').format(atendimento.dataHoraInicio).toLowerCase();
        // Busca se nome contém filtro OU se data contém filtro
        return nome.contains(filtro) || dataInicioFormatada.contains(filtro);
      }).toList();

      setState(() {
        _atendimentosFiltrados = listaFiltrada;
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
          "Atendimentos",
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
                labelText: 'Pesquisar atendimento',
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
            child: _atendimentosFiltrados.isEmpty
                ? const Center(child: Text('Nenhum atendimento encontrado.'))
                : ListView.builder(
                    itemCount: _atendimentosFiltrados.length,
                    itemBuilder: (context, index) {
                      final atendimento = _atendimentosFiltrados[index];
                      return ListTile(
                        title: Text(
                          "Cliente: ${atendimento.nomeCliente}",
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Início: ${DateFormat('dd/MM/yyyy HH:mm').format(atendimento.dataHoraInicio)}",
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Término: ${atendimento.dataHoraFim == null ? "" : DateFormat('dd/MM/yyyy HH:mm').format(atendimento.dataHoraFim!)}",
                              style: const TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final atendimentoEditado = await Navigator.pushNamed(
                            context,
                            '/atendimento_editar',
                            arguments: atendimento,
                          );
                          if (atendimentoEditado != null && atendimentoEditado is Atendimento) {
                            _carregarAtendimentos();
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Aqui você pode implementar a exclusão
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
          await Navigator.pushNamed(context, '/atendimento_adicionar');
          _carregarAtendimentos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}