import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:odin/src/services/firebase_store_service.dart';
import 'package:odin/src/utils/new_user_setup.dart';

class DeleteAccountAlert extends StatefulWidget {
  const DeleteAccountAlert({super.key});

  @override
  State<DeleteAccountAlert> createState() => _DeleteAccountAlertState();
}

class _DeleteAccountAlertState extends State<DeleteAccountAlert> {
  User? user = FirebaseAuth.instance.currentUser;
  FireStoreService appSettingsService = FireStoreService.appSettings();
  FireStoreService notesService = FireStoreService.notes();
  FireStoreService quickbuttonsService = FireStoreService.quickbuttons();

  // datos // = _user?.email;
  late bool isAnonymous; // = _user?.isAnonymous ?? true;

  // variables
  Timer? _timer;
  bool _isButtonEnabled = false;
  late int _counter;

  @override
  void initState() {
    isAnonymous = user?.isAnonymous ?? true;
    super.initState();
    _counter = 5;
    _timer?.cancel();
    // contador para habilitar el boton
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _isButtonEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Eliminar datos"),
      content: const Text(
        "Cuidado, esta acción NO puede deshacerse",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: _isButtonEnabled
              ? () async {
                  // borramos los datos
                  await notesService.deleteAllNotes();
                  await appSettingsService.deleteAppSettings(uid: user!.uid);
                  await quickbuttonsService.deleteAllQAButtons();
                  // cargamos los por defecto
                  await NewUserSetup.loadDefaultQAButtons();
                  await NewUserSetup.loadDefaultSettings();
                  // borramos/cerramos el usuario
                  if (isAnonymous) {
                    await user!.delete();
                  } else {
                    // !No puedo eliminar una cuenta sin una autenticacion reciente del usuario
                    // await user.delete();
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                  }

                  // Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, "/login");

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Datos eliminados correctamente")));
                }
              : null,
          style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(
                _isButtonEnabled
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onError,
              ),
              backgroundColor: WidgetStateProperty.all(_isButtonEnabled
                  ? Theme.of(context).buttonTheme.colorScheme!.errorContainer
                  : Theme.of(context).colorScheme.onErrorContainer)),
          child: Text("Eliminar datos ${_isButtonEnabled ? "" : _counter}"),
        )
      ],
    );
  }
}
