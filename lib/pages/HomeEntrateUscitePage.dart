import 'package:flutter/material.dart';
import '../models/movimento.dart';
import '../services/movimenti_service.dart';
import './NuovaTransazioneDialog.dart';
import './CassaDialog.dart';

class HomeEntrateUscitePage extends StatelessWidget {

  final MovimentiService service;

  const HomeEntrateUscitePage({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => apriNuovaTransazioneDialog(context),
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

              // CARD CASSA INIZIALE
              Container(
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
                          "€ 0",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => apriCassaDialog(context),
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
                      children: lista.map(_buildMovimentoRow).toList(),
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
        ],
      ),
    );
  }

  Widget _buildMovimentoRow(Movimento m) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(m.data.toString())),
          Expanded(flex: 4, child: Text(m.descrizione)),
          Expanded(
            flex: 2,
            child: Text("€ ${m.entrata}"),
          ),
          Expanded(flex: 2, child: Text(m.importo.toString())),
          // Expanded(flex: 2, child: Text(m.uscita != null ? "€ ${m.uscita}" : "-")),
          Expanded(flex: 2, child: Text("€ 0")),
          // Expanded(flex: 2, child: Text("€ ${m.saldo.toStringAsFixed(2)}")),
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

  void apriNuovaTransazioneDialog(BuildContext context) {
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
            child: const NuovaTransazioneDialog(),
          ),
        );
      },
    );
  }

  void apriCassaDialog(BuildContext context) {
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
            child: const CassaDialog(),
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
