import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odin/src/models/notes_model.dart';
import 'package:odin/src/services/firebase_store_service.dart';

class NotesEditLayout extends StatefulWidget {
  const NotesEditLayout({super.key});

  @override
  State<NotesEditLayout> createState() => _NotesEditLayoutState();
}

class _NotesEditLayoutState extends State<NotesEditLayout> {
  // gestor de la base de datos
  final FireStoreService _fireStoreService = FireStoreService.notes();

  // valores
  String _title = "";
  String _content = "";
  List _tags = [];

  // eventos
  bool _titleEditMode = false;
  bool _contentEditMode = false;

  // nuevos valores
  String newTitle = "";
  String newContent = "";

  late FocusNode _focusNode;

  // controladores
  late TextEditingController titleController;
  late TextEditingController contentController;
  TextEditingController tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    titleController =
        TextEditingController(text: newTitle != "" ? newTitle : _title);
    contentController =
        TextEditingController(text: newContent != "" ? newContent : _content);
  }

  @override
  Widget build(BuildContext context) {
    // recoger los argumentos pasados
    Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

    // NOTE: Argumentos modificables
    if (_title.isEmpty && _content.isEmpty) {
      _title = arguments['title'];
      _content = arguments['content'];
    }

    _tags = arguments['tags'] ?? _tags;

    // NOTE: si la id es nula es por que la nota es nueva
    final String? id = arguments['id'];

    // controladores
    TextEditingController titleController =
        TextEditingController(text: newTitle != "" ? newTitle : _title);
    TextEditingController contentController =
        TextEditingController(text: newContent != "" ? newContent : _content);
    TextEditingController tagsController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        bool _continue = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alerta'),
              content: Text('¿Estás seguro de que deseas continuar?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Acción al cancelar
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    debugPrint('Cancelar presionado');
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    // Acción al aceptar
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Cerrar el diálogo
                    debugPrint('Aceptar presionado');
                    _continue = true;
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
        return _continue;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[100],
          foregroundColor: Colors.blueGrey[900],
          title: GestureDetector(
            onTap: () {
              // hace que suene como si fuera un boton
              Feedback.forTap(context);
              setState(() {
                debugPrint("Contenido: ${contentController.text}");
                newContent = contentController.text;
                // damos focus al textfild
                _focusNode.requestFocus();
                _titleEditMode = !_titleEditMode;
              });
            },
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _titleEditMode
                    ? Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: titleController,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      )
                    : Row(
                        children: [
                          Text(
                            titleController.text,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.edit)
                        ],
                      ),
                _titleEditMode
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            newTitle = titleController.text;
                            _titleEditMode = false;
                          });
                        },
                        icon: const Icon(Icons.save))
                    : Container()
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    //tags adder
                    Expanded(
                        child: TextField(
                      controller: tagsController,
                      decoration: InputDecoration(hintText: "Agregar tag #"),
                    )),
                    ElevatedButton(
                      onPressed: () {
                        if (tagsController.text.length != 0) {
                          setState(() {
                            _tags.add(tagsController.text);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ingrese un tag!",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          );
                        }
                      },
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ...List.generate(_tags.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: InputChip(
                          label: Text("# " + _tags[index]),
                          deleteIcon: Icon(Icons.delete),
                          onDeleted: () {
                            setState(() {
                              _tags.removeAt(index);
                            });
                          },
                          onSelected: (value) {},
                        ),
                      );
                    })
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Escribe tu nota...\n\n\n\n",
                  ),
                  controller: contentController,
                ),
              ),
              Row(
                children: [
                  //guardar nota
                ],
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // si es nueva
            if (id == null) {
              String _DEFAULT_BG_NOTE = await _loadDefaultBGNoteAsBase64();
              Note note = Note(
                  title: newTitle == "" ? "Nueva nota" : newTitle,
                  imgBase64: _DEFAULT_BG_NOTE,
                  tags: _tags,
                  createdOn: Timestamp.now(),
                  updatedOn: Timestamp.now(),
                  uid: firebase_auth.FirebaseAuth.instance.currentUser!.uid,
                  content: contentController.text);

              _fireStoreService.addNote(note);
            } else {
              // modificacion de nota
              Note note = Note(
                title: newTitle == "" ? _title : newTitle,
                imgBase64: arguments["imgBase64"],
                tags: _tags,
                createdOn: arguments["createdOn"],
                updatedOn: Timestamp.now(),
                uid: firebase_auth.FirebaseAuth.instance.currentUser!.uid,
                content: contentController.text,
              );
              _fireStoreService.updateNote(noteId: arguments["id"], note: note);
            }
            Navigator.pop(context);
          },
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // El TextField ha perdido el foco
      debugPrint('El TextField ha perdido el foco');

      setState(() {
        _titleEditMode = false;
      });
    }
  }

  // carga la imagen por defecto de las notas
  Future<String> _loadDefaultBGNoteAsBase64() async {
    // asset a ByteData
    ByteData bytes = await rootBundle.load('assets/notesPaperBG.jpg');

    // ByteData a Uint8List
    Uint8List byteList = bytes.buffer.asUint8List();

    // Uint8List a base64
    String base64Image = base64Encode(byteList);

    return base64Image;
  }
}
