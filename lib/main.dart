import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/HomePage.dart';
import 'services/movimenti_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
    
  // );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inizializzato con successo!");
  } catch (e) {
    print("Errore durante l'inizializzazione di Firebase: $e");
  }

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 ID utente temporaneo (sostituibile con login in seguito)
    const userId = "demo-user";

    final service = MovimentiService(userId);
    
    return MaterialApp(
      title: "Giornale Contabile",
      home: HomePage(service: service),
      // home: Scaffold(
      //   body: Center(child: Text("Firebase OK")),
        
      // ),
    );
  }
}
