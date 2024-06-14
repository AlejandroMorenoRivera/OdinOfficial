import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odin/src/models/notes_model.dart';
import 'package:odin/src/models/settings_model.dart';
import 'package:odin/src/widgets/notes_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odin/src/services/firebase_store_service.dart';

class NotesLayout extends StatefulWidget {
  const NotesLayout({super.key});

  @override
  State<NotesLayout> createState() => _NotesLayoutState();
}

class _NotesLayoutState extends State<NotesLayout> {
  final String _DEFAULT_BG_NOTE = '';
  // esto sirve para poder meterle luego un listener
  // (pero no me gusta esta opcion para este caso)
  // ValueNotifier<bool> showSearchBar = ValueNotifier<bool>(false);

  // lista de notas (la hago para poder ordenar los resultados por fecha)
  List<NotesItem> _notesListSorted = [];

  // controlado de la barra de busqueda
  TextEditingController textEditingController = TextEditingController();

  // controlador para poder manejar el scroll de la app
  final ScrollController _scrollController = ScrollController();

  // gestor de la base de datos
  final FireStoreService _fireStoreNotes = FireStoreService.notes();
  final FireStoreService _fireStoreAppSetting = FireStoreService.appSettings();
  late StreamSubscription<DocumentSnapshot<Object?>>
      _fireStoreAppSettingSubcription;

  // variables del filtro
  late bool _sortMode;

  // settings
  late AppSettings appSettings;

  @override
  void initState() {
    textEditingController.addListener(() {
      setState(() {});
      debugPrint(textEditingController.text);
    });

    // agregamos el listener para que al hacer scroll
    // el focus se pierda en otros sitios
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });

    // listener para el orden de las notas
    _fireStoreAppSettingSubcription =
        _fireStoreAppSetting.getAppSettings().listen(
      (event) {
        appSettings = event.data() as AppSettings;
        _sortMode = appSettings.sortMode;
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textEditingController.dispose();
    _fireStoreAppSettingSubcription.cancel();
    super.dispose();
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

  void _addNote() async {
    Navigator.of(context).pushNamed(
      '/editNote',
      arguments: {'id': null, 'title': "Nueva nota", 'content': ""},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _fireStoreNotes.getNotes(),
        builder: (context, snapshot) {
          // almacenamos los datos que viene directos del firestore (en json)
          List<QueryDocumentSnapshot> notesData = snapshot.data?.docs ?? [];

          // si no hay datos muestra un progress indicator
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
            // si hay datos muestra el gridview
          } else {
            // limpiamos la lista para evitar que se sumen mas y mas en cada cambio
            _notesListSorted.clear();
            //llenamos la lista mapeando cada item de los datos que viene del stream
            _notesListSorted.addAll(
              notesData.map(
                (e) => NotesItem(
                    title: (e.data() as Note).title,
                    id: e.id,
                    content: (e.data() as Note).content,
                    imgBase64: (e.data() as Note).imgBase64,
                    createdOn: (e.data() as Note).createdOn,
                    updatedOn: (e.data() as Note).updatedOn,
                    onDelete: (id) {
                      _fireStoreNotes.deleteNote(noteId: id);
                    },
                    tags: (e.data() as Note).tags),
              ),
            );
            // aplicamos los filtros de los ajustes
            _notesListSorted = getListFiltered(_notesListSorted);

            return GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: SafeArea(
                child: CustomScrollView(
                  //controlador para el scroll
                  controller: _scrollController,
                  // physics: BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      pinned: true,
                      clipBehavior: Clip.none,
                      // shape: const StadiumBorder(),
                      scrolledUnderElevation: 0.0,
                      titleSpacing: 0.0,
                      // backgroundColor: Colors.transparent,
                      leading: const BackButton(),
                      // centerTitle: true,

                      title: TextField(
                        // para controlar las pulsaciones
                        controller: textEditingController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              textEditingController.clear();
                              setState(() {});
                            },
                          ),
                          // icon: Icon(Icons.search),
                          isDense: true,
                          // prefix: Text("Buscar: "),
                          prefixIcon: const Icon(Icons.search),

                          hintText: "Buscar...",
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            _swapSortOrder();
                          },
                          icon: const Icon(Icons.filter_alt_outlined),
                        ),
                      ],
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // Note aux = notesData[index].data() as Note;
                        NotesItem aux = _notesListSorted[index];

                        // cuando escribimos en el buscador
                        if (aux.title.toLowerCase().contains(
                                textEditingController.text.toLowerCase()) ||
                            aux.content.toLowerCase().contains(
                                textEditingController.text.toLowerCase()) ||
                            _isTextInList(aux.tags,
                                textEditingController.text.toLowerCase())) {
                          return _notesListSorted[index];

                          // valores sin filtrar
                        }
                        return Container();
                      }, childCount: snapshot.data?.size),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            _addNote();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  bool _isTextInList(List lista, String text) {
    bool isConteined = false;
    for (String element in lista) {
      if (element.toLowerCase().contains(text)) {
        isConteined = true;
        return isConteined;
      }
    }
    return isConteined;
  }

  List<NotesItem> getListFiltered(List<NotesItem> originalList) {
    List<NotesItem> filteredList = originalList;

    // del mas nuevo al mas viejo
    originalList.sort((a, b) {
      return b.updatedOn.compareTo(a.updatedOn);
    });
    // del mas viejo al mas nuevo
    if (_sortMode) {
      filteredList = originalList.reversed.toList();
    }
    return filteredList;
  }

  void _swapSortOrder() {
    setState(() {
      // appSettings.sortMode = !appSettings.sortMode;
      _sortMode = !_sortMode;
    });
    // _fireStoreAppSetting.updateAppSettings(
    //     uid: firebaseauth.FirebaseAuth.instance.currentUser!.uid,
    //     settings: appSettings);
  }
}
