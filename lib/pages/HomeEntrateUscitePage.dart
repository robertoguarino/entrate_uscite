import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/movimento.dart';
import '../services/movimenti_service.dart';
import 'TransazioneDialog.dart';
import './CassaDialog.dart';
import 'package:intl/intl.dart';

class HomeEntrateUscitePage extends StatelessWidget {

  final MovimentiService service;
  final bool isMobile;

  const HomeEntrateUscitePage({
    super.key,
    required this.service,
    required this.isMobile,

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

                  // 1) stato di attesa
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2) errore
                  if (snapshot.hasError) {
                    return Text("Errore cassa: ${snapshot.error}");
                  }

                  
                  final cassa = snapshot.data;

                  // 3) se la cassa NON esiste
                  if (cassa == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cassa non impostata",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text("Imposta la cassa iniziale con l’icona ✏️"),
                        ],
                      ),
                    );
                  }

                  // 4) cassa presente
                  final dataFormattataCassa = DateFormat('dd/MM/yyyy').format(cassa.data);
                  cassaCtrl.text = cassa.importo.toStringAsFixed(2);
                  final isEntrata = cassa.entrata;

                  // String dataFormattataCassa;
                  // bool isEntrata = true;
                  // if(cassa != null) {
                  //   cassaCtrl.text = cassa.importo.toStringAsFixed(2);
                  //   isEntrata = cassa.entrata;
                  //   final dataFormattataCassa = DateFormat('dd/MM/yyyy').format(cassa.data);
                  // }

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
                        Text(
                          "Cassa al $dataFormattataCassa",
                          style: const TextStyle(
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
                              "€ ${isEntrata ? cassaCtrl.text : '-${cassaCtrl.text}'}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: isEntrata ? Colors.green : Colors.red,
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
                child: StreamBuilder<List<MovimentoRow>>(
                  stream: service.streamMovimentiConSaldoLive(), // ≤≤≤ STREAM FIRESTORE
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyMessage();
                    }

                    final rows = snapshot.data ?? [];
                      if (rows.isEmpty) {
                        return _buildEmptyMessage();
                      }

                      return ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, i) => _buildMovimentoRow(context, rows[i]),
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
    if (!isMobile) {
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
    
    return const SizedBox.shrink();
  }

  Widget _buildMovimentoRow(BuildContext context, MovimentoRow row) {
    final m = row.movimento;
    final saldo = row.saldo;
    final dataFormattata = DateFormat('dd/MM/yyyy').format(m.data);


    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

      // ✅ MOBILE: card a 2 righe (niente colonne spezzate)
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Data:", style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dataFormattata, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("Descrizione:", style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.descrizione,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.entrata
                        ? "Entrata: € ${m.importo.toStringAsFixed(2)}"
                        : "Uscita: € ${m.importo.toStringAsFixed(2)}",
                    style: TextStyle(color: m.entrata ? Colors.green : Colors.red),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text("Saldo: € ${saldo.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  hoverColor: Colors.transparent,
                  onPressed: () => service.rimuovi(m.id),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  hoverColor: Colors.transparent,
                  onPressed: () async {
                    final mov = await service.trovaPerId(m.id);
                    if (mov != null && context.mounted) {
                      apriNuovaTransazioneDialog(context, service, movimento: mov);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 3),
      margin: const EdgeInsets.only(bottom: 0),
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
          Expanded(flex: 2, child: Text("€ ${saldo.toStringAsFixed(2)}")),
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
