import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pytorch_lite/pigeon.dart';
import 'dart:math' as math;

const TORCHVISION_NORM_MEAN_RGB = [0.485, 0.456, 0.406];
const TORCHVISION_NORM_STD_RGB = [0.229, 0.224, 0.225];

class PytorchLite {
  //Sets pytorch model path and returns Model
  static Future<ClassificationModel> loadClassificationModel(
      String path, int imageWidth, int imageHeight,
      {String? labelPath}) async {
    String absPathModelPath = await _getAbsolutePath(path);
    int index = await ModelApi()
        .loadModel(absPathModelPath, null, imageWidth, imageHeight, null);
    List<String> labels = [];
    if (labelPath != null) {
      if (labelPath.endsWith(".txt")) {
        labels = await _getLabelsTxt(labelPath);
      } else {
        labels = await _getLabelsCsv(labelPath);
      }
    }

    return ClassificationModel(index, labels, imageWidth, imageHeight);
  }

  static Future<String> _getAbsolutePath(String path) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String dirPath = join(dir.path, path);
    ByteData data = await rootBundle.load(path);
    //copy asset to documents directory
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    //create non existant directories
    List split = path.split("/");
    String nextDir = "";
    for (int i = 0; i < split.length; i++) {
      if (i != split.length - 1) {
        nextDir += split[i];
        await Directory(join(dir.path, nextDir)).create();
        nextDir += "/";
      }
    }
    await File(dirPath).writeAsBytes(bytes);

    return dirPath;
  }
}

///get labels in csv format
///labels are separated by commas
Future<List<String>> _getLabelsCsv(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split(",");
}

///get labels in txt format
///each line is a label
Future<List<String>> _getLabelsTxt(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split("\n");
}

class ClassificationModel {
  final int _index;
  final List<String> labels;
  final int imageWidth;
  final int imageHeight;
  ClassificationModel(
      this._index, this.labels, this.imageWidth, this.imageHeight);

  ///predicts image and returns the supposed label belonging to it
  Future<String> getImagePrediction(Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);

    double maxScore = double.negativeInfinity;
    int maxScoreIndex = -1;
    for (int i = 0; i < prediction.length; i++) {
      if (prediction[i]! > maxScore) {
        maxScore = prediction[i]!;
        maxScoreIndex = i;
      }
    }

    return labels[maxScoreIndex];
  }

  Future<Map<String, dynamic>> getImagePredictionResult(Uint8List imageAsBytes,
      {List<double> mean = TORCHVISION_NORM_MEAN_RGB,
      List<double> std = TORCHVISION_NORM_STD_RGB}) async {
    // Assert mean std
    assert(mean.length == 3, "mean should have size of 3");
    assert(std.length == 3, "std should have size of 3");

    final List<double?> prediction = await ModelApi().getImagePredictionList(
        _index, imageAsBytes, null, null, null, mean, std);

    // Get the index of the max score
    int maxScoreIndex = 0;
    for (int i = 1; i < prediction.length; i++) {
      if (prediction[i]! > prediction[maxScoreIndex]!) {
        maxScoreIndex = i;
      }
    }

    //Getting sum of exp
    double sumExp = 0.0;
    for (var element in prediction) {
      sumExp = sumExp + math.exp(element!);
    }

    final predictionProbabilities =
        prediction.map((element) => math.exp(element!) / sumExp).toList();

    return {
      "label": labels[maxScoreIndex],
      "probability": predictionProbabilities[maxScoreIndex]
    };
  }
}
