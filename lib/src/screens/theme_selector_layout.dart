import 'package:flutter/material.dart';
import 'package:odin/src/utils/quick_actions_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSelectorLayout extends StatefulWidget {
  const ThemeSelectorLayout({super.key});

  @override
  State<ThemeSelectorLayout> createState() => _ThemeSelectorLayoutState();
}

class _ThemeSelectorLayoutState extends State<ThemeSelectorLayout> {
  // color seleccionado
  late bool _isDarkTheme = false;
  @override
  void initState() {
    _isCurrentTheme().then(
      (value) {
        setState(() {
          _isDarkTheme = value;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Selector de tema'),
        ),
        //TODO: de momento la seleccion va a ser asi luego hay que hacer un lista con todos los temas y recorrerla
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.grey[300],
                    shape: const RoundedRectangleBorder()),
                onPressed: () {
                  QuickAcctionsManager.getActions(context: context)[2]();

                  setState(() {
                    _isDarkTheme = !_isDarkTheme;
                  });
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_isDarkTheme
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined),
                  title: const Text(
                    "Oscuro",
                  ),
                  subtitle: const Text("Activa el Modo oscuro"),
                  trailing: Switch(
                      value: _isDarkTheme,
                      onChanged: (value) {
                        QuickAcctionsManager.getActions()[2]();
                        setState(() {
                          _isDarkTheme = value;
                        });
                      }),
                ),
              ),
            ),
          ],
        ));
  }

  Future<bool> _isCurrentTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkTheme') ?? false;
  }
}
