import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
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

  Cliente? _clienteSelecionado;
  Agenda? _agendaSelecionada;

  List<Cliente> _clientes = [];
  List<Agenda> _agendas = [];

  final _descricaoController = TextEditingController();
  late MoneyMaskedTextController _valorPagoController;

  bool _realizado = false;
  bool _compareceu = false;
  bool _pagou = false;

  bool _botaoHabilitado = false;

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _valorPagoController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue: 0.0,
    );
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await DatabaseService().listarClientes();
    setState(() => _clientes = clientes);
  }

  Future<void> _carregarAgendas() async {
    if (_clienteSelecionado == null) {
      setState(() {
        _agendas = [];
        _agendaSelecionada = null;
      });
      return;
    }

    final todasAgendas = await DatabaseService().listarAgendas();
    final agendasCliente = todasAgendas
        .where((a) => a.clienteId == _clienteSelecionado!.id)
        .toList();

    setState(() {
      _agendas = agendasCliente;
      _agendaSelecionada = null;
    });
  }

  void _validarFormulario() {
    setState(() {
      _botaoHabilitado =
          _clienteSelecionado != null && _agendaSelecionada != null;
    });
  }

  Future<void> _selecionarData(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _selecionarHora(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );

    if (picked != null) {
      setState(() => _horaSelecionada = picked);
    }
  }

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSelecionado == null || _agendaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione cliente e agenda')),
      );
      return;
    }

    final valorPago = _valorPagoController.numberValue;

    final dataHoraInicio = DateTime(
      _dataSelecionada.year,
      _dataSelecionada.month,
      _dataSelecionada.day,
      _horaSelecionada.hour,
      _horaSelecionada.minute,
    );

    final atendimento = Atendimento(
      clienteId: _clienteSelecionado!.id!,
      agendaId: _agendaSelecionada!.id!,
      dataHoraInicio: dataHoraInicio,
      compareceu: _compareceu,
      pagou: _pagou,
      valorPago: valorPago,
      dataHoraFim: null,
      descricao: _descricaoController.text,
      realizado: _realizado,
      nomeCliente: _clienteSelecionado!.nome,
    );

    final id = await DatabaseService().inserirAtendimento(atendimento);

    if (id > 0) {
      await DatabaseService().inserirPagamento(
        clienteId: _clienteSelecionado!.id!,
        atendimentoId: id,
        valorCobrado: valorPago,
        valorPago: valorPago,
        tipoPgto: 'Dinheiro',
        data: DateFormat('yyyy-MM-dd').format(dataHoraInicio),
        hora: DateFormat('HH:mm').format(dataHoraInicio),
        observacao: '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atendimento salvo com sucesso')),
      );
      Navigator.pop(context, atendimento);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar atendimento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Adicionar Atendimento",
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownSearch<Cliente>(
                items: _clientes,
                selectedItem: _clienteSelecionado,
                itemAsString: (c) => c.nome,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  labelText: 'Cliente',
                )),
                onChanged: (c) {
                  setState(() {
                    _clienteSelecionado = c;
                    _agendaSelecionada = null;
                    _agendas = [];
                  });
                  _carregarAgendas();
                  _validarFormulario();
                },
                validator: (c) => c == null ? 'Selecione um cliente' : null,
                popupProps: const PopupProps.menu(showSearchBox: true),
              ),
              const SizedBox(height: 16),
              DropdownSearch<Agenda>(
                items: _agendas,
                selectedItem: _agendaSelecionada,
                itemAsString: (a) =>
                    '${a.nomeCliente} - ${DateFormat('dd/MM/yyyy HH:mm').format(a.dataHora)}',
                dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  labelText: 'Agenda',
                )),
                onChanged: (a) {
                  setState(() {
                    _agendaSelecionada = a;
                  });
                  _validarFormulario();
                },
                validator: (a) => a == null ? 'Selecione uma agenda' : null,
                popupProps: const PopupProps.menu(showSearchBox: true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 16),

              // Campo Valor Pago com incremento/decremento
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valorPagoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Valor Pago'),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Informe o valor pago';
                        }
                        // Opcional: validar valor numérico > 0
                        if (_valorPagoController.numberValue < 0) {
                          return 'Valor pago não pode ser negativo';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () {
                          setState(() {
                            _valorPagoController.updateValue(
                              _valorPagoController.numberValue + 1,
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          setState(() {
                            final novoValor = (_valorPagoController.numberValue - 1)
                                .clamp(0.0, double.infinity);
                            _valorPagoController.updateValue(novoValor);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Linha com Data Início e Hora Início lado a lado
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selecionarData(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Data Início',
                            suffixIcon: Icon(Icons.calendar_today, color: Colors.purple,),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Selecione a data' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selecionarHora(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Hora Início',
                            suffixIcon: Icon(Icons.access_time, color: Colors.purple,),
                          ),
                          controller: TextEditingController(
                            text: _horaSelecionada.format(context),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Selecione a hora' : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Realizado'),
                value: _realizado,
                onChanged: (v) => setState(() => _realizado = v),
              ),
              SwitchListTile(
                title: const Text('Compareceu'),
                value: _compareceu,
                onChanged: (v) => setState(() => _compareceu = v),
              ),
              SwitchListTile(
                title: const Text('Pagou'),
                value: _pagou,
                onChanged: (v) => setState(() => _pagou = v),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'home',
            backgroundColor: Colors.purple,
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
            child: const Icon(Icons.home),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'salvar',
            backgroundColor: _botaoHabilitado ? Colors.deepPurple : Colors.grey,
            onPressed: _botaoHabilitado ? _salvar : null,
            child: const Icon(Icons.done),
          ),
        ],
      ),
    );
  }
}
