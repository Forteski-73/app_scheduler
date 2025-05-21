import 'package:flutter/material.dart';
import 'package:oxf_client/screens/clientes.dart';
import 'package:oxf_client/screens/agendas.dart';
import 'package:oxf_client/screens/atendimentos.dart';
import 'package:oxf_client/screens/pagamento.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AGENDAMENTO')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Clientes'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Clientes()),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.event),
            label: const Text('Agendas'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Agendas()),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.assignment),
            label: const Text('Atendimentos'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Atendimentos()),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment, color: Colors.white, size: 28),
            label: const Text(
              'Pagamentos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Pagamentos()),
              );
            },
          ),
        ],
      ),
    );
  }
}
