import 'package:flutter/material.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AtendimentoAdicionar extends StatefulWidget {
  const AtendimentoAdicionar({Key? key}) : super(key: key);

  @override
  _AtendimentoAdicionarState createState() => _AtendimentoAdicionarState();
}

class _AtendimentoAdicionarState extends State<AtendimentoAdicionar> {
  final _formKey = GlobalKey<FormState>();
  final LayerLink _layerLink = LayerLink();
  final LayerLink _layerLinkAgenda = LayerLink();

  final FocusNode _clienteFocusNode = FocusNode();
  final FocusNode _agendaFocusNode = FocusNode();

  late TextEditingController _clienteController;
  late TextEditingController _agendaController;
  late TextEditingController _descricaoController;
  late MoneyMaskedTextController _valorPagoController;

  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  Cliente? _clienteSelecionado;

  List<Agenda> _agendas = [];
  List<Agenda> _agendasFiltradas = [];
  Agenda? _agendaSelecionada;

  bool _realizado = false;
  bool _compareceu = false;
  bool _pagou = false;

  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlayAgenda;

  @override
  void initState() {
    super.initState();
    _clienteController = TextEditingController();
    _agendaController = TextEditingController();
    _descricaoController = TextEditingController();
    _valorPagoController = MoneyMaskedTextController (
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue: 0.0,
    );
    _carregarClientes();

    _clienteFocusNode.addListener(() {
      if (!_clienteFocusNode.hasFocus) _removeOverlay();
    });

    _agendaFocusNode.addListener(() {
      if (!_agendaFocusNode.hasFocus) _removeAgendaOverlay();
    });
  }

  Future<void> _carregarClientes() async {
    final clientes = await DatabaseService().listarClientes();
    setState(() {
      _clientes = clientes;
      _clientesFiltrados = clientes;
    });
  }

  Future<void> _carregarAgendas() async {
    if (_clienteSelecionado != null) {
      final todasAgendas = await DatabaseService().listarAgendas();
      final agendasFiltradas = todasAgendas
          .where((agenda) => agenda.clienteId == _clienteSelecionado!.id)
          .toList();

      setState(() {
        _agendas = agendasFiltradas;
        _agendasFiltradas = agendasFiltradas;
        _agendaSelecionada = null;
        _agendaController.clear();
      });
    } else {
      setState(() {
        _agendas = [];
        _agendasFiltradas = [];
        _agendaSelecionada = null;
        _agendaController.clear();
      });
    }
  }

  void _filtrarClientes(String query) {
    setState(() {
      _clientesFiltrados = _clientes
          .where((c) => c.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _mostrarOverlay();
  }

  void _filtrarAgendas(String query) {
    setState(() {
      _agendasFiltradas = _agendas
          .where((a) =>
              (a.nomeCliente?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              DateFormat('dd/MM/yyyy HH:mm').format(a.dataHora).contains(query))
          .toList();
          });
    _mostrarAgendaOverlay();
  }

  void _mostrarOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 56),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _clientesFiltrados.length,
              itemBuilder: (context, index) {
                final cliente = _clientesFiltrados[index];
                return ListTile(
                  title: Text(cliente.nome),
                  onTap: () {
                    setState(() {
                      _clienteSelecionado = cliente;
                      _clienteController.text = cliente.nome;
                      _clientesFiltrados = _clientes;
                    });
                    _carregarAgendas();
                    _removeOverlay();
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _mostrarAgendaOverlay() {
    _removeAgendaOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = Overlay.of(context);
    _overlayAgenda = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLinkAgenda,
          offset: const Offset(0, 56),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _agendasFiltradas.length,
              itemBuilder: (context, index) {
                final agenda = _agendasFiltradas[index];
                return ListTile(
                  title: Text(
                    '${agenda.nomeCliente} - ${DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora)}',
                  ),
                  onTap: () {
                    setState(() {
                      _agendaSelecionada = agenda;
                      _agendaController.text =
                          '${agenda.nomeCliente} - ${DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora)}';
                      _agendasFiltradas = _agendas;
                    });
                    _removeAgendaOverlay();
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayAgenda!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _removeAgendaOverlay() {
    _overlayAgenda?.remove();
    _overlayAgenda = null;
  }

  void _abrirListaClientes() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _clienteFocusNode.unfocus();
    } else {
      FocusScope.of(context).requestFocus(_clienteFocusNode);
      _mostrarOverlay();
    }
  }

  void _abrirListaAgendas() {
    if (_overlayAgenda != null) {
      _overlayAgenda?.remove();
      _overlayAgenda = null;
      _agendaFocusNode.unfocus();
    } else {
      _agendaFocusNode.requestFocus();
      _mostrarAgendaOverlay();
    }
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      if (_clienteSelecionado == null || _agendaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um cliente e uma agenda')),
        );
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
        nomeCliente: _clienteSelecionado!.nome,
      );

      final id = await DatabaseService().inserirAtendimento(novoAtendimento);

      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atendimento salvo com sucesso')),
        );
        Navigator.pop(context, novoAtendimento);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar atendimento')),
        );
      }
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _agendaController.dispose();
    _descricaoController.dispose();
    _valorPagoController.dispose();
    _clienteFocusNode.dispose();
    _agendaFocusNode.dispose();
    _removeOverlay();
    _removeAgendaOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Adicionar Atendimento", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const CircleAvatar(
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
          child: ListView(
            children: [
              // Campo Cliente
              DropdownSearch<Cliente>(
                items: _clientes,
                itemAsString: (Cliente c) => c.nome,
                selectedItem: _clienteSelecionado,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Cliente",
                  ),
                ),
                onChanged: (Cliente? cliente) {
                  setState(() {
                    _clienteSelecionado = cliente;
                    _clienteController.text = cliente?.nome ?? '';
                  });
                  _carregarAgendas();
                },
                enabled: _clientes.isNotEmpty,
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
                validator: (value) => value == null ? 'Selecione um cliente' : null,
              ),
              const SizedBox(height: 16),

              // Campo Agenda
              DropdownSearch<Agenda>(
                items: _agendasFiltradas,
                itemAsString: (Agenda a) => '${a.nomeCliente ?? ''} - ${a.dataHora}',
                selectedItem: _agendaSelecionada,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Agenda",
                  ),
                ),
                onChanged: (Agenda? agenda) {
                  setState(() {
                    _agendaSelecionada = agenda;
                    _agendaController.text = '${agenda?.nomeCliente ?? ''} - '
                        '${agenda != null ? DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora) : ''}';
                  });
                },
                enabled: _agendasFiltradas.isNotEmpty,
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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