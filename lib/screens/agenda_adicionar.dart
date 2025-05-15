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

  // Novos campos para cliente com pesquisa
  final LayerLink _layerLink = LayerLink();
  final FocusNode _clienteFocusNode = FocusNode();
  final TextEditingController _clienteController = TextEditingController();
  OverlayEntry? _overlayEntry;

  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  Cliente? _clienteSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarClientes();

    // Atualizar lista quando campo cliente ganhar foco
    _clienteFocusNode.addListener(() {
      if (_clienteFocusNode.hasFocus) {
        _filtrarClientes(_clienteController.text);
      } else {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  Future<void> _carregarClientes() async {
    final clientes = await _dbService.listarClientes();
    setState(() {
      _clientes = clientes;
      _clientesFiltrados = clientes;
    });
  }

  @override
  void dispose() {
    _dataController.dispose();
    _horaController.dispose();
    _observacoesController.dispose();
    _clienteController.dispose();
    _clienteFocusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _filtrarClientes(String query) {
    _clientesFiltrados = _clientes
        .where((c) => c.nome.toLowerCase().contains(query.toLowerCase()))
        .toList();

    _mostrarOverlay();
  }

  void _mostrarOverlay() {
    _overlayEntry?.remove();

    if (_clientesFiltrados.isEmpty || !_clienteFocusNode.hasFocus) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final tamanhoCampo = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: tamanhoCampo.width - 32, // Considera padding do ListView
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(16, 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              padding: EdgeInsets.zero,
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
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                      _clienteFocusNode.unfocus();
                    });
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

  void _abrirListaClientes() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _clienteFocusNode.unfocus();
    } else {
      FocusScope.of(context).requestFocus(_clienteFocusNode);
      _filtrarClientes('');
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
      appBar: AppBar(
        title: const Text(
          "Adicionar Agenda",
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
              CompositedTransformTarget(
                link: _layerLink,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clienteController,
                        focusNode: _clienteFocusNode,
                        decoration: const InputDecoration(labelText: 'Cliente'),
                        onChanged: _filtrarClientes,
                        validator: (value) =>
                            _clienteSelecionado == null ? 'Selecione um cliente' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: _abrirListaClientes,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.purple,
                  ),
                ),
                readOnly: true,
                onTap: _selecionarData,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a data' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  suffixIcon: Icon(
                    Icons.access_time,
                    color: Colors.purple,
                  ),
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
                    final formattedTime =
                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    _horaController.text = formattedTime;
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a hora' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}