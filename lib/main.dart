import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Input Image',
                ),
                GestureDetector(
                  onTap: () async {
                    // showDialog(
                    //   context: context,
                    //   builder: (context) => imagePickAlert(
                    //     onCameraPressed: () async {
                    //       final imgPath = await obtainImage(ImageSource.camera);

                    //       Navigator.of(context).pop();
                    //     },
                    //     onGalleryPressed: () async {
                    //       final imgPath = await obtainImage(ImageSource.gallery);

                    //       Navigator.of(context).pop();
                    //     },
                    //   ),
                    // );
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    String conText = await getImageToText(image!.path);
                    setState(() {
                      text = conText;
                    });
                  },
                  child: const Icon(
                    Icons.add_a_photo,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  'Converted Text: $text',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 117, 90, 7), fontSize: 16),
                )
              ]),
        ),
      ),
    );
  }
}

Future getImageToText(final imagePath) async {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final RecognizedText recognizedText =
      await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
  String text = recognizedText.text.toString();
  return text;
}

// Widget imagePickAlert({
//   void Function()? onCameraPressed,
//   void Function()? onGalleryPressed,
// }) {
//   return AlertDialog(
//     title: const Text(
//       "Pick a source:",
//     ),
//     content: SingleChildScrollView(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.camera_alt),
//             title: const Text(
//               "Camera",
//             ),
//             onTap: onCameraPressed,
//           ),
//           ListTile(
//             leading: const Icon(Icons.image),
//             title: const Text(
//               "Gallery",
//             ),
//             onTap: onGalleryPressed,
//           ),
//         ],
//       ),
//     ),
//   );
// }
