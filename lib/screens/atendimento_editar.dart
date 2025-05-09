import 'package:flutter/material.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:intl/intl.dart';

class AtendimentoEditar extends StatefulWidget {
  final Atendimento atendimento;

  const AtendimentoEditar({Key? key, required this.atendimento}) : super(key: key);

  @override
  _AtendimentoEditarState createState() => _AtendimentoEditarState();
}

class _AtendimentoEditarState extends State<AtendimentoEditar> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _agendaIdController;
  late TextEditingController _descricaoController;
  late TextEditingController _valorPagoController;
  late TextEditingController _dataHoraFimController;

  bool _realizado = false;
  bool _compareceu = false;
  bool _pagou = false;

  @override
  void initState() {
    super.initState();
    _agendaIdController = TextEditingController(text: widget.atendimento.agendaId.toString());
    _descricaoController = TextEditingController(text: widget.atendimento.descricao);
    _valorPagoController = TextEditingController(text: widget.atendimento.valorPago?.toString() ?? '');
    _dataHoraFimController = TextEditingController(
      text: widget.atendimento.dataHoraFim != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.atendimento.dataHoraFim!)
          : '',
    );

    _realizado = widget.atendimento.realizado;
    _compareceu = widget.atendimento.compareceu;
    _pagou = widget.atendimento.pagou;
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final atendimentoEditado = Atendimento(
        id: widget.atendimento.id,
        clienteId: widget.atendimento.clienteId,
        agendaId: int.parse(_agendaIdController.text),
        descricao: _descricaoController.text,
        realizado: _realizado,
        compareceu: _compareceu,
        pagou: _pagou,
        valorPago: double.tryParse(_valorPagoController.text),
        dataHoraInicio: widget.atendimento.dataHoraInicio,
        dataHoraFim: _dataHoraFimController.text.isNotEmpty
            ? DateTime.tryParse(_dataHoraFimController.text)
            : null,
        nomeCliente: widget.atendimento.nomeCliente, // Aqui estamos pegando o nome do cliente da instância
      );

      final dbService = DatabaseService();
      await dbService.atualizarAtendimento(atendimentoEditado); // Atualiza no banco

      Navigator.pop(context, atendimentoEditado); // Retorna atendimento atualizado
    }
  }

  @override
  void dispose() {
    _agendaIdController.dispose();
    _descricaoController.dispose();
    _valorPagoController.dispose();
    _dataHoraFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Atendimento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _agendaIdController,
                decoration: const InputDecoration(labelText: 'ID da Agenda'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o ID da agenda' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _valorPagoController,
                decoration: const InputDecoration(labelText: 'Valor Pago'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dataHoraFimController,
                decoration: const InputDecoration(
                    labelText: 'Data/Hora Fim (yyyy-MM-dd HH:mm:ss)'),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final parsed = DateTime.tryParse(value);
                    if (parsed == null) {
                      return 'Formato inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Realizado'),
                value: _realizado,
                onChanged: (val) => setState(() => _realizado = val),
              ),
              SwitchListTile(
                title: const Text('Compareceu'),
                value: _compareceu,
                onChanged: (val) => setState(() => _compareceu = val),
              ),
              SwitchListTile(
                title: const Text('Pagou'),
                value: _pagou,
                onChanged: (val) => setState(() => _pagou = val),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
