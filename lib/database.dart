import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // Khởi tạo dữ liệu mẫu khớp với hình ảnh thiết kế
  Future<void> seedIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM transactions'),
    );

    if (count == 0) {
      final initialData = [
        {
          'type': 'Chi tiêu',
          'category': 'Ăn uống',
          'amount': 100000.0,
          'date': '12/04/2025',
          'note': 'Ăn trưa'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Mua sắm',
          'amount': 500000.0,
          'date': '10/04/2025',
          'note': 'Mua quần áo'
        },
        {
          'type': 'Thu nhập',
          'category': 'Lương',
          'amount': 10000000.0,
          'date': '05/04/2025',
          'note': 'Lương tháng 4'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Đi lại',
          'amount': 200000.0,
          'date': '03/04/2025',
          'note': 'Đổ xăng'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Học tập',
          'amount': 300000.0,
          'date': '01/04/2025',
          'note': 'Mua sách'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Ăn uống',
          'amount': 1900000.0,
          'date': '02/04/2025',
          'note': 'Ăn uống gia đình'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Mua sắm',
          'amount': 1000000.0,
          'date': '04/04/2025',
          'note': 'Đồ gia dụng'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Đi lại',
          'amount': 500000.0,
          'date': '06/04/2025',
          'note': 'Bảo dưỡng xe'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Học tập',
          'amount': 200000.0,
          'date': '07/04/2025',
          'note': 'Khóa học online'
        },
        {
          'type': 'Chi tiêu',
          'category': 'Khác',
          'amount': 300000.0,
          'date': '08/04/2025',
          'note': 'Chi phí phát sinh'
        },
      ];

      for (var row in initialData) {
        await db.insert('transactions', row);
      }
    }
  }

  // Thêm giao dịch mới
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transactions', row);
  }

  // Lấy tất cả giao dịch, sắp xếp mới nhất lên đầu
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', orderBy: 'id DESC');
  }

  // Cập nhật giao dịch
  Future<int> updateTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'transactions',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Xóa giao dịch
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
