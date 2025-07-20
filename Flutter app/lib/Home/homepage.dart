import 'package:app/Home/pytorch_lite_model.dart';
import 'package:app/Welcome/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:empty_widget/empty_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ClassificationModel? _imageModel;
  String? _imagePrediction;
  String? _predictionConfidence;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Load your model
  Future loadModel() async {
    String pathImageModel = "assets/models/Model1.pt";
    try {
      _imageModel = await PytorchLite.loadClassificationModel(
          pathImageModel, 512, 512,
          labelPath: "assets/models/labels.txt");
    } on PlatformException catch (e) {
      print("PlatformException: $e");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future runClassification(ImageSource source) async {
    // Pick an image
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      // Read and resize the image
      final bytes = await File(image.path).readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      img.Image resizedImage =
          img.copyResize(originalImage!, width: 512, height: 512);

      // Convert the normalized image back to bytes
      final resizedBytes = img.encodeJpg(resizedImage);

      // Run inference
      var result = await _imageModel!.getImagePredictionResult(resizedBytes);

      setState(() {
        _imagePrediction = result['label'];
        _predictionConfidence =
            (result['probability'] * 100).toStringAsFixed(2);
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Diabetic Retinopathy Detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                heroTag: "selectImage",
                onPressed: () => runClassification(ImageSource.gallery),
                foregroundColor: Colors.cyan[800],
                child: const Icon(Icons.photo),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                heroTag: "camera",
                onPressed: () => runClassification(ImageSource.camera),
                foregroundColor: Colors.blue[900],
                child: const Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                heroTag: "signOut",
                onPressed: () => signUserOut(context),
                foregroundColor: Colors.blueGrey[700],
                child: const Icon(Icons.logout),
              ),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: _image == null
                    ? EmptyWidget(
                        image: null,
                        packageImage: PackageImage.Image_3,
                        title: 'No image',
                        subTitle: 'Select an image',
                        titleTextStyle: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 31, 33, 38),
                          fontWeight: FontWeight.w500,
                        ),
                        subtitleTextStyle: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 31, 33, 38),
                        ),
                      )
                    : Column(
                        children: [
                          Image.file(_image!),
                          const SizedBox(
                              height:
                                  8), // Add some space between image and predictions
                          Card(
                            margin: const EdgeInsets.all(8.0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline)),
                            child: SizedBox(
                              width: 300,
                              height: 80,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text("Level: $_imagePrediction",
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                    Text("Confidence: $_predictionConfidence %",
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
