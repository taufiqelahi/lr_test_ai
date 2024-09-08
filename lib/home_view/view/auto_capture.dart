import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AutoCaptureScreen extends StatefulWidget {
  const AutoCaptureScreen({super.key});

  @override
  _AutoCaptureScreenState createState() => _AutoCaptureScreenState();
}

class _AutoCaptureScreenState extends State<AutoCaptureScreen> {
  CameraController? _cameraController;
  TextRecognizer? _textRecognizer;
  bool _isCapturing = false;
  bool _isTextDetected = false;
  bool _isStreamStopped = false; // Track if the image stream is stopped
  XFile? _capturedImage; // Store the captured image

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTextRecognizer();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888, // Using BGRA8888 format
    );

    await _cameraController?.initialize();
    setState(() {});

    // Start streaming frames to detect text
    _cameraController?.startImageStream(_processCameraImage);
  }

  Future<void> _initializeTextRecognizer() async {
    _textRecognizer = TextRecognizer();
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isCapturing || _isTextDetected || _isStreamStopped) return;

    try {
      final inputImage = _convertCameraImageToInputImage(cameraImage);
      final textRecognizerResult = await _textRecognizer!.processImage(inputImage);

      if (textRecognizerResult != null && textRecognizerResult.text.isNotEmpty) {
        setState(() {
          _isTextDetected = true;
        });

        // Call auto-capture method
        await _autoCaptureImage();
      }
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage cameraImage) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _autoCaptureImage() async {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_isCapturing) {
      try {
        _isCapturing = true;
        XFile imageFile = await _cameraController!.takePicture();

        setState(() {
          _capturedImage = imageFile; // Save the captured image
          _isTextDetected = false; // Reset text detected flag
          _isStreamStopped = true; // Stop further processing
        });

        // Debug print to verify image capture
      } catch (e) {
        print('Error capturing image: $e');
      } finally {
        _isCapturing = false;
        await _cameraController?.dispose(); // Dispose camera controller
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Capture Text')),
      body: Stack(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          if (_isTextDetected)
            Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: const Center(
                  child: Text('Text Detected! Auto-Capturing...'),
                ),
              ),
            ),
          if (_capturedImage != null) // Display the captured image
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(File(_capturedImage!.path)),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _capturedImage = null; // Reset captured image to continue detection
                          _isStreamStopped = false; // Reset stream status
                        });
                        // Reinitialize the camera and start the image stream
                        _initializeCamera();
                      },
                      child: const Text('Capture Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
