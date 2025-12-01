import 'package:cloud_firestore/cloud_firestore.dart';

class Movimento {
  String id;                   // ID documento Firestore
  String descrizione;          // Es: "Bolletta Enel"
  double importo;              // Es: 50.0
  DateTime data;               // Data del movimento
  bool entrata;                // true = entrata, false = uscita
  String? categoria;           // Opzionale (Casa, Auto, Cibo, Lavoro, ecc.)

  Movimento({
    required this.id,
    required this.descrizione,
    required this.importo,
    required this.data,
    required this.entrata,
    this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'descrizione': descrizione,
      'importo': importo,
      'data': Timestamp.fromDate(data),
      'entrata': entrata,
      'categoria': categoria,
    };
  }

  factory Movimento.fromMap(String id, Map<String, dynamic> map) {
    return Movimento(
      id: id,
      descrizione: map['descrizione'] ?? '',
      importo: (map['importo'] as num).toDouble(),
      data: (map['data'] as Timestamp).toDate(),
      entrata: map['entrata'] ?? false,
      categoria: map['categoria'],
    );
  }
}
