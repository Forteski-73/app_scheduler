import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:oxf_client/screens/calendario.dart';

class Agendas extends StatefulWidget {
  final DateTime? diaSelecionado;

  const Agendas({Key? key, this.diaSelecionado}) : super(key: key);

  @override
  State<Agendas> createState() => _AgendasState();
}

class _AgendasState extends State<Agendas> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Agenda> _todasAgendas = [];
  List<Agenda> _agendas = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      _filtrarAgendas(_searchController.text);
    });

    _carregarAgendas().then((_) {
      if (widget.diaSelecionado != null) {
        final dataFormatada = DateFormat('dd/MM/yyyy').format(widget.diaSelecionado!);
        _searchController.text = dataFormatada;
        _filtrarAgendas(dataFormatada);
      }
    });
  }

  Future<void> _carregarAgendas() async {
    final agendas = await _dbService.listarAgendas();

    if (widget.diaSelecionado != null) {
      final dia = DateTime(widget.diaSelecionado!.year, widget.diaSelecionado!.month, widget.diaSelecionado!.day);

      final filtradas = agendas.where((agenda) {
        final dataAgenda = DateTime(agenda.dataHora.year, agenda.dataHora.month, agenda.dataHora.day);
        return dataAgenda == dia;
      }).toList();

      setState(() {
        _todasAgendas = filtradas;
        _agendas = filtradas;
      });
    } else {
      setState(() {
        _todasAgendas = agendas;
        _agendas = agendas;
      });
    }
  }

  void _filtrarAgendas(String query) {
    if (query.length < 3) {
      setState(() {
        _agendas = List.from(_todasAgendas);
      });
    } else {
      final filtro = query.toLowerCase();

      final listaFiltrada = _todasAgendas.where((agenda) {
        final nome = agenda.nomeCliente?.toLowerCase() ?? '';

        // Formata a data como string, para comparação
        final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora).toLowerCase();

        // Retorna true se encontrar o filtro
        return nome.contains(filtro) || dataFormatada.contains(filtro);
      }).toList();

      setState(() {
        _agendas = listaFiltrada;
      });
    }
  }

  Future<void> _excluirAgenda(int id) async {
    await _dbService.deletarAgenda(id);
    await _carregarAgendas();
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
          "Agendas Cadastradas",
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
                labelText: 'Pesquisar agenda',
                prefixIcon: Icon(Icons.search, color: Colors.purple),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200],
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _agendas.isEmpty
                ? const Center(child: Text("Nenhuma agenda cadastrada"))
                : ListView.builder(
                    itemCount: _agendas.length,
                    itemBuilder: (context, index) {
                      final agenda = _agendas[index];
                      final dataFormatada =
                          DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora);
                      return ListTile(
                        title: Text("Cliente ID: ${agenda.clienteId} ${agenda.nomeCliente}"),
                        subtitle: Text(
                          dataFormatada,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/agenda_editar',
                            arguments: agenda,
                          ).then((_) => _carregarAgendas());
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirmado = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: Text('Deseja realmente excluir a agenda "${agenda.nomeCliente} ${DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora)}"?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirmado == true) {
                              await _excluirAgenda(agenda.id!);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // botton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "home",
              backgroundColor: Colors.purple,
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/')); // ou sua rota principal
              },
              child: const Icon(Icons.home),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "calendario",
              backgroundColor: Colors.purple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Calendario()),
                );
              },
              child: const Icon(Icons.calendar_month),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "adicionar",
              backgroundColor: Colors.deepPurple,
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/agenda_adicionar',
                  arguments: widget.diaSelecionado,
                );
                _carregarAgendas();
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}