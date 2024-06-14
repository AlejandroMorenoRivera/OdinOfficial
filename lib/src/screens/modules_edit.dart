import 'package:flutter/material.dart';

class ModulesEditingLayout extends StatefulWidget {
  const ModulesEditingLayout({super.key});

  @override
  State<ModulesEditingLayout> createState() => _ModulesEditingLayoutState();
}

class _ModulesEditingLayoutState extends State<ModulesEditingLayout> {
  List modules = ["Configuracion Notas"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurar Modulos"),
      ),
      body: ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.grey[300],
                  shape: const RoundedRectangleBorder()),
              onPressed: () {
                Navigator.pushNamed(context, "/noteSettings");
              },
              child: ListTile(
                leading: const Icon(Icons.sticky_note_2),
                title: Text(modules[index]),
              ));
        },
      ),
    );
  }
}
