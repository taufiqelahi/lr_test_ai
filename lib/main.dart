import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _scannedPicturePath;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Document Scanner App'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: onPressed,
                child: const Text("Scan Picture"),
              ),
              if (_scannedPicturePath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Scanned Picture Path: $_scannedPicturePath'),
                      Image.file(File(_scannedPicturePath!)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressed() async {
    try {
      // Get a single scanned picture
      List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];

      // We assume you're scanning just one picture, so take the first one
      if (pictures.isNotEmpty) {
        setState(() {
          _scannedPicturePath = pictures.first;
        });
      }
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $exception')),
      );
    }
  }
}
