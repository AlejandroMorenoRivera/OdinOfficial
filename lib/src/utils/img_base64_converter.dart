import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImgBase64Converter {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  static Uint8List uint8ListFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Future<String> convertImagePathToBase64(String imagePath) async {
    // Leer el archivo de la ruta
    final bytes = await File(imagePath).readAsBytes();

    // Convertir los bytes a Base64
    String base64Image = base64Encode(bytes);

    return base64Image;
  }

  static Future<String> convertAssetImageToBase64(String imagePath) async {
    // Carga la imagen desde los activos de la aplicación
    ByteData imageData = await rootBundle.load(imagePath);

    // Convierte los bytes de la imagen a base64
    String base64Image = base64Encode(imageData.buffer.asUint8List());

    return base64Image;
  }
}
