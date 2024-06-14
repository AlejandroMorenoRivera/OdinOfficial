import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // al hacerlo asi hace mas facil accceder a la instancia
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final kFirebaseAnalytics = FirebaseAnalytics.instance;

class FirebaseLogin extends StatefulWidget {
  static bool isNewUser = false;
  const FirebaseLogin({super.key});

  @override
  FirebaseLoginState createState() => FirebaseLoginState();
}

class FirebaseLoginState extends State<FirebaseLogin> {
  // Global keys
  // Usada en TextField para saber el alto predeterminado (para luego la animacion)
  final GlobalKey _textFieldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final FirebaseAuth _auth;
  firebase_auth.User? _user;
  //si esta en false el boton de login estara deshabilitado
  //para evitar que se pulsen mas botones una vez pulsas uno
  bool _busy = false;
  bool _registrationMode = false;
  bool _obscurePassword = true;

  // Controladores para el formulario de inicio de sesión
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordVerificationController = TextEditingController();

  // Variables de las animaciones
  double _verPassHigth = 0;

  @override
  void initState() {
    super.initState();
    _auth = firebase_auth.FirebaseAuth.instance;
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((firebase_auth.User? usr) {
      _user = usr;

      debugPrint('user=$_user');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_user != null) {
        FirebaseLogin.isNewUser = false;
        _showMainLayout();
      }
    });

    // NOTE: Registramos las veces que abren la aplicacion
    kFirebaseAnalytics.logAppOpen();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordVerificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Imagen de la partada
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

    final title = Text(
      _registrationMode ? "Registro" : "Iniciar sesión",
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
    // email
    final emailTextField = TextFormField(
      controller: emailController,
      onChanged: (value) {},
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Introduce tu email',
      ),
      validator: (value) {
        if (value == null || !EmailValidator.validate(value)) {
          return 'Por favor introduce un email valido';
        }
        return null;
      },
    );

    // password
    final passwordTextField = TextFormField(
      key: _textFieldKey,
      controller: passwordController,
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Introduce tu contraseña',
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: _obscurePassword
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.length < 6 ||
            value.length > 128 ||
            value.isEmpty) {
          return 'Contraseña invalida (de 6 a 128 caracteres)';
        }
        if (_registrationMode && value != passwordVerificationController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );

    // password verification
    final passwordVerificationTextField = AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      height: _registrationMode
          ? _verPassHigth = _getWidgetHeight(_textFieldKey)
          : _verPassHigth = 0,
      child: TextFormField(
        controller: passwordVerificationController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Verificación de contraseña',
          hintText: 'Intruduce tu contraseña',
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: _obscurePassword
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
          ),
        ),
      ),
    );

    // registrar
    final regButton = MaterialButton(
        color: Colors.blue,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              Icons.app_registration,
              color: Colors.white,
            ),
            Text(
              _registrationMode ? "Registrar" : "",
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
        onPressed: () {
          setState(() {
            debugPrint("valor del _registrationMode: $_registrationMode");
            if (_registrationMode) {
              _createUser();
            }

            _registrationMode = true;

            //
          });
        });
    final loginButton = MaterialButton(
        color: Colors.grey.shade900,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              Icons.login,
              color: Colors.white,
            ),
            Text(
              _registrationMode ? "" : "Acceder",
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
        onPressed: () {
          setState(() {
            if (!_registrationMode) _signIn();
            _registrationMode = false;
            passwordVerificationController.clear();
            FocusScope.of(context).unfocus();
          });
        });
    final statusText = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        _user == null
            ? 'No has iniciado session.'
            : 'Has iniciado sesion como: "${_user!.displayName}".',
      ),
    );
    final googleLoginBtn = MaterialButton(
      shape: const CircleBorder(),
      color: Colors.white,
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              final user = await _googleSignIn();
              setState(() => _busy = false);
              _showMainLayout();
            },
      child: Image.network(
          height: 40,
          'http://pngimg.com/uploads/google/google_PNG19635.png',
          fit: BoxFit.scaleDown),
    );
    final anonymousLoginBtn = MaterialButton(
      shape: const CircleBorder(),
      color: Colors.white,
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              final user = await _anonymousSignIn();
              setState(() => _busy = false);
              _showMainLayout();
            },
      child: Image.asset(
        height: 40,
        "assets/icons/anonymous.png",
        fit: BoxFit.scaleDown,
      ),
    );
    final signOutBtn = TextButton(
      onPressed: _busy
          ? null
          : () async {
              setState(() => _busy = true);
              await _signOut();
              setState(() => _busy = false);
            },
      child: const Text('Log out'),
    );
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // con esto perdemos el foco y se cierra el teclado, cuando hacemos tab fuera del textField
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            _busy
                ? Container(
                    color: Colors.white,
                    child: const Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Iniciando sesión...")
                      ],
                    )),
                  )
                : Center(
                    child: ListView(
                      // physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          vertical: 50.0, horizontal: 50.0),
                      children: <Widget>[
                        logo,
                        const SizedBox(height: 20),
                        title,

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              emailTextField,
                              passwordTextField,
                              passwordVerificationTextField,
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AnimatedContainer(
                                    width: _registrationMode
                                        ? (MediaQuery.of(context).size.width -
                                                100) *
                                            0.70
                                        : (MediaQuery.of(context).size.width -
                                                100) *
                                            0.25,
                                    duration: const Duration(seconds: 1),
                                    child: regButton,
                                  ),
                                  AnimatedContainer(
                                    width: _registrationMode
                                        ? (MediaQuery.of(context).size.width -
                                                100) *
                                            0.25
                                        : (MediaQuery.of(context).size.width -
                                                100) *
                                            0.70,
                                    duration: const Duration(seconds: 1),
                                    child: loginButton,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("Iniciar sesión con:"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        // statusText,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [googleLoginBtn, anonymousLoginBtn],
                        ),
                        // signOutBtn,
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Iniciar session con Google.
  Future<firebase_auth.User?> _googleSignIn() async {
    final curUser = _user ?? _auth.currentUser;
    if (curUser != null && !curUser.isAnonymous) {
      return curUser;
    }
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // NOTE: user.providerData[0].photoUrl == googleUser.plhotoUr.
    final userCredentials = (await _auth.signInWithCredential(credential));
    final user = userCredentials.user;

    // calculamos si es un usuario nuevo y cambiamos la variable "_isNewUser"
    _isNewUser(userCredentials);

    kFirebaseAnalytics.logLogin();
    setState(() => _user = user);
    return user;
  }

  // Iniciar session con el correo y la contraseña.
  Future<void> _signIn() async {
    debugPrint("validacion: ${_formKey.currentState!.validate()}");
    //validamos el formulario
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los datos')),
      );
    } else {
      try {
        UserCredential userCredentials =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        _isNewUser(userCredentials);
        kFirebaseAnalytics.logLogin();
        setState(() {
          _user = userCredentials.user;
        });
        _showMainLayout();

        // El usuario ha iniciado sesión correctamente
      } on FirebaseAuthException catch (e) {
        // Manejar errores de autenticación
        debugPrint('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Usuario no encontrado!',
            style: TextStyle(color: Colors.red),
          )),
        );
      }
    }
  }

  Future<User?> _createUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final result = await firebase_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text);

        kFirebaseAnalytics.logLogin();
        //podemos la variable para saber si el usuario es nuevo o no
        FirebaseLogin.isNewUser = true;
        _showMainLayout();
        setState(() {
          _user = result.user;
        });
        return result.user;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este email ya esta registrado!',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
    return null;
  }

  // Iniciar session anonima.
  Future<firebase_auth.User?> _anonymousSignIn() async {
    final curUser = _user ?? _auth.currentUser;
    if (curUser != null && curUser.isAnonymous) {
      FirebaseLogin.isNewUser = false;
      return curUser;
    }
    final anonyUser = (await _auth.signInAnonymously()).user;
    await anonyUser!
        .updateDisplayName('${anonyUser.uid.substring(0, 5)}_Guest');
    await anonyUser.reload();
    // hay que volver a llamar a `currentUser()` para hacer `updateProfile`
    // funcar segun esta web.
    // Este post es muy util para la modificacion de datos
    // Cf. https://stackoverflow.com/questions/50986191/flutter-firebase-auth-updateprofile-method-is-not-working.
    final user = _auth.currentUser;

    kFirebaseAnalytics.logLogin();
    setState(() => _user = user);
    FirebaseLogin.isNewUser = true;
    return user;
  }

  Future<void> _signOut() async {
    final user = _auth.currentUser;
    //cerramos sesion en todos los tipos de autenticaion
    _auth.signOut();
    // cerramos la sesion si estaamos con google
    await GoogleSignIn().signOut();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user == null
              ? 'No user logged in.'
              : '"${user.displayName}" logged out.',
        ),
      ),
    );

    setState(() => _user = null);
  }

  // Show user's profile in a new screen.
  void _showMainLayout() {
    if (FirebaseLogin.isNewUser) {
      Navigator.of(context).pushReplacementNamed('/main');
      Navigator.of(context).pushNamed("/introductionLayout");
    } else {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  // determinados de forma comodaa si es o no, nuevo usuario
  void _isNewUser(UserCredential userCredential) {
    if (userCredential.additionalUserInfo!.isNewUser) {
      debugPrint('Nuevo usuario');
      FirebaseLogin.isNewUser = true;
    } else {
      debugPrint('Usuario existente');
      FirebaseLogin.isNewUser = false;
    }
  }

  // ----------------------------------------------------------------
  // nos permite saber la altura de un widget (a tarves de su key),
  // lo uso para saber la altura que le tengo que dar al TextField con animacion
  double _getWidgetHeight(GlobalKey widgetKey) {
    try {
      final RenderBox renderBox =
          widgetKey.currentContext?.findRenderObject() as RenderBox;
      final size = renderBox.size;
      return size.height;
    } catch (e) {
      debugPrintStack();
      return 20;
    }
  }

  double _getWidgetWidth(GlobalKey widgetKey) {
    final RenderBox? renderBox =
        widgetKey.currentContext?.findRenderObject() == Null
            ? widgetKey.currentContext?.findRenderObject() as RenderBox
            : null;
    final size = renderBox?.size ?? const Size(0, 0);
    debugPrint('Anchura del widget: ${size.width}');
    return size.width;
  }

  bool _isValidPassword(String password) {
    if (password.length > 6 || password.length < 128) {
      return false;
    }
    return true;
  }
}
