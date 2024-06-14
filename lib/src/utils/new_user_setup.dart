import 'package:flutter/material.dart';
import 'package:odin/src/models/quick_buttons_model.dart';
import 'package:odin/src/models/settings_model.dart';
import 'package:odin/src/services/firebase_store_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odin/src/utils/img_base64_converter.dart';

class NewUserSetup {
  static final FireStoreService _qaButtons = FireStoreService.quickbuttons();
  static final FireStoreService _settingsApp = FireStoreService.appSettings();

  static Future<void> loadDefaultQAButtons() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    debugPrint("Cargando QAButtons para el usuario: $uid");
    for (var i = 0; i < 6; i++) {
      await _qaButtons.addQAButton(
        QuickAccessButton(
            name: "Boton $i",
            imgBase64: await ImgBase64Converter.convertAssetImageToBase64(
                "assets/QAButtons/add.png"),
            action: 0,
            position: i,
            uid: uid),
      );
    }
  }

  static Future<void> loadDefaultSettings() {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    debugPrint("Cargando settings para el usuario: $uid");
    return _settingsApp.addAppSettings(
      uid,
      AppSettings(sortMode: false),
    );
  }
}
