import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image To Text',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Image To Text'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String text = " ";
final today = DateTime.now();
String exDate = '';
String price = '';

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Input Image from the Gallery'),
                GestureDetector(
                  onTap: () async {
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    String conText = await getImageToText(image!.path);
                    setState(() {
                      text = conText;
                      exDate = '';
                      price = '';
                      List<String> dates = extractDates(text);
                      setDatesStatus(dates);
                      getPrice(text);
                    });
                  },
                  child: const Icon(Icons.add_photo_alternate),
                ),
                const SizedBox(height: 25),
                const Text('Open Camera'),
                GestureDetector(
                  onTap: () async {
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      String conText = await getImageToText(image.path);
                      setState(() {
                        text = conText;
                        exDate = '';
                        price = '';
                        List<String> dates = extractDates(text);
                        setDatesStatus(dates);
                        getPrice(text);
                      });
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(height: 25),
                Text(
                  'Converted Text: $text',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 7, 18, 117),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 65),
                Text(
                  'Detected Dates: ${extractDates(text).join(", ")}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 7, 18, 117),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Expired Date: $exDate',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 7, 18, 117),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Price: Rs $price/=',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 7, 18, 117),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getImageToText(final imagePath) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
    String text = recognizedText.text.toString();
    return text;
  }

  List<String> extractDates(String text) {
    List<String> parsedDates = [];
    RegExp regExp = RegExp(r'(\d{4})\.(\d{2})\.(\d{2})');
    Iterable<Match> matches = regExp.allMatches(text);
    for (Match match in matches) {
      int year = int.parse(match.group(1)!);
      int month = int.parse(match.group(2)!);
      int day = int.parse(match.group(3)!);
      DateTime date = DateTime(year, month, day);
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      parsedDates.add(formattedDate);
    }
    return parsedDates;
  }

  void setDatesStatus(List<String> dates) {
    for (final date in dates) {
      final parsedDate = DateTime.parse(date);
      if (parsedDate.isAfter(today)) {
        setState(() {
          exDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        });
      }
    }
  }

  void getPrice(String text) {
    RegExp regExp =
        // RegExp(r'(?:Rs|rs|RS|LKR)[,.]?\s?(\d+(?:,\d+)*(?:\.\d+)?)[/=]');
        // RegExp(r'(?:Rs|rs|RS|LKR)[,.]?\s?(\d+(?:,\d+)*(?:\.\d+)?)');
        RegExp(r'(?:Rs|rs|RS|LKR)[,.]?\s?(\d+(?:,\d+)*(?:[.,]\d{1,2})?)');

    List<String> prices = [];
    for (Match match in regExp.allMatches(text)) {
      String price = match.group(1)!;
      if (price.contains('.') || price.contains(',')) {
        price = price.replaceAll(RegExp(r'([.,]\d*?)0{1,2}$'), r'');
      }
      prices.add(price);
    }

    setState(() {
      price = prices.isNotEmpty ? prices.join(", ") : '';
    });
  }
}
