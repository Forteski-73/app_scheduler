import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  final DatabaseService _dbService = DatabaseService();
  Map<DateTime, List<Agenda>> _eventos = {};
  DateTime _diaSelecionado = DateTime.now();
  List<Agenda> _agendasDoDia = [];
  Key _calendarKey = UniqueKey();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarScope],
  );

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    final agendas = await _dbService.listarAgendas();

    final Map<DateTime, List<Agenda>> eventos = {};
    for (var agenda in agendas) {
      final data = DateTime(agenda.dataHora.year, agenda.dataHora.month, agenda.dataHora.day);
      eventos.putIfAbsent(data, () => []).add(agenda);
    }

    setState(() {
      _eventos = eventos;
      _calendarKey = UniqueKey();
      _agendasDoDia = _obterEventos(_diaSelecionado);
    });
  }

  List<Agenda> _obterEventos(DateTime dia) {
    final diaSemHora = DateTime(dia.year, dia.month, dia.day);
    return _eventos[diaSemHora] ?? [];
  }

  Future<void> _adicionarEventoNoGoogleCalendar(Agenda agenda) async {
    try {
      final account = await _googleSignIn.signIn();
      final authHeaders = await account?.authHeaders;

      if (authHeaders == null) {
        throw Exception('Erro ao obter os cabeçalhos de autenticação');
      }

      final client = auth.authenticatedClient(
        http.Client(),
        auth.AccessCredentials(
          auth.AccessToken(
            'Bearer',
            authHeaders['Authorization']!.split(' ').last,
            DateTime.now().add(Duration(hours: 1)),
          ),
          null,
          [cal.CalendarApi.calendarScope],
        ),
      );

      final calendar = cal.CalendarApi(client);

      final evento = cal.Event()
        ..summary = 'Agenda com ${agenda.nomeCliente ?? 'Cliente'}'
        ..description = 'Criado via App Agenda'
        ..start = cal.EventDateTime(dateTime: agenda.dataHora.toUtc(), timeZone: "UTC")
        ..end = cal.EventDateTime(dateTime: agenda.dataHora.add(Duration(hours: 1)).toUtc(), timeZone: "UTC");

      await calendar.events.insert(evento, "primary");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento salvo no Google Calendar')),
      );
    } catch (e) {
      print("Erro ao adicionar no Google Calendar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar no Google Calendar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendário de Agendas"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<Agenda>(
            locale: 'pt_BR',
            key: _calendarKey,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _diaSelecionado,
            eventLoader: _obterEventos,
            selectedDayPredicate: (day) => isSameDay(day, _diaSelecionado),
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _diaSelecionado = selectedDay;
                _agendasDoDia = _obterEventos(selectedDay);
              });

              final resultado = await Navigator.pushNamed(
                context,
                _agendasDoDia.isEmpty ? '/agenda_adicionar' : '/agendas_filtrado',
                arguments: selectedDay,
              );

              if (resultado is Agenda) {
                await _adicionarEventoNoGoogleCalendar(resultado);
              }

              await _carregarEventos();
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _agendasDoDia.isEmpty
                ? const Center(child: Text("Nenhuma agenda neste dia"))
                : ListView.builder(
                    itemCount: _agendasDoDia.length,
                    itemBuilder: (context, index) {
                      final agenda = _agendasDoDia[index];
                      return ListTile(
                        title: Text("Cliente: ${agenda.nomeCliente ?? 'Sem nome'}"),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/services/db_service.dart';
import 'package:intl/intl.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key});

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  final DatabaseService _dbService = DatabaseService();
  Map<DateTime, List<Agenda>> _eventos = {};
  DateTime _diaSelecionado = DateTime.now();
  List<Agenda> _agendasDoDia = [];
  Key _calendarKey = UniqueKey(); // Adicionado para forçar rebuild

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    final agendas = await _dbService.listarAgendas();

    final Map<DateTime, List<Agenda>> eventos = {};

    for (var agenda in agendas) {
      final data = DateTime(agenda.dataHora.year, agenda.dataHora.month, agenda.dataHora.day);
      eventos.putIfAbsent(data, () => []).add(agenda);
    }

    setState(() {
      _eventos = eventos;
      _calendarKey = UniqueKey(); // Força rebuild do calendário
      _agendasDoDia = _obterEventos(_diaSelecionado);
    });
  }

  List<Agenda> _obterEventos(DateTime dia) {
    final diaSemHora = DateTime(dia.year, dia.month, dia.day);
    return _eventos[diaSemHora] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendário de Agendas"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<Agenda>(
            locale: 'pt_BR',
            key: _calendarKey, // chave dinâmica para forçar rebuild
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _diaSelecionado,
            eventLoader: _obterEventos,
            selectedDayPredicate: (day) => isSameDay(day, _diaSelecionado),
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _diaSelecionado = selectedDay;
                _agendasDoDia = _obterEventos(selectedDay);
              });

              if (_agendasDoDia.isEmpty) {
                await Navigator.pushNamed(
                  context,
                  '/agenda_adicionar',
                  arguments: selectedDay,
                );
              } else {
                await Navigator.pushNamed(
                  context,
                  '/agendas_filtrado',
                  arguments: selectedDay,
                );
              }

              await _carregarEventos(); // recarrega e atualiza visualmente
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.greenAccent, // cor da bolinha verde
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _agendasDoDia.isEmpty
                ? const Center(child: Text("Nenhuma agenda neste dia"))
                : ListView.builder(
                    itemCount: _agendasDoDia.length,
                    itemBuilder: (context, index) {
                      final agenda = _agendasDoDia[index];
                      return ListTile(
                        title: Text("Cliente: ${agenda.nomeCliente ?? 'Sem nome'}"),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(agenda.dataHora),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
*/