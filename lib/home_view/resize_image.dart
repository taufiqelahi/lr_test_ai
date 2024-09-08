
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

enum TextAlignment {
  left,
  center,
  right,
}

class VisitingCardApp extends StatefulWidget {
  const VisitingCardApp({super.key});

  @override
  _VisitingCardAppState createState() => _VisitingCardAppState();
}

class _VisitingCardAppState extends State<VisitingCardApp> {
  File? _image;

  Future<void> pickAndProcessImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);  // Convert XFile to File
      final TextAlignment alignment = await detectTextAlignment(imageFile);  // Detect text alignment
      File resizedAndRotatedFile = await resizeAndRotateImage(imageFile, alignment);  // Resize and Rotate
      File compressedFile = await compressImage(resizedAndRotatedFile);  // Compress image

      setState(() {
        _image = compressedFile;
      });
    }
  }

  Future<TextAlignment> detectTextAlignment(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    // Decode the image using the `image` package to get its dimensions
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));

    if (decodedImage == null) {
      throw Exception("Failed to decode image.");
    }

    double imageWidth = decodedImage.width.toDouble();

    // Analyze recognized text to determine alignment
    List<TextBlock> blocks = recognizedText.blocks;
    if (blocks.isEmpty) return TextAlignment.center; // Default to center if no text is found

    double leftPosition = blocks.first.boundingBox.left;
    double rightPosition = blocks.last.boundingBox.right;

    if (leftPosition < 100) {
      return TextAlignment.left;  // Text is aligned to the left
    } else if (rightPosition > imageWidth - 100) {
      return TextAlignment.right;  // Text is aligned to the right
    } else {
      return TextAlignment.center;  // Text is centered
    }
  }

  Future<File> resizeAndRotateImage(File imageFile, TextAlignment alignment) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    Uint8List uint8List = Uint8List.fromList(imageBytes);
    img.Image? originalImage = img.decodeImage(uint8List);

    if (originalImage == null) {
      throw Exception("Unable to decode image.");
    }

    // Rotate based on text alignment
    int rotationAngle = 0;
    if (alignment == TextAlignment.left) {
      rotationAngle = 0; // No rotation needed
    } else if (alignment == TextAlignment.center) {
      rotationAngle = 90; // Rotate 90 degrees
    } else if (alignment == TextAlignment.right) {
      rotationAngle = 180; // Rotate 180 degrees
    }

    img.Image rotatedImage = img.copyRotate(originalImage, angle: rotationAngle);
    img.Image resizedImage = img.copyResize(rotatedImage, width: 400, height: 200);

    // Save resized and rotated image
    List<int> resizedBytes = img.encodeJpg(resizedImage);
    final Directory tempDir = await getTemporaryDirectory();
    final String resizedPath = "${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final File resizedFile = File(resizedPath)..writeAsBytesSync(Uint8List.fromList(resizedBytes));

    return resizedFile;
  }

  Future<File> compressImage(File imageFile) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath = "${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,  // Save to a different path
      quality: 80,
    );

    if (compressedXFile != null) {
      return File(compressedXFile.path);  // Convert XFile to File
    } else {
      throw Exception("Failed to compress the image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Visiting Card App")),
      body: Center(
        child: _image != null
            ? Image.file(_image!)
            : Text("No Image Selected"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndProcessImage,
        child: Icon(Icons.camera),
      ),
    );
  }
}
