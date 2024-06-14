import 'package:flutter/material.dart';
import 'package:odin/src/services/firebase_store_service.dart';

class DeleteNotesPopup extends StatefulWidget {
  const DeleteNotesPopup({super.key});

  @override
  State<DeleteNotesPopup> createState() => _DeleteNotesPopupState();
}

class _DeleteNotesPopupState extends State<DeleteNotesPopup> {
  final FireStoreService _fireStoreService = FireStoreService.notes();

  bool _deleteNotes = false;
  int _numberOfNotes = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Align(
              alignment: Alignment.center,
              child: Text("Advertencia",
                  style: TextStyle(color: Colors.amber[900])),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          CheckboxListTile(
            value: _deleteNotes,
            isThreeLine: false,
            activeColor: Colors.amber[900],
            // subtitle: Text("¿Desea eliminar todas las notas?",
            //     style: TextStyle(color: Colors.grey[700])),
            title: const Text("Eliminar notas ⚠️"),
            // secondary: Icon(Icons.warning, color: Colors.amber[900]),
            onChanged: (value) {
              setState(() {
                _deleteNotes = value!;
              });
            },
          ),
          StreamBuilder(
            stream: _fireStoreService.getNumberOfNotes().asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text("Cargando...");
              } else {
                _numberOfNotes = snapshot.data!;
                return AnimatedScale(
                  scale: _deleteNotes ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: Text(
                    "Número de notas: $_numberOfNotes",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                );
              }
            },
          )
        ],
      ),
      actions: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              // icon: Icon(Icons.cancel),
              label: const Text("Cancelar"),
            ),
            // divisor para rows
            // Container(
            //   height: 20,
            //   width: 1,
            //   color: Theme.of(context).primaryColorDark,
            // ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              child: TextButton(
                onPressed: _deleteNotes
                    ? () {
                        _fireStoreService.deleteAllNotes();
                        Navigator.pop(context, {'numNotes': _numberOfNotes});
                      }
                    : null,
                child: const Text("Aceptar"),
              ),
            )
          ],
        )
      ],
    );
  }
}
