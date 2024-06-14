import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:odin/src/screens/firebase_login.dart';
import 'package:odin/src/screens/settings_layout.dart';
import 'package:odin/src/utils/app_storage.dart';
import 'package:odin/src/models/main_bar_buttons_model.dart';
import 'package:odin/src/utils/new_user_setup.dart';
import 'package:odin/src/widgets/overview.dart';
// import 'package:odin/src/services/firebase_service.dart';
// import 'package:odin/src/widgets/overview.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  List<MainBarButtonModel> sampleData = [];

  int selectedIndex = 0;

  @override
  void initState() {
    // si es nuevo usuario vamos a cargar QAButtons por primera vez
    _loadDefaultSetup();

    // agrega los botones del menu de abajo
    sampleData.add(
      MainBarButtonModel(
        title: "Notas",
        onTap: () => Navigator.pushNamed(context, "/notes"),
        icon: Icons.sticky_note_2,
        colors: Colors.blue,
      ),
    );
    sampleData.add(
      MainBarButtonModel(
        title: "Coming soon",
        onTap: () {},
        icon: Icons.construction,
        colors: Colors.orange,
      ),
    );
    sampleData.add(
      MainBarButtonModel(
        title: "Coming soon",
        onTap: () {},
        icon: Icons.construction,
        colors: Colors.red,
      ),
    );
    sampleData.add(
      MainBarButtonModel(
        title: "Coming soon",
        onTap: () {},
        icon: Icons.construction,
        colors: Colors.purple,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      // le pasamos la lista de elementos que queremos mostrar (en este caso la pasamos vacia ya que quermos que nos genere una aleatoria)
      body: const Center(child: OverView()),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // me gusta que sea un FLoatinActionButton ya que cuando lo usas en otras
      // screens el boton se va moviendo
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        // le quitamos el fondo
        backgroundColor: Colors.transparent,
        // quitamos la elevacion
        elevation: 0,
        child: SpeedDial(
          // icon: Icons.settings,
          direction: SpeedDialDirection.down,
          backgroundColor: Colors.transparent,
          mini: true,
          elevation: 0,
          childrenButtonSize: const Size(50, 50),
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.settings),
              shape: const CircleBorder(),
              onTap: () {
                // Navigator.of(context).pushReplacementNamed('/login');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsLayout()));
                // Navigator.pushNamed(context, route)
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppStorage.cardColor,
        clipBehavior: Clip.hardEdge,
        shape: const CircularNotchedRectangle(),
        notchMargin: 1,
        child: Container(
          //margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            children: [
              ...List.generate(
                sampleData.length,
                (index) {
                  MainBarButtonModel data = sampleData[index];
                  return Expanded(
                    child: IconButton(
                        onPressed: () {
                          data.onTap!();
                        },
                        icon: Column(
                          children: [
                            Icon(
                              data.icon,
                            ),
                            Text(
                              data.title!,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        )),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _singOut() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user == null
              ? 'No user logged in.'
              : '"${user.displayName ?? user.email}" logged out.',
        ),
      ),
    );

    await auth.signOut();

    Navigator.of(context).pushReplacementNamed('/login');
  }

  void navigatorWithAnimation(BuildContext context, Widget newScreen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => newScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Definimos el desplazamiento inicial y final
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          // Usamos SlideTransition para animar el desplazamiento
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _loadDefaultSetup() async {
    if (FirebaseLogin.isNewUser) {
      debugPrint("El usuario es Nuevo, montando setUp");
      NewUserSetup.loadDefaultQAButtons();
      NewUserSetup.loadDefaultSettings();
    } else {
      debugPrint("El usuario viejooo");
    }
  }
}
