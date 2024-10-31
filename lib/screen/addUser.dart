import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_crud/models/student_models.dart';
import 'package:sqflite_crud/service/student_database.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<Adduser> {

  final _nameController = TextEditingController();
  final _nisnController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _studentDb = StudentDatabase.instance;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildlabel('Nama Siswa'),
              _buildTextField(_nameController, 'Masukan Nama'),
              SizedBox(height: 20),
              _buildlabel('NISN Siswa'),
              _buildTextField(_nisnController, 'Masukan NISN'),
              SizedBox(height: 20),
              _buildlabel('Tanggal Lahir'),
              GestureDetector(
                onTap: _selecDate,
                child: _buildTextField(
                  _birthDateController, 
                  'Pilih  Tanggal Lahir', 
                  suffixIcon: Icons.calendar_today,
                ),
              ),
              SizedBox(height: 20),
              _buildPhotoUploader(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveStudent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal:40, vertical: 15
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ), 
                  child: Text('Tambah',style: TextStyle(color: Colors.white), 
                  )
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selecDate() async{
    DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('YYYY-MM-dd').format(picked);
      });
    }
  }

  // Fungsi untuk memilih gambar 
  Future<void> _pickImage() async{
    final PickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
    if (PickedFile != null) {
      setState(() {
        _imageFile = File(PickedFile.path);
      });
    }
  }

  // Fungsi untukk menyimpan data siswa
  Future<void> _saveStudent() async {
    final student = Student(
      name: _nameController.text, 
      nisn: _nisnController.text, 
      birthDate: _birthDateController.text,
      photoPath: _imageFile?.path,
    );

    await _studentDb.insertStudent(student);
    _clearFields();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Siswa Ditambahkan')),
    );
  }

  // Fungsi untuk mengosongkan field setelah simpan
  void _clearFields() {
    _nameController.clear();
    _nisnController.clear();
    _birthDateController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  // Fungsi untuk membangun label
  Widget _buildlabel(String text) {
    return Text(text, style: TextStyle(fontSize: 18));
  }

  // Fungsi untuk membangun TextField
  Widget _buildTextField(TextEditingController controller, String hintText,
      {IconData? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon !=null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  // Fungsi untuk upload foto
  Widget _buildPhotoUploader() {
    return Center(
      child: Column(
        children: [
          const Text('Unggah Foto Profil', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
              child:  _imageFile == null
                  ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                  : null,
            ),
          )
        ],
      ),
    );
  }
}