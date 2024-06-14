import 'package:flutter/material.dart';
import 'package:odin/src/screens/firebase_login.dart';
import 'package:odin/src/screens/introduction_layout.dart';
import 'package:odin/src/screens/main_layout.dart';
import 'package:odin/src/screens/modules_edit.dart';
import 'package:odin/src/screens/note_setting.dart';
import 'package:odin/src/screens/notes_edit_layout.dart';
import 'package:odin/src/screens/notes_layout.dart';
import 'package:odin/src/screens/theme_selector_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  /// si luego quisieramos sacar las rutas para  modificarlas (para hacer lo de la gestion de modulos)
  /// podemos limitar la rutas extrayendo las en un variable (no se se me acaba de ocurrir valorar cuando sea oportuno XD)

  //Map<String, Widget Function(BuildContext)> routes = const <String, WidgetBuilder>{};

  static ValueNotifier<ThemeData> themeNotifier =
      ValueNotifier(ThemeData.light());

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    // nos carga el tema que tengamos guardado
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: MainApp.themeNotifier,
        builder: (context, ThemeData themem, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: MainApp.themeNotifier.value,
            initialRoute: '/login',
            routes: {
              "/login": (context) => const FirebaseLogin(),
              "/main": (context) => const MainLayout(),
              "/notes": (context) => const NotesLayout(),
              "/editNote": (context) => const NotesEditLayout(),
              "/modulesEditingLayout": (context) =>
                  const ModulesEditingLayout(),
              "/noteSettings": (context) => const NoteSettingsLayout(),
              "/themeSelectorLayout": (context) => const ThemeSelectorLayout(),
              "/introductionLayout": (context) => const IntroductionLayout(),
            },
          );
        });
  }

// nos carga el tema que tengamos guardado
// en el copyWith podemos modificar cosas del tema
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    if (isDarkTheme) {
      MainApp.themeNotifier.value = ThemeData.dark().copyWith();
    } else {
      MainApp.themeNotifier.value = ThemeData.light().copyWith();
    }
  }
}
