import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/models/municipio.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ClienteAdicionar extends StatefulWidget {
  @override
  State<ClienteAdicionar> createState() => _ClienteAdicionarState();
}

class _ClienteAdicionarState extends State<ClienteAdicionar> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController precoAtendimentoController = TextEditingController();
  final TextEditingController _cidadeManualController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  String? _ufSelecionado;
  Municipio? _cidadeSelecionada;
  String? _cidadeManual;
  List<Municipio> _municipios = [];

  final List<String> _estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'SP',
    'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'SE',
    'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'TO'
  ];

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) ##### ####',
    filter: { "#": RegExp(r'[0-9]') },
  );

  Future<void> carregarMunicipios(String uf) async {
    final url = Uri.parse('https://brasilapi.com.br/api/ibge/municipios/v1/$uf');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _municipios = data.map((json) => Municipio.fromJson(json)).toList();
        _cidadeSelecionada = null;
        _cidadeManual = null;
        _cidadeManualController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar municípios")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool semMunicipios = _municipios.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Cliente", style: TextStyle(color: Colors.white)),
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.number,
                inputFormatters: [telefoneFormatter],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "UF"),
                value: _ufSelecionado,
                isExpanded: true,
                items: _estados.map((uf) {
                  return DropdownMenuItem(value: uf, child: Text(uf));
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    _ufSelecionado = valor;
                    _municipios = [];
                    _cidadeSelecionada = null;
                    _cidadeManual = null;
                    _cidadeManualController.clear();
                  });
                  if (valor != null) {
                    carregarMunicipios(valor);
                  }
                },
              ),
              const SizedBox(height: 16),
              (_ufSelecionado != null && semMunicipios)
                  ? TextField(
                      controller: _cidadeManualController,
                      decoration: const InputDecoration(labelText: "Cidade"),
                      onChanged: (value) => _cidadeManual = value,
                      enabled: _ufSelecionado != null,
                      style: const TextStyle(color: Colors.black),
                    )
                  : DropdownSearch<Municipio>(
                      items: _municipios,
                      itemAsString: (Municipio m) => m.nome,
                      selectedItem: _cidadeSelecionada,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(labelText: "Cidade"),
                      ),
                      onChanged: (Municipio? municipio) {
                        setState(() {
                          _cidadeSelecionada = municipio;
                          _cidadeManual = null;
                          _cidadeManualController.clear();
                        });
                      },
                      enabled: _ufSelecionado != null,
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                      ),
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: precoAtendimentoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Preço do Atendimento"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () {
                          final valorAtual = double.tryParse(precoAtendimentoController.text) ?? 0.0;
                          precoAtendimentoController.text = (valorAtual + 1).toStringAsFixed(2);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          final valorAtual = double.tryParse(precoAtendimentoController.text) ?? 0.0;
                          final novoValor = (valorAtual - 1).clamp(0.0, double.infinity);
                          precoAtendimentoController.text = novoValor.toStringAsFixed(2);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final cliente = Cliente(
                      nome: nomeController.text,
                      email: emailController.text,
                      telefone: telefoneController.text,
                      cidade: _cidadeSelecionada?.nome ?? _cidadeManual,
                      uf: _ufSelecionado,
                      precoAtendimento: precoAtendimentoController.text.isNotEmpty
                          ? double.tryParse(precoAtendimentoController.text)
                          : null,
                      dataCadastro: DateTime.now(),
                    );
                    await _dbService.inserirCliente(cliente);
                    Navigator.pop(context);
                  },
                  child: const Text("Salvar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}