import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String databaseName = 'parkeer.db';

  static Database? _database;

  Future<void> initialize() async {
    await database;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Mengembalikan path file database tanpa harus membuka koneksinya.
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, databaseName);
  }

  /// Menutup koneksi database yang sedang aktif (jika ada).
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = join(directory.path, databaseName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicle_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE parking_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        vehicle_type_code TEXT NOT NULL,
        calculation_type TEXT NOT NULL,
        minimum_charge REAL DEFAULT 0,
        maximum_daily_charge REAL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(vehicle_type_code)
          REFERENCES vehicle_types(code)
      )
    ''');

    await db.execute('''
      CREATE TABLE parking_rate_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parking_rate_id INTEGER NOT NULL,
        from_minute INTEGER NOT NULL,
        to_minute INTEGER,
        price REAL DEFAULT 0,
        FOREIGN KEY(parking_rate_id)
          REFERENCES parking_rates(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE parking_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_number TEXT NOT NULL UNIQUE,
        plate_number TEXT NOT NULL,
        vehicle_type_code TEXT NOT NULL,
        entry_time TEXT NOT NULL,
        exit_time TEXT,
        minimum_charge REAL DEFAULT 0,
        maximum_daily_charge REAL,
        total_fee REAL DEFAULT 0,
        status TEXT NOT NULL,
        FOREIGN KEY(vehicle_type_code)
          REFERENCES vehicle_types(code)
      )
    ''');

    await db.execute('''
      CREATE TABLE parking_transaction_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parking_transaction_id INTEGER NOT NULL,
        from_minute INTEGER NOT NULL,
        to_minute INTEGER,
        price REAL DEFAULT 0,
        FOREIGN KEY(parking_transaction_id)
          REFERENCES parking_transactions(id)
          ON DELETE CASCADE
      )
    ''');

    // Indexing untuk pencarian
    await db.execute(
      'CREATE INDEX idx_ticket_number ON parking_transactions(ticket_number)',
    );
    await db.execute(
      'CREATE INDEX idx_plate_number ON parking_transactions(plate_number)',
    );
    await db.execute(
      'CREATE INDEX idx_vehicle_type_code ON parking_transactions(vehicle_type_code)',
    );

    // Insert data awal
    await db.insert('vehicle_types', {'code': 'MOTOR', 'name': 'Motor'});
    await db.insert('vehicle_types', {'code': 'CAR', 'name': 'Mobil'});

    final motorRateId = await db.insert('parking_rates', {
      'name': 'Motor Progressive',
      'vehicle_type_code': 'MOTOR',
      'calculation_type': 'PROGRESSIVE',
      'minimum_charge': 5000,
      'maximum_daily_charge': 20000,
    });
    await db.insert('parking_rate_details', {
      'parking_rate_id': motorRateId,
      'from_minute': 0,
      'to_minute': 60,
      'price': 5000,
    });
    await db.insert('parking_rate_details', {
      'parking_rate_id': motorRateId,
      'from_minute': 61,
      'to_minute': 120,
      'price': 2000,
    });
    await db.insert('parking_rate_details', {
      'parking_rate_id': motorRateId,
      'from_minute': 121,
      'to_minute': 180,
      'price': 2000,
    });
    await db.insert('parking_rate_details', {
      'parking_rate_id': motorRateId,
      'from_minute': 181,
      'to_minute': null,
      'price': 2000,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Jalankan migration jika versi database berubah
  }
}
