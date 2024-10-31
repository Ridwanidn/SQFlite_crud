import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_crud/models/student_models.dart';
import 'package:sqflite_crud/screen/addUser.dart';
import 'package:sqflite_crud/screen/edit_user.dart';
import 'package:sqflite_crud/service/student_database.dart';

class ViewUser extends StatefulWidget {
  const ViewUser({super.key});

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  final _studentDB = StudentDatabase.instance;
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _studentsFuture = _studentDB.getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Data Siswa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak Ada Siswa Ditemukan'));
          }

          final students = snapshot.data!;
          return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: student.photoPath != null
                        ? ClipOval(
                            child: Image.file(
                              File(student.photoPath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NISN: ${student.nisn}'),
                        Text('Tanggal Lahir: ${student.birthDate}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditStudent(student);
                        } else if (value == 'delete') {
                          _deletStudent(student.id!);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Adduser();
          }));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _navigateToEditStudent(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditStudentPage();
        },
      ),
    ).then((_) {
      setState(() {
        _studentsFuture = _studentDB.getStudents();
      });
    });
  }

  void _deletStudent(int id) async {
    await _studentDB.deleteStudent(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Siswa Di Hapus')),
    );
    setState(() {
      _studentsFuture = _studentDB.getStudents();
    });
  }
}