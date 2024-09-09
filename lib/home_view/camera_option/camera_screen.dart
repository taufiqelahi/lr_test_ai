import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0], // Use the first camera (usually the rear camera)
        ResolutionPreset.high,
      );

      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> captureAndCropCard() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Visiting Card')),
      body: _isCameraInitialized
          ? Center(
            child: CameraPreview(_cameraController!),
          )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          if (_cameraController == null || !_cameraController!.value.isInitialized) {
            return;
          }

          try {
            // Capture the image
            final XFile imageFile = await _cameraController!.takePicture();

            // Crop the image automatically to the visiting card size (5:3 ratio)
            CroppedFile? croppedFile = await ImageCropper().cropImage(
              sourcePath: imageFile.path,
              aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3), // Custom aspect ratio for visiting card
              compressFormat: ImageCompressFormat.jpg,
              compressQuality: 90,
              uiSettings: [
                AndroidUiSettings(
                  toolbarTitle: 'Cropper',
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: true,  // Lock the aspect ratio
                ),
                IOSUiSettings(
                  title: 'Cropper',
                  aspectRatioLockEnabled: true,
                  minimumAspectRatio: 5 / 3,
                ),
              ],
            );

            if (croppedFile != null) {
              // Proceed with the cropped image
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayCroppedImage(croppedImagePath: croppedFile.path),
                ),
              );
            }
          } catch (e) {
            print('Error capturing or cropping image: $e');
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class DisplayCroppedImage extends StatelessWidget {
  final String croppedImagePath;

  const DisplayCroppedImage({Key? key, required this.croppedImagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cropped Image')),
      body: Center(child: Image.file(File(croppedImagePath))),
    );
  }
}
