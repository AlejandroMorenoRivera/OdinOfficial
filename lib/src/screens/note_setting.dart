import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odin/src/models/settings_model.dart';
import 'package:odin/src/services/firebase_store_service.dart';

class NoteSettingsLayout extends StatefulWidget {
  const NoteSettingsLayout({super.key});

  @override
  State<NoteSettingsLayout> createState() => _NoteSettingsLayoutState();
}

class _NoteSettingsLayoutState extends State<NoteSettingsLayout> {
  final FireStoreService _appSettings = FireStoreService.appSettings();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //keys

  final GlobalKey<PopupMenuButtonState> _keyOrden =
      GlobalKey<PopupMenuButtonState>();
  // Lista de opciones del dropdown
  final Map<bool, String> _options = {
    true: "Antiguos primero",
    false: "Nuevos primeros"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion de notas')),
      body: ElevatedButton(
          style: ElevatedButton.styleFrom(
              // backgroundColor: Colors.grey[300],
              shape: const RoundedRectangleBorder()),
          onPressed: () {
            _keyOrden.currentState?.showButtonMenu();
          },
          child: StreamBuilder(
            stream: _appSettings.getAppSettings(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                // Instancia de AppSettings con los datos combinados
                AppSettings appSettings = snapshot.data!.data() as AppSettings;

                String order = _options[snapshot.data?['sortMode']]!;

                return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.filter_list),
                    title: const Text("Orden predeterminado"),
                    subtitle: Text(order),
                    trailing: PopupMenuButton(
                      key: _keyOrden,
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(),
                      itemBuilder: (context) {
                        return _options.entries.map((e) {
                          return PopupMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          );
                        }).toList();
                      },
                      onSelected: (value) {
                        _appSettings.updateAppSettings(
                            uid: _auth.currentUser!.uid,
                            settings: appSettings.copyWith(
                              sortMode: value,
                            ));
                      },
                    ));
              }
            },
          )),
    );
  }
}
