import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';

class AgendaAdicionar extends StatefulWidget {
  const AgendaAdicionar({super.key});

  @override
  State<AgendaAdicionar> createState() => _AgendaAdicionarState();
}

class _AgendaAdicionarState extends State<AgendaAdicionar> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _observacoesController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  List<Cliente> _clientes = [];
  Cliente? _clienteSelecionado;

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
  void dispose() {
    _dataController.dispose();
    _horaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      _dataController.text = DateFormat('dd/MM/yyyy').format(data);
    }
  }

  void _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      _horaController.text = hora.format(context);
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      if (_clienteSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecione um cliente")),
        );
        return;
      }
      try {
        final data = DateFormat('dd/MM/yyyy').parse(_dataController.text.trim());
        final partesHora = _horaController.text.trim().split(":");

        final hora = TimeOfDay(
          hour: int.parse(partesHora[0]),
          minute: int.parse(partesHora[1]),
        );

        final dataHora = DateTime(
          data.year,
          data.month,
          data.day,
          hora.hour,
          hora.minute,
        );

        final novaAgenda = Agenda(
          clienteId: _clienteSelecionado!.id!,
          dataHora: dataHora,
          observacoes: _observacoesController.text,
        );

        await _dbService.inserirAgenda(novaAgenda);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao processar data ou hora. Verifique o formato.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Agenda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Cliente>(
                value: _clienteSelecionado,
                items: _clientes.map((cliente) {
                  return DropdownMenuItem(
                    value: cliente,
                    child: Text(cliente.nome),
                  );
                }).toList(),
                onChanged: (cliente) {
                  setState(() {
                    _clienteSelecionado = cliente;
                  });
                },
                decoration: const InputDecoration(labelText: 'Cliente'),
                validator: (value) =>
                    value == null ? 'Selecione um cliente' : null,
              ),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Data (dd/mm/aaaa)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selecionarData,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a data' : null,
              ),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Informe a hora';
                  final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
                  if (!regex.hasMatch(value.trim())) return 'Formato inválido. Use HH:mm (24h)';
                  return null;
                },
              ),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}