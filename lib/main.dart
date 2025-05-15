import 'package:flutter/material.dart';

// Screens
import 'package:oxf_client/screens/clientes.dart';
import 'package:oxf_client/screens/agendas.dart';
import 'package:oxf_client/screens/atendimentos.dart';
import 'package:oxf_client/screens/cliente_adicionar.dart';
import 'package:oxf_client/screens/cliente_editar.dart';
import 'package:oxf_client/screens/agenda_adicionar.dart';
import 'package:oxf_client/screens/agenda_editar.dart';
import 'package:oxf_client/screens/atendimento_editar.dart';
import 'package:oxf_client/screens/atendimento_adicionar.dart';

// Models
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/models/atendimento.dart';

import 'package:flutter_localizations/flutter_localizations.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oxford Atendimento',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.purple,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.purple),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.purple),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.purple),
          titleLarge: TextStyle(color: Colors.purple, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.purple),
          labelStyle: const TextStyle(color: Colors.purple),
        ),
      ),
      home: const Home(),
      routes: {
        '/cliente_adicionar': (context) => ClienteAdicionar(),
        '/agenda_adicionar': (context) => AgendaAdicionar(),
        '/atendimento_adicionar': (context) => AtendimentoAdicionar(), // <-- ROTA ADICIONADA
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/cliente_editar') {
          final cliente = settings.arguments as Cliente;
          return MaterialPageRoute(
            builder: (context) => ClienteEditar(cliente: cliente),
          );
        }

        if (settings.name == '/agenda_editar') {
          final agenda = settings.arguments as Agenda;
          return MaterialPageRoute(
            builder: (context) => AgendaEditar(agenda: agenda),
          );
        }

        if (settings.name == '/atendimento_editar') {
          final atendimento = settings.arguments as Atendimento;
          return MaterialPageRoute(
            builder: (context) => AtendimentoEditar(atendimento: atendimento),
          );
        }

        return null;
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AGENDAMENTO",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Imagem de background que cobre toda a área
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  'assets/background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                ),
              ],
            ),
          ),
          // Conteúdo com padding e scroll
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.person, color: Colors.white, size: 28),
                label: const Text(
                  'Clientes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Clientes()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.event, color: Colors.white, size: 28),
                label: const Text(
                  'Agendas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Agendas()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment, color: Colors.white, size: 28),
                label: const Text(
                  'Atendimentos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Atendimentos()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 40,
        alignment: Alignment.center,
        color: Colors.purple[100],
        child: const Text(
          'Versão 1.0.0',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}