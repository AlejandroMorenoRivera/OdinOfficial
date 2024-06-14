import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionLayout extends StatefulWidget {
  const IntroductionLayout({super.key});

  @override
  State<IntroductionLayout> createState() => _IntroductionLayoutState();
}

class _IntroductionLayoutState extends State<IntroductionLayout> {
  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        // color: Colors.blue,
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: ClipOval(
            child: Image.asset(
              "assets/app_logo.jpg",
              fit: BoxFit.fill,
            ),
          ),
        ));
    return IntroductionScreen(
      next: const Icon(Icons.navigate_next),
      // showBackButton: true, ! showBack and showSkip can't be both be true.
      // back: const Icon(Icons.arrow_back),
      showSkipButton: true,
      skip: const Text('Skip'),
      onDone: Navigator.of(context).pop,
      done: const Text("Done"),
      dotsFlex: 3,
      pages: [
        PageViewModel(
          //! The title/body can either be strings or widgets.
          titleWidget: logo,
          body: 'Bienvenidos a Odin!',
        ),
        PageViewModel(
          title: 'Botones de acceso rápido',
          body:
              'Con estos botones puedes acceder de forma inmedianta, a diferentes secciones del app.',
          image: Image.asset('assets/introduction/qabuttons.jpeg'),
        ),
        PageViewModel(
          title: 'Uso de los botones',
          body:
              'Si eres un usuario nuevo puedes hacer clic en ellos y configurar el botón.\n Para editar el botón, manten el botón y se abrirá el modo edición',
          image: Image.asset('assets/introduction/qabutton_edit.jpeg'),
        ),
        PageViewModel(
          title: 'Listo para usar!',
          body: "Ahora hacer uso del botón.",
          image: Image.asset('assets/introduction/qabutton_example.jpeg'),
        ),
        PageViewModel(
          title: 'Barra de navegacion',
          body:
              "Con esta barra podras acceder a todas las funcionalides de los modulos que ofrece la app",
          image: Image.asset("assets/introduction/buttonbar.jpeg"),
        ),
        PageViewModel(
          title: 'Ajustes',
          body:
              "Con esta barra podras acceder a todas las funcionalides de los modulos que ofrece la app",
          image: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            children: [
              // Image.asset("assets/introduction/settingsButton.jpeg"),
              Image.asset("assets/introduction/settings.jpeg"),
            ],
          ),
        ),
        // PageViewModel(
        //   title: 'Enjoy!',
        //   bodyWidget: Column(
        //     children: [
        //       Text('Explore the demos and learn Flutter anywhere as you go!\n'
        //           'And you are more than welcome to contribute to this open-source app :)'),
        //       Card(
        //         child: ListTile(
        //           leading: Icon(Icons.code),
        //           title: Text('Source code on GitHub'),
        //           onTap: () {},
        //         ),
        //       ),
        //       Card(
        //         child: ListTile(
        //           leading: const Icon(Icons.bug_report),
        //           title: const Text('Report issue on GitHub'),
        //           onTap: () {},
        //         ),
        //       ),
        //     ],
        //   ),
        //   image: Image.asset('res/images/dart-side.png'),
        // ),
      ],
    );
  }
}
