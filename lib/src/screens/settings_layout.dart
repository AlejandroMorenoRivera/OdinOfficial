
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:odin/src/services/firebase_store_service.dart';
import 'package:odin/src/widgets/deleteAccountAlert.dart';

class SettingsLayout extends StatefulWidget {
  const SettingsLayout({super.key});

  @override
  State<SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<SettingsLayout> {
  User? user = FirebaseAuth.instance.currentUser;
  FireStoreService appSettingsService = FireStoreService.appSettings();
  FireStoreService notesService = FireStoreService.notes();
  FireStoreService quickbuttonsService = FireStoreService.quickbuttons();

  // datos
  late String? photoURL; // = _user?.photoURL;
  late String? name; // = _user?.displayName;
  late String? email; // = _user?.email;
  late bool isAnonymous; // = _user?.isAnonymous ?? true;

  @override
  void initState() {
    photoURL = user?.photoURL;
    name = user?.displayName;
    email = user?.email;
    isAnonymous = user?.isAnonymous ?? true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            cardSettings(),
            const SizedBox(height: 20),
            settingsButton("Cambiar paleta de colores", Icons.color_lens, () {
              Navigator.pushNamed(context, "/themeSelectorLayout");
            }),
            settingsButton("Modulos", Icons.view_compact,
                () => Navigator.pushNamed(context, "/modulesEditingLayout")),
            settingsButton("Repetir tutorial", Icons.school_rounded,
                () => Navigator.of(context).pushNamed("/introductionLayout")),
            settingsButton("Eliminar cuenta", Icons.delete, () {
              showDialog(
                context: context,
                builder: (context) {
                  return const DeleteAccountAlert();
                },
              );
            })
          ],
        ),
      ),
    );
  }

  Widget settingsButton(String title, IconData icon, Function() onPress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              alignment: Alignment.centerLeft,
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              // backgroundColor: WidgetStateProperty.all(Colors.white),
              // foregroundColor: WidgetStateProperty.all(Colors.black),
            ),
            onPressed: onPress,
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget cardSettings() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 0,
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(photoURL ??
                "https://artscimedia.case.edu/wp-content/uploads/sites/79/2016/12/14205134/no-user-image.gif"),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? "<<Cuenta sin nombre>>",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              email != null ? Text(email!) : Container(),
              isAnonymous
                  ? const Text("Usuario anonimo",
                      style: TextStyle(color: Colors.grey))
                  : Container()
            ],
          ),
        ),
        IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      "Cerrar sesión",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "¿Desea cerrar sesión?",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        isAnonymous
                            ? Card(
                                shape: const RoundedRectangleBorder(),
                                // elevation: 5,
                                child: Text(
                                  "Estas con una cuenta anonima, por lo que perderas todos los datos",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancelar",
                          )),
                      TextButton(
                          onPressed: () async {
                            if (isAnonymous) {
                              appSettingsService.deleteAppSettings(
                                  uid: user!.uid);
                              await notesService.deleteAllNotes();
                              await quickbuttonsService.deleteAllQAButtons();
                              await user!.delete();
                              Navigator.pushReplacementNamed(context, "/login");
                            }

                            GoogleSignIn().signOut();
                            FirebaseAuth.instance.signOut().then(
                              (value) {
                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                    context, "/login");
                              },
                            );
                          },
                          child: const Text("Aceptar"))
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ))
      ],
    );
  }
}
