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
  String s="";
  final TextEditingController controller=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white60,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 250,
                  width: 250,
                  child: Center(
                    child: GestureDetector(
                        onTap: () async {
                          final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                          String a = await getImageTotext(image!.path);
                          setState(() {
                            s = a;
                            print(s);
                            controller.text=a;
                          });
                        },
                        child: const Icon(
                          Icons.file_copy,
                        )),
                  ),
                ),
                Text(
                  s,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                TextField(
                  controller: controller,
                  maxLines: 10,
                ),
                ElevatedButton(onPressed: (){}, child: Text("Save"));
              ],
            ),
          ),
        ));
  }
}
Future getImageTotext(final imagePath) async {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final RecognizedText recognizedText =
  await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
  String text = recognizedText.text.toString();
  return text;
}