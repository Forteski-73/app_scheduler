import 'package:flutter/material.dart';
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
      _agendasDoDia = _eventos[_diaSelecionado] ?? [];
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
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _diaSelecionado,
            eventLoader: _obterEventos,
            selectedDayPredicate: (day) => isSameDay(day, _diaSelecionado),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _diaSelecionado = selectedDay;
                _agendasDoDia = _obterEventos(selectedDay);
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
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