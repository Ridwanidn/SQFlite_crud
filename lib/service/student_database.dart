import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_crud/models/student_models.dart';

class StudentDatabase {
  static final StudentDatabase instance = StudentDatabase._init();

  static Database? _database;

  StudentDatabase._init();

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database = await _initDB('studentz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbpath = await getDatabasesPath();
    final Path = join(dbpath, filePath);

    return await openDatabase(
      Path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
     CREATE TABLE students (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       name TEXT NOT NULL,
       nisn TEXT NOT NULL,
       birthDate TEXT NOT NULL,
       photoPath TEXT
     )
   ''');
  }

  Future<void> insertStudent(Student student) async {
    final db = await getDatabase();
    await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('students');

    return List.generate(maps.length, (i) {
      return Student(
        id: maps[i]['id'],
        name: maps[i]['name'],
        nisn: maps[i]['nisn'],
        birthDate: maps[i]['birthDate'],
        photoPath: maps[i]['photoPath'],
      );
    });
  }

  Future<void> deleteStudent(int id) async {
    final db = await getDatabase();
    await db.delete(
      'Students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}