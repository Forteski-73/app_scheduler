import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/services/db_service.dart';

class AgendaEditar extends StatefulWidget {
  final Agenda agenda;

  const AgendaEditar({Key? key, required this.agenda}) : super(key: key);

  @override
  _AgendaEditarState createState() => _AgendaEditarState();
}

class _AgendaEditarState extends State<AgendaEditar> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _dataHora;
  late TextEditingController _observacoesController;
  late TextEditingController _dataController;
  late TextEditingController _horaController;

  @override
  void initState() {
    super.initState();
    _dataHora = widget.agenda.dataHora;
    _dataController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(_dataHora));
    _horaController = TextEditingController(text: DateFormat('HH:mm').format(_dataHora));
    _observacoesController = TextEditingController(text: widget.agenda.observacoes ?? '');
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataHora = dataSelecionada;
        _dataController.text = DateFormat('dd/MM/yyyy').format(_dataHora);
      });
    }
  }

  Future<void> _selecionarHora() async {
    final TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora),
    );

    if (horaSelecionada != null) {
      setState(() {
        _dataHora = DateTime(
          _dataHora.year,
          _dataHora.month,
          _dataHora.day,
          horaSelecionada.hour,
          horaSelecionada.minute,
        );
        _horaController.text = DateFormat('HH:mm').format(_dataHora);
      });
    }
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final novaAgenda = Agenda(
        id: widget.agenda.id,
        clienteId: widget.agenda.clienteId,
        dataHora: _dataHora,
        observacoes: _observacoesController.text,
        nomeCliente: widget.agenda.nomeCliente,
      );

      // Atualizar a agenda no banco
      DatabaseService().atualizarAgenda(novaAgenda).then((rowsAffected) {
        if (rowsAffected > 0) {
          Navigator.pop(context, novaAgenda);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar agenda. Tente novamente.')),
          );
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar agenda. Tente novamente.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Agenda",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cliente: ${widget.agenda.nomeCliente ?? "Não informado"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Campo de data
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    labelStyle: TextStyle(color: Colors.black),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.purple),
                  ),
                  child: Text(
                    _dataController.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Campo de hora
              InkWell(
                onTap: _selecionarHora,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hora',
                    labelStyle: TextStyle(color: Colors.black),
                    suffixIcon: Icon(Icons.access_time, color: Colors.purple),
                  ),
                  child: Text(
                    _horaController.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  labelStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _salvar,
                    child: const Text('Salvar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
