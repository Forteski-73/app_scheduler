import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:oxf_client/services/db_service.dart';

class Atendimentos extends StatefulWidget {
  @override
  _AtendimentosState createState() => _AtendimentosState();
}

class _AtendimentosState extends State<Atendimentos> {
  late Future<List<Atendimento>> _atendimentos;

  @override
  void initState() {
    super.initState();
    _atendimentos = DatabaseService().listarAtendimentosRealizados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atendimentos Realizados"),
      ),
      body: FutureBuilder<List<Atendimento>>(
        future: _atendimentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar atendimentos.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum atendimento realizado encontrado.'));
          } else {
            final atendimentos = snapshot.data!;
            return ListView.builder(
              itemCount: atendimentos.length,
              itemBuilder: (context, index) {
                final atendimento = atendimentos[index];
                return ListTile(
                  title: Text("Cliente: ${atendimento.nomeCliente} (ID: ${atendimento.clienteId})"),
                  subtitle: Text(
                    "Início: ${DateFormat('dd/MM/yyyy HH:mm').format(atendimento.dataHoraInicio)}",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/atendimento_editar', arguments: atendimento);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Excluir atendimento
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/atendimento_adicionar');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
