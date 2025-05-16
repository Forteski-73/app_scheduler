import 'package:flutter/material.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

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
  late MoneyMaskedTextController _valorPagoController;
  late TextEditingController _dataFimController;
  late TextEditingController _horaFimController;
  late TextEditingController _dataInicioController;
  late TextEditingController _horaInicioController;

  bool _realizado = false;
  bool _compareceu = false;
  bool _pagou = false;

  @override
  void initState() {
    super.initState();
    // Inicializando os controladores com os valores vindos de 'widget.atendimento'
    _agendaIdController = TextEditingController(text: widget.atendimento.agendaId.toString());
    _descricaoController = TextEditingController(text: widget.atendimento.descricao);
    _valorPagoController = MoneyMaskedTextController (
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue: 0.0,
    );

    _dataInicioController = TextEditingController();
    _horaInicioController = TextEditingController();

    if (widget.atendimento.dataHoraInicio != null) {
      _dataInicioController.text = DateFormat('dd/MM/yyyy').format(widget.atendimento.dataHoraInicio);
      _horaInicioController.text = DateFormat('HH:mm').format(widget.atendimento.dataHoraInicio);
    }
    _dataFimController = TextEditingController();
    _horaFimController = TextEditingController();

    if (widget.atendimento.dataHoraFim != null) {
      // Preenchendo data e hora separadamente
      _dataFimController.text = DateFormat('dd/MM/yyyy').format(widget.atendimento.dataHoraFim!);
      _horaFimController.text = DateFormat('HH:mm').format(widget.atendimento.dataHoraFim!);
    }

    _realizado = widget.atendimento.realizado;
    _compareceu = widget.atendimento.compareceu;
    _pagou = widget.atendimento.pagou;
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      // Unificando data e hora para salvar
      String? dataHoraFimString;
      if (_dataFimController.text.isNotEmpty && _horaFimController.text.isNotEmpty) {
        final data = DateFormat('dd/MM/yyyy').parse(_dataFimController.text);
        final hora = _horaFimController.text.split(':');
        if (hora.length == 2) {
          final novaDataHoraFim = DateTime(
            data.year,
            data.month,
            data.day,
            int.parse(hora[0]),
            int.parse(hora[1]),
          );
          dataHoraFimString = novaDataHoraFim.toIso8601String();
        }
      }

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
        dataHoraFim: dataHoraFimString != null ? DateTime.parse(dataHoraFimString) : null,
        nomeCliente: widget.atendimento.nomeCliente, // Atribuindo nomeCliente do atendimento
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
    _dataInicioController.dispose();
    _horaInicioController.dispose();
    _dataFimController.dispose();
    _horaFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Atendimento",
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
          child: ListView(
            children: [
              TextFormField(
                controller: _agendaIdController,
                readOnly: true,
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

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valorPagoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Valor Pago'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () {
                          _valorPagoController.updateValue(
                            _valorPagoController.numberValue + 1,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          final novoValor = (_valorPagoController.numberValue - 1).clamp(0.0, double.infinity);
                          _valorPagoController.updateValue(novoValor);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataInicioController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data Início',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Hora Início',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Campo para data
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _dataFimController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data fim',
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.purple,),
                      ),
                      onTap: () async {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          FocusScope.of(context).unfocus();
                          DateTime now = DateTime.now();
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            locale: const Locale('pt', 'BR'),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dataFimController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                            });
                          }
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            DateFormat('dd/MM/yyyy').parseStrict(value);
                          } catch (_) {
                            return 'Formato de data inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12), // Espaço entre os campos
                  // Campo para hora
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _horaFimController,
                      decoration: const InputDecoration(
                        labelText: 'Hora Fim',
                        suffixIcon: Icon(Icons.access_time, color: Colors.purple,),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );

                        if (pickedTime != null) {
                          final String formattedTime =
                              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                          _horaFimController.text = formattedTime;
                        }
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final timeParts = value.split(':');
                          if (timeParts.length != 2 ||
                              int.tryParse(timeParts[0]) == null ||
                              int.tryParse(timeParts[1]) == null ||
                              int.parse(timeParts[0]) > 23 ||
                              int.parse(timeParts[1]) > 59) {
                            return 'Formato de hora inválido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}