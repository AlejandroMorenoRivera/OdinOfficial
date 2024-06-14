import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odin/src/models/quick_buttons_model.dart';
import 'package:odin/src/services/firebase_store_service.dart';
import 'package:odin/src/widgets/overview_item.dart';

class OverView extends StatefulWidget {
  // la clase aqui debe ser final para mejor compatibilidad, y luego en el estado ya hacer una nueva variable con la que trabajar
  // TODO: Hacer que estaa lista sea accesible desde los ajustes y que cuando cambie se aculize la lista mostrada

  const OverView({
    super.key,
  });

  @override
  State<OverView> createState() => _OverViewState();
}

class _OverViewState extends State<OverView>
    with SingleTickerProviderStateMixin {
  //instancia de la base de datos
  final FireStoreService _fireStoreService = FireStoreService.quickbuttons();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // radio de la preview
  late double radius;

  // Obtener las dimensiones de la pantalla
  late double screenWidth;
  late double screenHeight;

  // calcular el tamaño de los elementos para que se ajusten segun el telefono
  final crossAxisCount = 2; // numero de columnas en la rejilla
  late double itemWidth;
  late double itemHeight; // hacer los elementos cuadrados

  //cargamos el radio de los elementos
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //inicializamos las variables
    MediaQueryData mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    itemWidth = screenWidth / crossAxisCount;
    itemHeight = itemWidth;
    radius = itemWidth;

    // //en caso de estar vacia vamos a cargar con datatos aletorios (esto es por que la app esta en desarrollo, deberia cambiar en produccion)
    // if (quickAccessButtons.isEmpty) {
    //   //cargamos el array con los items para el acceso rapido
    //   for (var i = 0; i < 6; i++) {
    //     //vamos agregando los widgets al array
    //     quickAccessButtons.add(
    //       OverviewItem(radius: radius, elevation: 9, id: i, action: 1,),
    //     );
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // esta es la opcion que mas me convence
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // esperamos a que los datos se recojan del stream
          StreamBuilder(
            // el stream de datos que hemos creado antes
            stream: _fireStoreService.getQAButtons(),
            // contruccion del widget
            builder: (context, snapshot) {
              // almacenamos los datos que viene directos del firestore (en json)
              List<QueryDocumentSnapshot> quickAccessButtonsData =
                  snapshot.data?.docs ?? [];
              // si no hay datos muestra un progress indicator
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
                // si hay datos muestra el gridview
              } else {
                return GridView.builder(
                  //quietamos el scroll
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // hacemos un delagete personalizado
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //cuando ocupa cada cuadradito del grid
                    // /4 para guardar la relacion bien
                    mainAxisExtent: itemHeight,
                    crossAxisCount: 2,
                    // en moviles ccon la resulucion rara se puedenn ver como ovalos XD
                    childAspectRatio: itemWidth / itemHeight,
                  ),
                  // numero de datos que hay en firebase
                  itemCount: quickAccessButtonsData.length,
                  //creamoe el conjunto de elementos del gridview
                  itemBuilder: (context, index) {
                    // creamos un boton
                    QuickAccessButton aux = quickAccessButtonsData[index].data()
                        as QuickAccessButton;

                    return OverviewItem(
                      radius: radius,
                      elevation: 9,
                      id: quickAccessButtonsData[index].id,
                      action: aux.action,
                      imageBase64: aux.imgBase64,
                      position: aux.position,
                    );
                    // return quickAccessButtons[index];
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  
}
