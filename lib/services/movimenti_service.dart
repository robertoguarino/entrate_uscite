import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movimento.dart';
// import '../config/app_env.dart';
import '../config/app_config.dart';

class MovimentiService {
  // final _db = FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  final String userId;
  

  // MovimentiService(this.userId);
 

  // CollectionReference get _col =>
  //     _db.collection("users").doc(userId).collection("movimentidev");

  MovimentiService(this.userId, {FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  String get _movimentiCollectionName =>
      AppConfig.isDev ? "movimentidev" : "movimenti";

  CollectionReference get _col =>
      _db.collection("users").doc(userId).collection(_movimentiCollectionName);

  Future<void> aggiungi(Movimento m) async {
    print("📌 userId = $userId");
    print("📌 documento = ${m.id}");

    print("📁 Collection path = ${_col.path}");
    print("➡️ Provo a salvare...");
  
    try {
      await _col.doc(m.id).set(m.toMap());
      print("✅ SALVATO!");
    } catch (e, stack) {
      print("❌ ERRORE Firestore:");
      print(e);
      print(stack);
    }
  }

  Future<void> aggiorna(Movimento m) async {
  print("✏️ Aggiorno documento = ${m.id}");
  print("📁 Collection path = ${_col.path}");

  try {
    await _col.doc(m.id).set(m.toMap());
    print("✅ AGGIORNATO!");
  } catch (e, stack) {
    print("❌ ERRORE update Firestore:");
    print(e);
    print(stack);
  }
}

  Future<void> rimuovi(String id) async {
    await _col.doc(id).delete();
  }


  Stream<List<Movimento>> streamMovimenti() {
    return _col
        .orderBy('data', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .where((doc) => doc.id != 'cassa') // filtro lato client
            .map((doc) => Movimento.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }   



  Stream<Movimento?> streamCassa() {
    return _col.doc('cassa').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Movimento.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  Future<Movimento?> trovaPerId(String id) async {
    print("🔎 Cerco documento = $id");
    print("📁 Collection path = ${_col.path}");

    try {
      final doc = await _col.doc(id).get();

      if (!doc.exists || doc.data() == null) {
        print("⚠️ Documento non trovato");
        return null;
      }

      return Movimento.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    } catch (e, stack) {
      print("❌ ERRORE get documento:");
      print(e);
      print(stack);
      return null;
    }
  }

  Stream<List<MovimentoRow>> streamMovimentiConSaldo() {
  return _col
      .orderBy('data', descending: false)
      .snapshots()
      .asyncMap((snap) async {
        final cassa =  await streamCassa().first;
        
        // saldo iniziale dalla cassa (se non esiste -> 0)
        double saldo = 0.0;
        if (cassa != null) {
          saldo = cassa.entrata ? cassa.importo : -cassa.importo;
        }

        final movimenti = snap.docs
            .where((doc) => doc.id != 'cassa')
            .map((doc) => Movimento.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList();

        final rows = <MovimentoRow>[];
        for (final m in movimenti) {
          saldo += m.entrata ? m.importo : -m.importo;
          rows.add(MovimentoRow(movimento: m, saldo: saldo));
        }

        return rows;
      });
  }

  Stream<List<MovimentoRow>> streamMovimentiConSaldoLive() {
  final controller = StreamController<List<MovimentoRow>>();

  Movimento? cassaCorrente;
  List<Movimento> movimentiCorrenti = [];

  void emit() {
    // saldo iniziale dalla cassa
    double saldo = 0.0;
    if (cassaCorrente != null) {
      saldo = cassaCorrente!.entrata
          ? cassaCorrente!.importo
          : -cassaCorrente!.importo;
    }

    // calcolo saldo progressivo
    final rows = <MovimentoRow>[];
    for (final m in movimentiCorrenti) {
      saldo += m.entrata ? m.importo : -m.importo;
      rows.add(MovimentoRow(movimento: m, saldo: saldo));
    }

    controller.add(rows);
  }

  final subCassa = streamCassa().listen((c) {
    cassaCorrente = c;
    emit();
  }, onError: controller.addError);

  final subMov = streamMovimenti().listen((lista) {
    movimentiCorrenti = lista;
    emit();
  }, onError: controller.addError);

  controller.onCancel = () async {
    await subCassa.cancel();
    await subMov.cancel();
    await controller.close();
  };

  return controller.stream;
}


}

class MovimentoRow {
  final Movimento movimento;
  final double saldo;

  MovimentoRow({required this.movimento, required this.saldo});
}
