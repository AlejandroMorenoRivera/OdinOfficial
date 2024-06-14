
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odin/src/models/quick_buttons_model.dart';
import 'package:odin/src/services/firebase_store_service.dart';
import 'package:odin/src/utils/quick_actions_manager.dart';
import 'package:odin/src/utils/img_base64_converter.dart';

class QAButtonsEditPopup extends StatefulWidget {
  final String id;
  final int position;
  const QAButtonsEditPopup(
      {super.key, required this.id, required this.position});

  @override
  State<QAButtonsEditPopup> createState() => _QAButtonsEditPopupState();
}

class _QAButtonsEditPopupState extends State<QAButtonsEditPopup> {
  // key del formulario para poder validarlo
  final _formKey = GlobalKey<FormState>();

  // servicio de firebase
  final FireStoreService _fireStoreService = FireStoreService.quickbuttons();

  // servicio de firebase auth
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // nos permite seleccionar una imagen de la galería
  late ImagePicker imagePicker;

  // TODO.: esto lo necesitaremos para almacenar imagnes que hagamos desde la galería
  // donde vamos a almacenar la imagen seleccionada
  XFile? _imageCustom;

  // la ruta de la imagen seleccionada
  String? _selectedImagePath;

  // accion seleccionada
  int? _selectedAction;

  // Texto de la imagen (para poder validar si has seleccinado o no la imagen)
  String _imageText = "Selecciona una imagen";

  // color del texto de la imagen seleccinada (para mostrar al usuario si se ha equivocado o no la imagen)
  Color _colorTextImage = Colors.black;

  // Lista de imagenes por defecto
  // imaganes size = 48, bgColor=black, weight = 200
  final List<String> _defaultImagesPaths = [
    'assets/QAButtons/add.png',
    'assets/QAButtons/note_add.png',
    'assets/QAButtons/add_task.png',
    'assets/QAButtons/delete.png',
    'assets/QAButtons/last_page.png',
    'assets/QAButtons/checklist.png',
    'assets/QAButtons/brightness_6.png'
    // Agrega aquí las demás rutas de imágenes
  ];
  // TODO.: debemos hacer que el usuario pueda subir una foto
  Future getImage() async {
    var image = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageCustom = image;
    });
  }

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Editando..."),
          // lista desplegable
          DropdownButtonFormField(
            hint: const Text('Selecciona una Acción'),
            items: List.generate(
              QuickAcctionsManager.getActions(
                      context: context,
                      id: widget.id,
                      position: widget.position)
                  .length,
              (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(QuickAcctionsManager.getActionsIcons()[index]),
                      Container(width: 10),
                      Text(QuickAcctionsManager.getActionsName()[index]!)
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedAction = index;
                    });
                  },
                );
              },
            ),
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona una acción';
              }
              return null;
            },
            // Ejecuta este codigo siempre que se cambie el valor de la lista
            onChanged: (value) {},
          ),
          const SizedBox(
            height: 30,
          ),
          // preview de la imagen del boton
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  // muestra la ventana emergente y guarda el valor que nos devuelve
                  final selectedImage = await showDialog<String>(
                    context: context,
                    builder: (context) =>
                        ImageSelectionDialog(imagePaths: _defaultImagesPaths),
                  );

                  // si tenemos datos de la imagen seleccinada la guardamos en
                  // una variable mas alta
                  if (selectedImage != null) {
                    setState(() {
                      _selectedImagePath = selectedImage;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _selectedImagePath != null
                          ? Image(image: AssetImage(_selectedImagePath!))
                          : Container(),
                      _selectedImagePath == null
                          ? const Icon(Icons.image, size: 50)
                          : Container(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _selectedImagePath == null
                    ? _imageText
                    : "Imagen: ${_selectedImagePath?.split('/').last.split('.')[0].toUpperCase()}",
                style: TextStyle(fontSize: 12, color: _colorTextImage),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedImagePath != null) {
                    _formKey.currentState!.save();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Boton guardado')),
                    );
                    debugPrint("_selectedImagePath: $_selectedImagePath");
                    debugPrint("_selectedAction: $_selectedAction");
                    _fireStoreService.updateQAButton(
                        quickAccessButtonId: widget.id,
                        quickAccessButton: QuickAccessButton(
                          name: "",
                          imgBase64: await ImgBase64Converter
                              .convertAssetImageToBase64(_selectedImagePath!),
                          action: _selectedAction!,
                          position: widget.position,
                          uid: _auth.currentUser?.uid ?? "",
                        ));
                  } else {
                    setState(() {
                      _colorTextImage = (_selectedImagePath == null
                          ? Colors.red
                          : Theme.of(context).textTheme.displaySmall!.color!);
                      _imageText = "Selecciona una imagen!";
                    });
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//clase que muestra un menu con las imagenes seleccionables
class ImageSelectionDialog extends StatelessWidget {
  final List<String> imagePaths;

  const ImageSelectionDialog({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Imagen de Fondo',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          // crea un item por cada elemento del map, ejecutando la fucion
          children: imagePaths.map((imagePath) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context, imagePath);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Image(
                        image: AssetImage(imagePath),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(imagePath.split('/').last.split('.')[0].toUpperCase()),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
