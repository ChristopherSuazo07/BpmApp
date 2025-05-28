import 'package:bpm/firebase_options.dart';
import 'package:bpm/widgets/scaffold.dart';
import 'package:flutter/material.dart';

// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_importl
void main() async{

  WidgetsFlutterBinding.ensureInitialized();  // Asegura que todo esté inicializado antes de correr la app
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Inicializa Firebase con la configuración correcta
  );

  //inicializamos el serviciones de notificaciones locales
  runApp( const MyApp());

}


class MyApp extends StatelessWidget{

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey),
        home: const Scafold(),
        
    );
  }
}