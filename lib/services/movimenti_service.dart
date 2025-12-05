import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movimento.dart';

class MovimentiService {
  final _db = FirebaseFirestore.instance;
  final String userId;

  MovimentiService(this.userId);


  CollectionReference get _col =>
      _db.collection("users").doc(userId).collection("movimenti");

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

  Future<void> rimuovi(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Movimento>> streamMovimenti() {
    return _col.orderBy("data", descending: true).snapshots().map((snap) {
      return snap.docs.map((doc) {
        return Movimento.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
