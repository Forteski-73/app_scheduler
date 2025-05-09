import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/services/db_service.dart';

class Agendas extends StatefulWidget {
  const Agendas({Key? key}) : super(key: key);

  @override
  State<Agendas> createState() => _AgendasState();
}

class _AgendasState extends State<Agendas> {
  final DatabaseService _dbService = DatabaseService();
  List<Agenda> _agendas = [];

  @override
  void initState() {
    super.initState();
    _carregarAgendas();
  }

  Future<void> _carregarAgendas() async {
    final agendas = await _dbService.listarAgendas();
    setState(() {
      _agendas = agendas;
    });
  }

  Future<void> _excluirAgenda(int id) async {
    await _dbService.deletarAgenda(id);
    await _carregarAgendas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agendas Cadastradas"),
      ),
      body: ListView.builder(
        itemCount: _agendas.length,
        itemBuilder: (context, index) {
          final agenda = _agendas[index];
          final dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora);

          return ListTile(
            title: Text("Cliente ID: ${agenda.clienteId} ${agenda.nomeCliente}"),
            subtitle: Text(
              dataFormatada,
              style: TextStyle(
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
              icon: Icon(Icons.delete),
              onPressed: () async {
                  await _excluirAgenda(agenda.id!);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/agenda_adicionar');
          _carregarAgendas();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}