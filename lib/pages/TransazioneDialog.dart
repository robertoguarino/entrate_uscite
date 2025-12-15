import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimento.dart';
import '../services/movimenti_service.dart';

class NuovaTransazioneDialog extends StatefulWidget {

  final MovimentiService service;
  final Movimento? movimento;
  // final String idMovimento;

  const NuovaTransazioneDialog({super.key, required this.service, this.movimento,});
  

  @override
  State<NuovaTransazioneDialog> createState() => _NuovaTransazioneDialogState();
}

class _NuovaTransazioneDialogState extends State<NuovaTransazioneDialog> {
  DateTime data = DateTime.now();
  bool isEntrata = true;
  bool _prefillDone = false;

  final descrizioneCtrl = TextEditingController();
  final importoCtrl = TextEditingController(text: "0.00");

  bool get isModifica => widget.movimento != null;

  @override
  void initState() {
    super.initState();

    final m = widget.movimento;
    if (m != null) {
      data = m.data;
      isEntrata = m.entrata;
      descrizioneCtrl.text = m.descrizione;
      importoCtrl.text = m.importo.toStringAsFixed(2);
      _prefillDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITOLO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (isModifica ? "Modifica transazione" : "Nuova transazione"),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 26),
              )
            ],
          ),

          const SizedBox(height: 24),

          // leggo da firebase l'importo della cassa
          // StreamBuilder<Movimento?>(
          //   stream: widget.service.trovaPerId(), // deve leggere doc('cassa')
          //   builder: (context, snapshot) {
          //     final movimenti = snapshot.data;

          //     // ✅ Precompila UNA SOLA VOLTA quando arriva la cassa
          //     if (!_prefillDone && movimenti != null) {
          //       _prefillDone = true;
          //       WidgetsBinding.instance.addPostFrameCallback((_) {
          //         if (!mounted) return;
          //         setState(() {
          //           data = movimenti.data;
          //           isEntrata = cassa.entrata;
          //           importoCtrl.text = movimenti.importo.toStringAsFixed(2);
          //         });
          //       });
          //     }

          //     return const SizedBox.shrink();
          //   },
          // ),

          // DATA
          const Text(
            "Data",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: data,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => data = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat("dd/MM/yyyy").format(data)),
                  const Icon(Icons.calendar_today_outlined, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // TIPO
          const Text(
            "Tipo",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isEntrata = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isEntrata ? Colors.green : Colors.black12,
                        width: 2,
                      ),
                      color: isEntrata
                          ? Colors.green.withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        "Entrata",
                        style: TextStyle(
                          fontSize: 16,
                          color: isEntrata ? Colors.green.shade700 : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isEntrata = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: !isEntrata ? Colors.red : Colors.black12,
                        width: 2,
                      ),
                      color: !isEntrata
                          ? Colors.red.withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        "Uscita",
                        style: TextStyle(
                          fontSize: 16,
                          color: !isEntrata ? Colors.red.shade700 : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // DESCRIZIONE
          const Text(
            "Descrizione",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descrizioneCtrl,
            decoration: InputDecoration(
              hintText: "Es: Vendita prodotto, Acquisto materiali...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // IMPORTO
          const Text(
            "Importo (€)",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: importoCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // BOTTONI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ANNULLA
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 18),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Annulla",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              // SALVA
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  // TODO: salva su Firestore
                  final importo = double.tryParse(importoCtrl.text.replaceAll(',', '.')) ?? 0;

                  final isModifica = widget.movimento != null;

                    final movimentoDaSalvare = Movimento(
                      // ✅ se modifica: mantieni lo stesso id, altrimenti creane uno nuovo
                      id: isModifica
                          ? widget.movimento!.id
                          : DateTime.now().microsecondsSinceEpoch.toString(),

                      descrizione: descrizioneCtrl.text,
                      importo: importo,
                      data: data,
                      entrata: isEntrata,

                      // ⚠️ qui probabilmente NON vuoi usare la descrizione come categoria
                      categoria: isModifica
                          ? widget.movimento!.categoria
                          : "varie", // oppure un dropdown categoria
                    );

                    if (isModifica) {
                      await widget.service.aggiorna(movimentoDaSalvare); // <-- crea questo metodo
                    } else {
                      await widget.service.aggiungi(movimentoDaSalvare);
                    }

                    if (mounted) Navigator.pop(context);

                  // final nuovo = Movimento(
                  //   id: DateTime.now().microsecondsSinceEpoch.toString(),
                  //   descrizione: descrizioneCtrl.text,
                  //   importo: importo,
                  //   data: data,
                  //   entrata: isEntrata,
                  //   categoria: descrizioneCtrl.text,
                  // );

                  // //print(nuovo.toMap());
                  // await widget.service.aggiungi(nuovo);

                  // Navigator.pop(context);
                },
                child: const Text(
                  "Salva",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
