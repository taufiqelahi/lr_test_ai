import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class DisplayCapturedImage extends StatelessWidget {
  final String imagePath;

  const DisplayCapturedImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Captured Image')),
      body: Column(
        children: [
          Image.file(File(imagePath)),
          ElevatedButton(
            onPressed: () async {
              // Define custom aspect ratio for visiting card (e.g., 5:3)
              const double visitingCardAspectRatio = 5 / 3;

              CroppedFile? croppedFile = await ImageCropper().cropImage(
                sourcePath: imagePath,
                compressFormat: ImageCompressFormat.jpg,
                compressQuality: 90,
                aspectRatio: CropAspectRatio(ratioX: 5, ratioY: 3), // Custom aspect ratio
                uiSettings: [
                  AndroidUiSettings(
                    toolbarTitle: 'Cropper',
                    toolbarColor: Colors.deepOrange,
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: true,  // Lock the aspect ratio for automatic cropping
                  ),
                  IOSUiSettings(
                    title: 'Cropper',
                    aspectRatioLockEnabled: true,
                    minimumAspectRatio: visitingCardAspectRatio,
                  ),
                ],
              );

              if (croppedFile != null) {
                // Convert CroppedFile to File
                File croppedImageFile = File(croppedFile.path);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DisplayCroppedImage(croppedImagePath: croppedImageFile.path),
                  ),
                );
              }
            },
            child: Text('Crop Visiting Card'),
          ),
        ],
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
      appBar: AppBar(title: Text('Cropped Image')),
      body: Center(child: Image.file(File(croppedImagePath))),
    );
  }
}
