import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movimento.dart';

class MovimentiService {
  final _db = FirebaseFirestore.instance;
  final String userId;

  MovimentiService(this.userId);


  CollectionReference get _col =>
      _db.collection("users").doc(userId).collection("movimentidev");

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

}
