import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odin/src/models/notes_model.dart';
import 'package:odin/src/models/quick_buttons_model.dart';
import 'package:odin/src/models/settings_model.dart';

const String QUICKACCESSBUTTONS_COLLECTION_REF = "quickAccessButtons";
const String NOTES_COLLECTION_REF = "notes";
String SETTINGS_COLLECTION_REF = "settings";

class FireStoreService {
  // creamos la instancia de firestore
  final _fireStore = FirebaseFirestore.instance;

  // creamos la variables donde se guardara la coleccion
  late final CollectionReference _QAButtonsCollectionRef;
  late final CollectionReference _NoteCollectionRef;
  late final CollectionReference _SettingsCollectionRef;

// quick Access buttons
  // firestore para cargar QAButtons
  FireStoreService.quickbuttons() {
    // usamos "withconverter" por que nos va a hacer mas facil el manejo
    // de los datos con el server es decir estamos "parseando"
    // los datos del servidor para que se adapten
    // a nuestro modelo "quick_buttons_model"
    // cuando necesitemos datos de la base de datos
    // se va a ejecutar "fromFirestore"
    // cuando mandemos datos al servidor, se ejecutara "toFirestore"
    _QAButtonsCollectionRef = _fireStore
        .collection(QUICKACCESSBUTTONS_COLLECTION_REF)
        .withConverter<QuickAccessButton>(
            fromFirestore: (snapshot, _) =>
                QuickAccessButton.fromJson(snapshot.data()!),
            toFirestore: (quickAccessButtonModel, _) =>
                quickAccessButtonModel.toJson());
  }

  // para poder coger datos de firestore
  Stream<QuerySnapshot> getQAButtons() {
    return _QAButtonsCollectionRef.where("uid",
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  // agregar datos en firestore (async ya que cuando subamos los datos
  // no queremos que se pille la app)
  Future<DocumentReference<Object?>> addQAButton(QuickAccessButton quickAccessButton) async {
    return _QAButtonsCollectionRef.add(quickAccessButton);
  }

  // firestore para actulizar datos en notas
  void updateQAButton(
      {required String quickAccessButtonId,
      required QuickAccessButton quickAccessButton}) async {
    _QAButtonsCollectionRef.doc(quickAccessButtonId)
        .update(quickAccessButton.toJson());
  }

  // firestore para eliminar datos en notas
  void deleteQAButton({required String quickAccessButtonId}) async {
    _QAButtonsCollectionRef.doc(quickAccessButtonId).delete();
  }

  // delete all QAButtons
  Future<void> deleteAllQAButtons() async {
    return _QAButtonsCollectionRef.where("uid",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then((querySnapshot) {
      for (var document in querySnapshot.docs) {
        document.reference.delete();
      }
    });
  }

//firestore para cargar notas
  FireStoreService.notes() {
    // usamos "withconverter" por que nos va a hacer mas facil el manejo de los datos con el server
    // es decir estamos "parseando" los datos del servidor para se se adapten a nuestro modelo "quick_buttons_model"
    // cuando necesitemos datos de la base de datos se va a ejecutar "fromFirestore"
    // cuando mandemos datos al servidor, se ejecutara "toFirestore"
    _NoteCollectionRef = _fireStore
        .collection(NOTES_COLLECTION_REF)
        .withConverter<Note>(
            fromFirestore: (snapshot, _) => Note.fromJson(snapshot.data()!),
            toFirestore: (noteModel, _) => noteModel.toJson());
  }

//notas
  // para poder coger datos de firestore
  Stream<QuerySnapshot> getNotes() {
    return _NoteCollectionRef.where("uid",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  // agregar nota en firestore (async ya que cuando subamos los datos no queremos que se pille la app XD)
  void addNote(Note note) async {
    _NoteCollectionRef.add(note);
  }

  // firestore para actulizar datos en notas
  void updateNote({required String noteId, required Note note}) async {
    _NoteCollectionRef.doc(noteId).update(note.toJson());
  }

  // firestore para eliminar datos en notas
  void deleteNote({required String noteId}) async {
    _NoteCollectionRef.doc(noteId).delete();
  }

  // firestore para eliminar todas las notas
  // (lo tenemos que hacer asi ya que las UID estan en las notas no en los documentos)
  Future<void> deleteAllNotes() async {
    return _NoteCollectionRef.where("uid",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((querySnapshot) {
      for (var document in querySnapshot.docs) {
        document.reference.delete();
      }
    });
  }

  // Devuelve el numero de notas para este usuario
  Future<int> getNumberOfNotes() async {
    return _NoteCollectionRef.where("uid",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((querySnapshot) {
      return querySnapshot.size;
    });
  }

// Ajustes
  FireStoreService.appSettings() {
    _SettingsCollectionRef = _fireStore
        .collection(SETTINGS_COLLECTION_REF)
        .withConverter<AppSettings>(
            fromFirestore: (snapshot, _) =>
                AppSettings.fromJson(snapshot.data()!),
            toFirestore: (settingsModel, _) => settingsModel.toJson());
  }
  Future<void> addAppSettings(String uid, AppSettings settings) async {
    return _SettingsCollectionRef.doc(uid).set(settings);
  }

  void updateAppSettings(
      {required String uid, required AppSettings settings}) async {
    _SettingsCollectionRef.doc(uid).update(settings.toJson());
  }

  Stream<DocumentSnapshot<Object?>> getAppSettings() {
    return _SettingsCollectionRef.doc(
            firebaseAuth.FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Future<void> deleteAppSettings({required String uid}) async {
    return _SettingsCollectionRef.doc(uid).delete();
  }
}
