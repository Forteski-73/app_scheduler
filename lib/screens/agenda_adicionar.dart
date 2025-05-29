import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AgendaAdicionar extends StatefulWidget {
  final DateTime? dataSelecionada;

  const AgendaAdicionar({super.key, this.dataSelecionada});

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

  bool _botaoHabilitado = false;

  @override
  void initState() {
    super.initState();
    _carregarClientes();

    final data = widget.dataSelecionada;
    if (data != null) {
      _dataController.text = DateFormat('dd/MM/yyyy').format(data);
    }

    // Adiciona listeners para atualizar o estado do botão quando data ou hora mudarem
    _dataController.addListener(_atualizarBotaoHabilitado);
    _horaController.addListener(_atualizarBotaoHabilitado);
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

  void _atualizarBotaoHabilitado() {
    final dataValida = _validarDataHora();
    final clienteSelecionado = _clienteSelecionado != null;
    final formValido = _formKey.currentState?.validate() ?? false;

    final habilitar = dataValida && clienteSelecionado && formValido;

    if (_botaoHabilitado != habilitar) {
      setState(() {
        _botaoHabilitado = habilitar;
      });
    }
  }

  bool _validarDataHora() {
    if (_dataController.text.isEmpty || _horaController.text.isEmpty) return false;

    try {
      final data = DateFormat('dd/MM/yyyy').parse(_dataController.text.trim());
      final partesHora = _horaController.text.trim().split(":");
      if (partesHora.length != 2) return false;

      final hora = int.parse(partesHora[0]);
      final minuto = int.parse(partesHora[1]);

      final dataHora = DateTime(data.year, data.month, data.day, hora, minuto);
      return dataHora.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
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
      _atualizarBotaoHabilitado();
    }
  }

  void _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      final formattedTime = hora.format(context);
      _horaController.text = formattedTime;
      _atualizarBotaoHabilitado();
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate() && _validarDataHora() && _clienteSelecionado != null) {
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
          observacao: _observacoesController.text,
          nomeCliente: _clienteSelecionado!.nome,
        );

        await _dbService.inserirAgenda(novaAgenda);

        // <-- AQUI ESTÁ O RETORNO COM A AGENDA INSERIDA
        Navigator.pop(context, novaAgenda);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao processar data ou hora. Verifique o formato.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos corretamente e selecione uma data/hora futura.")),
      );
    }
  }

  /*
  void _salvar() async {
    if (_formKey.currentState!.validate() && _validarDataHora() && _clienteSelecionado != null) {
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
          observacao: _observacoesController.text,
        );

        await _dbService.inserirAgenda(novaAgenda);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao processar data ou hora. Verifique o formato.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos corretamente e selecione uma data/hora futura.")),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Agenda", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.purple),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _atualizarBotaoHabilitado, // valida ao mudar qualquer campo
          child: ListView(
            children: [
              DropdownSearch<Cliente>(
                items: _clientes,
                itemAsString: (Cliente c) => c.nome,
                selectedItem: _clienteSelecionado,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Cliente"),
                ),
                onChanged: (Cliente? cliente) {
                  setState(() {
                    _clienteSelecionado = cliente;
                    _atualizarBotaoHabilitado();
                  });
                },
                enabled: _clientes.isNotEmpty,
                popupProps: const PopupProps.menu(showSearchBox: true),
                validator: (value) => value == null ? 'Selecione um cliente' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.purple),
                ),
                readOnly: true,
                onTap: _selecionarData,
                //validator: (value) => value == null || value.isEmpty ? 'Informe a data' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  suffixIcon: Icon(Icons.access_time, color: Colors.purple),
                ),
                readOnly: true,
                onTap: _selecionarHora,
                //validator: (value) => value == null || value.isEmpty ? 'Informe a hora' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
              /*const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _botaoHabilitado ? _salvar : null,
                child: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),*/
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: "home_agenda",
              backgroundColor: Colors.purple,
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Icon(Icons.home),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "salvar_agenda",
              backgroundColor: Colors.deepPurple,
              onPressed: _botaoHabilitado ? _salvar : null,
              child: const Icon(Icons.done),
            ),
          ],
        ),
      ),
    );
  }
}
