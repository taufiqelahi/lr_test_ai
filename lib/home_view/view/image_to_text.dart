import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ImageToText extends StatefulWidget {
  const ImageToText({super.key});

  @override
  State<ImageToText> createState() => _ImageToTextState();
}

class _ImageToTextState extends State<ImageToText> {
  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  final TextEditingController controller = TextEditingController();
  String savedText = ""; // This will store the saved text

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    String text = await getImageToText(image.path);
                    setState(() {
                      controller.text = text; // Put recognized text into the controller
                      selectedImage = File(image.path);
                    });
                  }
                },
                child: Container(
                  height: 250,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                   // border: Border.all(color: Colors.black),
                    //color: Colors.grey[300],
                  ),
                  child: selectedImage != null
                      ? Image.file(selectedImage!)
                      : const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Edit the text here',
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    savedText = controller.text; // Save the controller text
                  });
                },
                child: const Text("Save"),
              ),

              const SizedBox(height: 20),
              if (savedText.isNotEmpty)
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        selectedImage != null
                            ? Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(right: 15),
                          child: Image.file(selectedImage!),
                        )
                            : Container(
                          height: 100,
                          width: 100,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: savedText
                                .split("\n")
                                .map((line) => Text(
                              line,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getImageToText(final imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
    await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
    return recognizedText.text;
  }
}
