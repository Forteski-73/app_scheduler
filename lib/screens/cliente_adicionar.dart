import 'package:flutter/material.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/services/db_service.dart';

class ClienteAdicionar extends StatelessWidget {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Adicionar Cliente")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(labelText: "Telefone"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final cliente = Cliente(
                  nome: nomeController.text,
                  email: emailController.text,
                  telefone: telefoneController.text,
                );
                await _dbService.inserirCliente(cliente);
                Navigator.pop(context);
              },
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
