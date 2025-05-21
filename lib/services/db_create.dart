import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseCreate {
  static final DatabaseCreate _instance = DatabaseCreate._internal();
  factory DatabaseCreate() => _instance;
  DatabaseCreate._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'oxf_client.db');
    return await openDatabase(
      path,
      version: 1,  // Atualizar a versão aqui caso necessário
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        telefone TEXT NOT NULL,
        cidade TEXT,
        uf TEXT,
        preco_atendimento REAL,
        data_cadastro TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute(''' 
      CREATE TABLE agenda (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        data_hora TEXT NOT NULL,
        observacao TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute(''' 
      CREATE TABLE atendimentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        agenda_id INTEGER NOT NULL,
        data_hora_inicio TEXT NOT NULL,
        compareceu INTEGER NOT NULL,
        pagou INTEGER NOT NULL,
        valor_pago REAL,
        data_hora_fim TEXT,
        descricao TEXT NOT NULL,
        realizado INTEGER NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON DELETE CASCADE ON UPDATE CASCADE  -- Chave estrangeira para 'agenda'
      )
    ''');
    
    await db.execute('''
      CREATE TABLE pagamento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        atendimento_id INTEGER NOT NULL,
        valor_cobrado REAL,
        valor_pago REAL,
        tipo_pgto TEXT CHECK (tipo_pgto IN ('Pix', 'Dinheiro', 'Cartão', 'Crédito Antecipado')),
        data TEXT,
        hora TEXT,
        observacao TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (atendimento_id) REFERENCES atendimentos(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE saldo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        saldo REAL NOT NULL DEFAULT 0.0,
        observacao TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna 'agenda_id', 'descricao' e 'realizado' se a versão for menor que 2
      await db.execute('''
        ALTER TABLE atendimentos ADD COLUMN agenda_id INTEGER NOT NULL DEFAULT 0;
      ''');

      await db.execute('''
        ALTER TABLE atendimentos ADD COLUMN descricao TEXT NOT NULL DEFAULT '';
      ''');

      await db.execute('''
        ALTER TABLE atendimentos ADD COLUMN realizado INTEGER NOT NULL DEFAULT 0;
      ''');

      // Você também pode adicionar mais alterações se precisar de migração entre versões.
    }
  }
}
