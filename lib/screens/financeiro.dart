import 'package:flutter/material.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:flutter/cupertino.dart';

class RelatorioFinanceiro extends StatefulWidget {
  const RelatorioFinanceiro({Key? key}) : super(key: key);

  @override
  State<RelatorioFinanceiro> createState() => _RelatorioFinanceiroState();
}

class _RelatorioFinanceiroState extends State<RelatorioFinanceiro> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _pagamentosMensais = [];
  List<Map<String, dynamic>> _saques = [];

  late String _mesSelecionado;
  late String _anoSelecionado;

  final List<String> meses = [
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12'
  ];

  late final List<String> anos;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesSelecionado = meses[agora.month - 1];
    final anoAtual = agora.year;
    anos = List.generate(6, (index) => (anoAtual - index).toString());
    _anoSelecionado = anos.first;
    _carregarDados(mes: _mesSelecionado, ano: _anoSelecionado);
  }

  Future<void> _carregarDados({String? mes, String? ano}) async {
    List<Map<String, dynamic>> pagamentos;
    if (mes != null && ano != null) {
      pagamentos = await _dbService.totalPagamentosPorMesFiltrado(mes, ano);
    } else {
      pagamentos = await _dbService.totalPagamentosPorMes();
    }

    final saques = await _dbService.listarSaques();

    setState(() {
      _pagamentosMensais = pagamentos;
      _saques = saques;
    });
  }

  double get totalRecebido =>
      _pagamentosMensais.fold(0.0, (soma, item) => soma + (item['total'] as double));
  double get totalSaques =>
      _saques.fold(0.0, (soma, saque) => soma + (saque['valor'] as double));
  double get saldoAtual => totalRecebido - totalSaques;

  void _aplicarFiltro() {
    _carregarDados(mes: _mesSelecionado, ano: _anoSelecionado);
  }

  void _abrirDialogSaque() {
    final valorController = TextEditingController();
    final observacaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Saque'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
              ),
            ),
            TextField(
              controller: observacaoController,
              decoration: const InputDecoration(labelText: 'Observação'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final valor = double.tryParse(valorController.text.replaceAll(',', '.'));
              final observacao = observacaoController.text;

              if (valor != null && valor > 0) {
                await DatabaseService().registrarSaque(
                  valor: valor,
                  observacao: observacao,
                  data: DateTime.now(),
                );
                Navigator.pop(context);
                await _carregarDados();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saque registrado com sucesso')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe um valor válido')),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Financeiro R\$", style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar por mês/ano',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Mês'),
                      SizedBox(
                        height: 100,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: meses.indexOf(_mesSelecionado),
                          ),
                          itemExtent: 32.0,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _mesSelecionado = meses[index];
                            });
                          },
                          children: meses.map((m) => Text(m)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Ano'),
                      SizedBox(
                        height: 100,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: anos.indexOf(_anoSelecionado),
                          ),
                          itemExtent: 32.0,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _anoSelecionado = anos[index];
                            });
                          },
                          children: anos.map((a) => Text(a)).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _aplicarFiltro,
                  child: const Text('Aplicar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Total de Pagamentos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_pagamentosMensais.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Nenhum pagamento encontrado para o filtro selecionado.'),
              ),
            ..._pagamentosMensais.map((item) => ListTile(
                  title: Text(item['mes']),
                  trailing: Text('R\$ ${item['total'].toStringAsFixed(2)}'),
                )),
            const SizedBox(height: 20),
            const Divider(),
            const Text('Histórico de Saques',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._saques.map((saque) => ListTile(
                  leading: const Icon(Icons.money_off),
                  title: Text('R\$ ${saque['valor'].toStringAsFixed(2)}'),
                  subtitle: Text('${saque['data']} - ${saque['observacao'] ?? ''}'),
                )),
            const SizedBox(height: 20),
            const Divider(),
            Text('Total recebido: R\$ ${totalRecebido.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Total sacado: R\$ ${totalSaques.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Saldo atual: R\$ ${saldoAtual.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green)),
          ],
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
              heroTag: "home",
              backgroundColor: Colors.purple,
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Icon(Icons.home),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "sacar_valor",
              backgroundColor: const Color.fromARGB(255, 25, 148, 29),
              onPressed: _abrirDialogSaque, // Função que abre o diálogo de saque
              child: const Icon(Icons.monetization_on),
              tooltip: "Sacar R\$",
            ),
          ],
        ),
      ),

    );
  }
}