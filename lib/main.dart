import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'pages/HomePage.dart';
import 'pages/HomeEntrateUscitePage.dart';
import 'services/movimenti_service.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    setWindowMinSize(const Size(800, 700));   // ← MINIMO CONSIGLIATO
    // setWindowMaxSize(const Size.infinite);     // ← nessun limite massimo

    // 2️⃣ imposta dimensione iniziale REALE
    setWindowFrame(const Rect.fromLTWH(200, 150, 800, 700));
  }
  
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


    // final service = MovimentiService(userId, env: env);
    final service = MovimentiService(userId);
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;
    
    return MaterialApp(
      title: "Giornale Contabile",
      home: HomeEntrateUscitePage(
        // cassaIniziale: 1000.00,
        // transazioni: [],
        service: service,
        isMobile: isMobile,
      ),
      //home: HomePage(service: service),
      // home: Scaffold(
      //   body: Center(child: Text("Firebase OK")),
        
      // ),
    );
  }
}
