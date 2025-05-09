import 'package:flutter/material.dart';
import 'package:oxf_client/screens/clientes.dart';
import 'package:oxf_client/screens/agendas.dart';
import 'package:oxf_client/screens/atendimentos.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OXF Client')),
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
        ],
      ),
    );
  }
}
