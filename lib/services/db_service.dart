import 'package:sqflite/sqflite.dart';
import 'package:oxf_client/models/cliente.dart';
import 'package:oxf_client/models/agenda.dart';
import 'package:oxf_client/models/atendimento.dart';
import 'package:oxf_client/services/db_create.dart';

class DatabaseService {
  final DatabaseCreate _dbHelper = DatabaseCreate();

  Future<List<Cliente>> listarClientes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> resultado = await db.query('clientes');

    return resultado.map((map) => Cliente.fromMap(map)).toList();
  }

  Future<int> inserirCliente(Cliente cliente) async {
    final db = await _dbHelper.database;
    return await db.insert('clientes', cliente.toMap());
  }

  /*Future<List<Agenda>> listarAgendas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> resultado = await db.query('agenda');
    return resultado.map((map) => Agenda.fromMap(map)).toList();
  }*/

  Future<List<Agenda>> listarAgendas() async {
  final db = await _dbHelper.database;

  final List<Map<String, dynamic>> resultado = await db.rawQuery('''
      SELECT 
        agenda.id,
        agenda.cliente_id,
        agenda.data_hora,
        agenda.observacoes,
        clientes.nome AS nome_cliente
      FROM agenda
      JOIN clientes ON agenda.cliente_id = clientes.id
      ORDER BY agenda.data_hora
    ''');

    return resultado.map((map) => Agenda.fromMap(map)).toList();
  }

  Future<int> deletarAgenda(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('agenda', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> inserirAgenda(Agenda agenda) async {
    final db = await _dbHelper.database;
    return await db.insert('agenda', agenda.toMap());
  }

  // Atualizar agenda existente
  Future<int> atualizarAgenda(Agenda agenda) async {
    final db = await _dbHelper.database;
    return await db.update(
      'agenda',
      agenda.toMap(),
      where: 'id = ?',
      whereArgs: [agenda.id],
    );
  }

    // Inserir um novo atendimento no banco
    Future<int> inserirAtendimento(Atendimento atendimento) async {
      final db = await _dbHelper.database;

      return await db.insert('atendimentos', {
        'cliente_id': atendimento.clienteId,
        'agenda_id': atendimento.agendaId,
        'data_hora_inicio': atendimento.dataHoraInicio.toIso8601String(),
        'compareceu': atendimento.compareceu ? 1 : 0,
        'pagou': atendimento.pagou ? 1 : 0,
        'valor_pago': atendimento.valorPago,
        'data_hora_fim': atendimento.dataHoraFim?.toIso8601String(),
        'descricao': atendimento.descricao,
        'realizado': atendimento.realizado ? 1 : 0,
      });
    }

  Future<int> atualizarAtendimento(Atendimento atendimento) async {
    final db = await _dbHelper.database;

    return await db.update(
      'atendimentos',
      {
        'cliente_id': atendimento.clienteId,
        'agenda_id': atendimento.agendaId,
        'data_hora_inicio': atendimento.dataHoraInicio.toIso8601String(),
        'compareceu': atendimento.compareceu ? 1 : 0,
        'pagou': atendimento.pagou ? 1 : 0,
        'valor_pago': atendimento.valorPago,
        'data_hora_fim': atendimento.dataHoraFim?.toIso8601String(),
        'descricao': atendimento.descricao,
        'realizado': atendimento.realizado ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [atendimento.id],
    );
  }

  Future<void> deletarAtendimento(int id) async {
    final db = await _dbHelper.database;
    await db.delete('atendimentos', where: 'id = ?', whereArgs: [id]);
  }

  // Listar apenas atendimentos realizados
  Future<List<Atendimento>> listarAtendimentosRealizados() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> resultado = await db.rawQuery('''
      SELECT 
        atendimentos.id,
        atendimentos.cliente_id,
        atendimentos.agenda_id,
        atendimentos.data_hora_inicio,
        atendimentos.compareceu,
        atendimentos.pagou,
        atendimentos.valor_pago,
        atendimentos.data_hora_fim,
        atendimentos.descricao,
        atendimentos.realizado,
        clientes.nome AS nome_cliente
      FROM atendimentos
      JOIN clientes ON atendimentos.cliente_id = clientes.id
      ORDER BY atendimentos.data_hora_inicio
    ''');

    // Mapear os resultados para a lista de objetos Atendimento
    return resultado.map((map) {
      return Atendimento.fromMap(map);
    }).toList();
  }

  Future<int> atualizarCliente(Cliente cliente) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deletarCliente(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

/*
  Future<List<Atendimento>> listarAtendimentosRealizados() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        a.id, 
        a.cliente_id, 
        a.agenda_id, 
        a.data_hora_inicio, 
        a.compareceu, 
        a.pagou, 
        a.valor_pago, 
        a.data_hora_fim, 
        a.descricao, 
        a.realizado,
        c.nome AS nome_cliente
      FROM atendimentos a
      INNER JOIN clientes c ON a.cliente_id = c.id
      WHERE a.realizado = 1
      ORDER BY a.data_hora_inicio DESC
    ''');

    return List.generate(maps.length, (i) {
      return Atendimento.fromMap(maps[i]);
    });
  }
*/

}
