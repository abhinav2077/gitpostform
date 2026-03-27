import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'api.dart';

void main() {
  runApp(const MyApp());
}

/// ROOT APP
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Post Form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Upload Files'),
    );
  }
}

/// ✅ THIS WAS MISSING (VERY IMPORTANT)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// STATE CLASS
class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _fileNameController = TextEditingController();
  PlatformFile? _selectedFile;

  Future<void> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true, // ✅ IMPORTANT for web
  );

  if (result != null) {
    setState(() {
      _selectedFile = result.files.first;
    });
  } else {
    print("User canceled");
  }
}

  Future<void> saveFile() async {
  if (_selectedFile == null || _fileNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter file name and select file")),
    );
    return;
  }

  try {
    final bytes = _selectedFile!.bytes;

    if (bytes == null) {
      throw Exception("File bytes are null");
    }

    bool success = await ApiService.uploadFile(
      fileBytes: bytes,
      fileName: _fileNameController.text,
      originalFileName: _selectedFile!.name,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploaded successfully")),
      );

      setState(() {
        _selectedFile = null;
        _fileNameController.clear();
      });
    } else {
      throw Exception("Upload failed");
    }

  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error uploading file")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: "File Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
  onPressed: () async {
    print("Clicked"); // debug
    await pickFile(); // 👈 direct awaited call
  },
  child: const Text("Select File"),
),

            const SizedBox(height: 10),

            if (_selectedFile != null)
              Text("Selected: ${_selectedFile!.name}"),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveFile,
              child: const Text("Save File"),
            ),
          ],
        ),
      ),
    );
  }
}