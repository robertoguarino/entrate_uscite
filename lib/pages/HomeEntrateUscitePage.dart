import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/movimento.dart';
import '../services/movimenti_service.dart';
import './NuovaTransazioneDialog.dart';
import './CassaDialog.dart';
import 'package:intl/intl.dart';

class HomeEntrateUscitePage extends StatelessWidget {

  final MovimentiService service;
 

  const HomeEntrateUscitePage({
    super.key,
    required this.service,

  }
  );
  

  @override
  Widget build(BuildContext context) {

    final cassaCtrl = TextEditingController(text: "0.00");
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITOLO
              const Text(
                "Gestione Entrate e Uscite",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // HEADER + BOTTONE NUOVA TRANSAZIONE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  ElevatedButton.icon(
                    onPressed: () => apriNuovaTransazioneDialog(context, service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      "Nuova Transazione",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // leggo da firebase l'importo della cassa
              StreamBuilder<Movimento?>(
                stream: service.streamCassa(), // deve leggere doc('cassa')
                builder: (context, snapshot) {

                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final cassa = snapshot.data;
                  if(cassa != null) {
                    cassaCtrl.text = cassa.importo.toStringAsFixed(2);
                    
                  }

                  // CARD CASSA INIZIALE
                  return  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cassa",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              // "€ ${cassaIniziale.toStringAsFixed(2)}",
                              //"€ 0",
                              "€ ${cassaCtrl.text}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => apriCassaDialog(context, service),
                              child: const Text(
                                "Modifica",
                                style: TextStyle(
                                  color: Color(0xFF1A73E8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // TABELLA
              _buildTableHeader(),

              Expanded(
                child: StreamBuilder<List<Movimento>>(
                  stream: service.streamMovimenti(), // ≤≤≤ STREAM FIRESTORE
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyMessage();
                    }

                    final lista = snapshot.data!;
                    
                    return ListView(
                      children: lista
                        .map((m) => _buildMovimentoRow(context, m))
                        .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER TABELLA
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text("Data", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              "Descrizione",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Entrate",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Uscite",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text("Saldo", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded( 
            flex: 2,
            child: Text(""),
          ),
          Expanded(
            flex: 2,
            child: Text(""),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimentoRow(BuildContext context, Movimento m) {
    final dataFormattata = DateFormat('dd-MM-yyyy').format(m.data);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(dataFormattata)),
          Expanded(flex: 4, child: Text(m.descrizione)),
          Expanded( // entrate
            flex: 2,
            // child: Text("€ ${m.entrata}"),
            child: Text(
              (m.entrata ? "€ ${m.importo.toStringAsFixed(2)}" : ""),
              style: TextStyle(
                color: Colors.green,
                //fontSize: 18,
              ),
            ),
          ),
          Expanded( // uscite
            flex: 2, 
            child: Text(
              (m.entrata ? "" :  "€ ${m.importo.toStringAsFixed(2)}"),
              style: TextStyle(
                color: Colors.red,
                //fontSize: 18,
              ),
            ),
            
            ),
          // Expanded(flex: 2, child: Text(m.uscita != null ? "€ ${m.uscita}" : "-")),
          Expanded(flex: 2, child: Text("€ 0")),
          // Expanded(flex: 2, child: Text("€ ${m.saldo.toStringAsFixed(2)}")),
          // ✏️ ICONA delete
          Expanded(flex: 2, child:
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              hoverColor: Colors.transparent,
              tooltip: "Elimina",
              onPressed: () {
                service.rimuovi(m.id);
                // apriModificaMovimentoDialog(context, m);
              },
            ),
          ),
          // ✏️ ICONA MODIFICA
          Expanded(flex: 2, child:
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              hoverColor: Colors.transparent,
              tooltip: "Modifica",
              onPressed: () async {
                // apriModificaMovimentoDialog(context, m);
                final movimentoId = service.trovaPerId(m.id);
                if (movimentoId != null) {
                  apriNuovaTransazioneDialog(context, service, movimento: await movimentoId);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // LISTA TRANSAZIONI VUOTA
  Widget _buildEmptyMessage() {
    return const Center(
      child: Text(
        "Nessuna transazione. Aggiungi la prima transazione per iniziare.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black45, fontSize: 16),
      ),
    );
  }

  // LISTA TRANSAZIONI
  // Widget _buildTransazioniList() {
  //   return ListView(
  //     children: transazioni.map((t) => _buildTransazioneRow(t)).toList(),
  //   );
  // }

  // RIGA TRANSAZIONE
  // Widget _buildTransazioneRow(Transazione t) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF1F6FF),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     margin: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       children: [
  //         Expanded(flex: 2, child: Text(t.data ?? "-")),
  //         Expanded(flex: 4, child: Text(t.descrizione)),
  //         Expanded(
  //             flex: 2,
  //             child: Text(t.entrata != null ? "€ ${t.entrata}" : "-")),
  //         Expanded(
  //             flex: 2,
  //             child: Text(t.uscita != null ? "€ ${t.uscita}" : "-")),
  //         Expanded(
  //             flex: 2,
  //             child: Text("€ ${t.saldo?.toStringAsFixed(2) ?? "-"}")),
  //       ],
  //     ),
  //   );
  // }

  // void apriNuovaTransazioneDialog(BuildContext context, MovimentiService service, [Future<Movimento?>? movimentoId]) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) {
  //       return Dialog(
  //         insetPadding: const EdgeInsets.all(32), // distanza dai bordi esterni
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: ConstrainedBox(
  //           constraints: const BoxConstraints(
  //             maxWidth: 380, // LARGHEZZA FISSA
  //             minWidth: 380,
  //             maxHeight: 650, // non cresce troppo
  //           ),
  //           child: NuovaTransazioneDialog(service: service, movimentoId),
  //         ),
  //       );
  //     },
  //   );
  // }

  void apriNuovaTransazioneDialog(
  BuildContext context,
  MovimentiService service, {
  Movimento? movimento, // null = nuova, non-null = modifica
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 380,
            minWidth: 380,
            maxHeight: 650,
          ),
          child: NuovaTransazioneDialog(
            service: service,
            movimento: movimento,
          ),
        ),
      );
    },
  );
}


  void apriCassaDialog(BuildContext context, MovimentiService service) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(32), // distanza dai bordi esterni
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 380, // LARGHEZZA FISSA
              minWidth: 380,
              maxHeight: 650, // non cresce troppo
            ),
            child: CassaDialog(service: service),
          ),
        );
      },
    );
  }
}

// class Transazione {
//   final String? data;
//   final String descrizione;
//   final double? entrata;
//   final double? uscita;
//   final double? saldo;

//   Transazione({
//     this.data,
//     required this.descrizione,
//     this.entrata,
//     this.uscita,
//     this.saldo,
//   });
// }
