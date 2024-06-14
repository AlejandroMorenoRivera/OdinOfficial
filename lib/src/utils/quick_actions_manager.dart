import 'package:flutter/material.dart';
import 'package:odin/src/app.dart';
import 'package:odin/src/widgets/delete_all_notes_popup.dart';
import 'package:odin/src/widgets/qab_edit_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickAcctionsManager {
  static Map<int, dynamic> getActions(
      {BuildContext? context, String? id, int? position}) {
    final Map<int, dynamic> actions = {
      //mostrar el menu de edicion del QAButton
      0: () {
        showDialog(
          context: context!,
          builder: (context) {
            return AlertDialog(
                content: QAButtonsEditPopup(
              id: id!,
              position: position!,
            ));
          },
        );
      },
      //crear nota
      1: () {
        Navigator.of(context!).pushNamed(
          '/editNote',
          arguments: {'id': null, 'title': "Nueva nota", 'content': ""},
        );
      },
      //cambiar de tema
      2: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (MainApp.themeNotifier.value == ThemeData.light()) {
          MainApp.themeNotifier.value = ThemeData.dark();
          await prefs.setBool('isDarkTheme', true);
        } else {
          MainApp.themeNotifier.value = ThemeData.light();
          await prefs.setBool('isDarkTheme', false);
        }
      },
      //borrar datos de todas las notas
      3: () async {
        final result = await showDialog(
          context: context!,
          builder: (BuildContext context) {
            return const DeleteNotesPopup();
          },
        );

        if (result != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Se eliminaron ${result['numNotes']} notas"),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ]),
              );
            },
          );
        }
      },
      // 4: () {
      //   debugPrint("Boton 4");
      // }
    };
    return actions;
  }
  // Map que relaciona el action(en firebase) con la accion(la funcion que hace)

  // Map que relaciona el action(en firebase) con el nombre de la accion
  static final Map<int, String> _actionsName = {
    0: "Default",
    1: "Crear Nota",
    2: "Alternar tema",
    3: "Borrar notas",
    // 4: "Ver tarear pendientes"
  };
  // a cada accion le ponemos un icono representativo
  static final Map<int, IconData> _actionsIcons = {
    0: Icons.add,
    1: Icons.edit,
    2: Icons.brightness_6_outlined,
    3: Icons.delete_outline,
    // 4: Icons.toc_outlined
  };

  static Function()? getAccionById(
      BuildContext context, int action, String id, int position) {
    return getActions(context: context, id: id, position: position)[action];
  }

  static Map<int, String> getActionsName() {
    return _actionsName;
  }

  static Map<int, dynamic> getActionsIcons() {
    return _actionsIcons;
  }
}
