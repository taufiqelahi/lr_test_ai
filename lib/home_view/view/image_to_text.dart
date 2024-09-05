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
  String savedText = ""; // Store the saved text
  Map<String, String> extractedInfo = {}; // To store structured data

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){

              setState(() {
                controller.clear();
                selectedImage=null;
                savedText="";
                extractedInfo={};
              });
            }, icon: Icon(Icons.refresh))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    String text = await getImageToText(image.path);
                    setState(() {
                      controller.text = text;
                      print(text);// Put recognized text into the controller
                      selectedImage = File(image.path);
                      extractedInfo = extractDetails(text); // Extract details using regex
                    });
                  }
                },
                child: Container(
                  height: 250,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.grey[300],
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
                    extractedInfo = extractDetails(savedText); // Re-extract details if edited
                  });
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 20),
              if (extractedInfo.isNotEmpty)
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
                            children: [
                              if (extractedInfo['Name'] != null)
                                Text(" ${extractedInfo['Name']}"),
                              if (extractedInfo['Email'] != null)
                                Text(" ${extractedInfo['Email']}"),
                              if (extractedInfo['Mobile'] != null)
                                Text("m: ${extractedInfo['Mobile']}"),
                              if (extractedInfo['Phone'] != null)
                                Text("p: ${extractedInfo['Phone']}"),
                              if (extractedInfo['Telephone'] != null)
                                Text(" ${extractedInfo['Phone']}"),
                              if (extractedInfo['Address'] != null)
                                Text(" ${extractedInfo['Address']}"),
                            ],
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

  // Function to extract structured info using regex
  Map<String, String> extractDetails(String text) {
    final Map<String, String> extracted = {};

    // Regex for email
    final emailRegex = RegExp(r'\b[\w.%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      extracted['Email'] = emailMatch.group(0) ?? '';
    }

    // Regex for phone number (adjust based on the region)
    final phoneRegex = RegExp(
      r'(?:Phone|Mobile|Cell|Tel|Global Dial)?\s*:?(\+?\d{1,3}[\d\s\-]{7,}\d)',
      multiLine: true,
    );

    final phoneMatches = phoneRegex.allMatches(text);
    if (phoneMatches.isNotEmpty) {
      // Initialize lists to collect all phone and mobile numbers found
      List<String> phones = [];
      List<String> mobiles = [];

      for (var match in phoneMatches) {
        String number = match.group(1) ?? '';

        // Check if the number is a mobile number starting with +8801
        if (number.startsWith('+8801')) {
          mobiles.add(number);
        } else {
          phones.add(number);
        }
      }

      // Store phone and mobile numbers in the extracted map
      if (phones.isNotEmpty) extracted['Phone'] = phones.join(', ');
      if (mobiles.isNotEmpty) extracted['Mobile'] = mobiles.join(', ');
    }
    // Regex for name (you can fine-tune this for common name patterns)
    final nameRegex = RegExp(
      r'^(?:Mr\.?|Mrs\.?|Ms\.?|Dr\.?|Md\.?)?\s*[A-Za-z.]+\s*[A-Za-z\s.]+$',
      multiLine: true,
    );
    final nameMatches = nameRegex.allMatches(text);
    if (nameMatches.isNotEmpty) {
      // Collect all name matches and join them into a single string
      extracted['Name'] = nameMatches.map((match) => match.group(0) ?? '').join(', ');
    }

    // Use a heuristic for address extraction (can be more sophisticated)
    final addressPattern = RegExp(r'[A-Za-z0-9.,\s-]+');
    extracted['Address'] = text.split('\n').lastWhere(
            (line) => addressPattern.hasMatch(line),
        orElse: () => 'Address not found');

    return extracted;
  }
}
