import 'package:flutter/material.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';

class AtendimentoAdicionar extends StatefulWidget {
  const AtendimentoAdicionar({Key? key}) : super(key: key);

  @override
  _AtendimentoAdicionarState createState() => _AtendimentoAdicionarState();
}

class _AtendimentoAdicionarState extends State<AtendimentoAdicionar> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _valorPagoController;

  late List<Cliente> _clientes = [];
  Cliente? _clienteSelecionado;
  late List<Agenda> _agendas = [];
  Agenda? _agendaSelecionada;

  bool _realizado = false;
  bool _compareceu = false;
  bool _pagou = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController();
    _valorPagoController = TextEditingController();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await DatabaseService().listarClientes();
    setState(() {
      _clientes = clientes;
      _clienteSelecionado = null;
      _agendaSelecionada = null;
      _agendas = [];
    });
  }

  Future<void> _carregarAgendas() async {
    if (_clienteSelecionado != null) {
      final agendas = await DatabaseService().listarAgendas();
      setState(() {
        _agendas = agendas
            .where((agenda) => agenda.clienteId == _clienteSelecionado!.id)
            .toList();
        _agendaSelecionada = _agendas.isNotEmpty ? _agendas.first : null;
      });
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      if (_clienteSelecionado == null || _agendaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecione um cliente e uma agenda')));
        return;
      }

      final novoAtendimento = Atendimento(
        clienteId: _clienteSelecionado!.id!,
        agendaId: _agendaSelecionada!.id!,
        dataHoraInicio: DateTime.now(),
        compareceu: _compareceu,
        pagou: _pagou,
        valorPago: double.tryParse(_valorPagoController.text) ?? 0.0,
        dataHoraFim: null,
        descricao: _descricaoController.text,
        realizado: _realizado,
        nomeCliente: _clienteSelecionado!.nome, // Aqui está o nome do cliente
      );

      final id = await DatabaseService().inserirAtendimento(novoAtendimento);

      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Atendimento salvo com sucesso')));
        Navigator.pop(context, novoAtendimento);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar atendimento')));
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorPagoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Atendimento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Cliente>(
                value: _clienteSelecionado,
                decoration: const InputDecoration(labelText: 'Cliente'),
                onChanged: (cliente) {
                  setState(() {
                    _clienteSelecionado = cliente;
                    _carregarAgendas();
                  });
                },
                items: _clientes.map((cliente) {
                  return DropdownMenuItem<Cliente>(
                    value: cliente,
                    child: Text(cliente.nome),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Selecione um cliente' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Agenda>(
                value: _agendaSelecionada,
                decoration: const InputDecoration(labelText: 'Agenda'),
                onChanged: (agenda) {
                  setState(() {
                    _agendaSelecionada = agenda;
                  });
                },
                items: _agendas.map((agenda) {
                  return DropdownMenuItem<Agenda>(
                    value: agenda,
                    child: Text(
                      'Agenda ${agenda.id} - ${agenda.nomeCliente} - ${agenda.dataHora}',
                    ),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Selecione uma agenda' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _valorPagoController,
                decoration:
                    const InputDecoration(labelText: 'Valor Pago (opcional)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Realizado'),
                value: _realizado,
                onChanged: (val) {
                  setState(() {
                    _realizado = val;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Compareceu'),
                value: _compareceu,
                onChanged: (val) {
                  setState(() {
                    _compareceu = val;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Pagou'),
                value: _pagou,
                onChanged: (val) {
                  setState(() {
                    _pagou = val;
                  });
                },
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
