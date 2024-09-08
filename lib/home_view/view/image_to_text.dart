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
            IconButton(
                onPressed: () {
                  setState(() {
                    controller.clear();
                    selectedImage = null;
                    savedText = "";
                    extractedInfo = {};
                  });
                },
                icon: Icon(Icons.refresh))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    String text = await getImageToText(image.path);
                    setState(() {
                      controller.text = text;
                      print(text); // Put recognized text into the controller
                      selectedImage = File(image.path);
                      extractedInfo =
                          extractDetails(text); // Extract details using regex
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
                    extractedInfo = extractDetails(
                        savedText); // Re-extract details if edited
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
                                Text("n ${extractedInfo['Name']}"),
                              if (extractedInfo['Company'] != null)
                                Text("c ${extractedInfo['Company']}"),
                              if (extractedInfo['Designation'] != null)
                                Text("d ${extractedInfo['Designation']}"),
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
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Define extracted information map
    Map<String, String> extracted = {};

    // Predefined lists for designations and company identifiers
    List<String> designations = [
      "CEO",
      "Manager",
      "HR",
      "Software Developer",
      "Developer",
      "Engineer",
      "Analyst",
      "Consultant",
      "Internal Audit",
      "CTO",
      "CFO",
      "COO",
      "Product Manager",
      "Project Manager",
      "Team Lead",
      "UX/UI Designer",
      "Data Scientist",
      "Marketing Executive",
      "Sales Executive",
      "Business Analyst",
      "Operations Manager",
      "Customer Support",
      "Legal Advisor",
      "Network Administrator",
      "Database Administrator",
      "System Architect",
      "Quality Assurance",
      "Digital Marketing Specialist",
      "Scrum Master",
      "Content Writer",
      "Financial Advisor"
    ];


    List<String> companyKeywords = [
      "Limited",
      "Technologies",
      "Telecom",
      "Corporation",
      "Trust",
      "Inc.",
      "LLC",
      "Group",
      "Holdings",
      "Consulting",
      "Solutions",
      "Partners",
      "Systems",
      "Industries",
      "Enterprise",
      "Global",
      "International",
      "Ventures",
      "Associates",
      "Network",
      "Services",
      "Development",
      "Media",
      "Logistics",
      "Resources",
      "Software",
      "Finance",
      "Pharmaceuticals",
      "Energy",
      "Innovation",
      "Capital",
      "Centre"
    ];



    // Predefined list for name prefixes
    List<String> namePrefixes = ["Mr.", "Mrs.", "Ms.", "Dr.", "Md.", "Mst."];

    // Extract company name (if any line contains a company keyword)
    for (var line in lines) {
      if (companyKeywords.any(
          (keyword) => line.toLowerCase().contains(keyword.toLowerCase()))&&!line.endsWith(".com")) {
        extracted['Company'] = line;
        break; // Company name found, break out of the loop
      }
    }

    // Regular expression for identifying potential names
    final nameRegex = RegExp(
      r'^(?:Mr\.?|Mrs\.?|Ms\.?|Dr\.?|Md\.?|Mst\.?)?\s*[A-Za-z\s.]+(?:\s[A-Za-z\s.]+)*$',
      multiLine: true,
    );

    // Extract designation and skip lines identified as company names
    for (var line in lines) {
      // Skip lines that are identified as company names
      if (extracted['Company'] != null && extracted['Company'] == line) {
        continue;
      }

      // Check for designation
      if (extracted['Designation'] == null &&
          designations.any((designation) =>
              line.toLowerCase().contains(designation.toLowerCase()))) {
        extracted['Designation'] = line;
        continue;
      }
    }

    // Extract the name
    for (var line in lines) {
      // Skip lines already identified as company or designation
      if (line == extracted['Company'] || line == extracted['Designation']) {
        continue;
      }

      // Check for name using prefix and regex
      if (namePrefixes.any((prefix) =>
              line.toLowerCase().startsWith(prefix.toLowerCase())) &&
          nameRegex.hasMatch(line)) {
        extracted['Name'] = line;
        print("object$line");
        break; // Stop after finding the first valid name
      }
    }
    if(extracted['Name']==null){
      for (var line in lines) {
        // Skip lines already identified as company or designation
        if (line == extracted['Company'] || line == extracted['Designation']) {
          continue;
        }

        // Check for name using prefix and regex
        if (extracted['Name'] == null && !designations.contains(line) && !companyKeywords.any((keyword) => line.contains(keyword))) {
          if (nameRegex.hasMatch(line)) {
            extracted['Name'] = line;
            print("Match found for name without prefix: $line");
            break;  // Stop after finding the first valid name
          }
        }
      }
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
    // final nameRegex = RegExp(
    //   r'^(?:Mr\.?|Mrs\.?|Ms\.?|Dr\.?|Md\.?)?\s*[A-Za-z.]+\s*[A-Za-z\s.]+$',
    //   multiLine: true,
    // );
    //
    // final nameMatches = nameRegex.allMatches(text);
    // if (nameMatches.isNotEmpty) {
    //   List<String> matchedLines = nameMatches.map((match) => match.group(0) ?? '').toList();
    //
    //   if (matchedLines.isNotEmpty) {
    //     // Assuming the first line is the company name
    //     extracted['Company'] = matchedLines[0];
    //
    //     // If there are more than one matches, the second is assumed to be the person's name
    //     if (matchedLines.length > 1) {
    //       extracted['Name'] = matchedLines[1];
    //     }
    //
    //     // If there are more than two matches, the third is assumed to be the designation
    //     if (matchedLines.length > 2) {
    //       extracted['Designation'] = matchedLines[2];
    //     }
    //   }
    // }

    // Use a heuristic for address extraction (can be more sophisticated)
    final addressPattern = RegExp(r'[A-Za-z0-9.,\s-]+');
    extracted['Address'] = text.split('\n').lastWhere(
        (line) => addressPattern.hasMatch(line),
        orElse: () => 'Address not found');

    return extracted;
  }
}
