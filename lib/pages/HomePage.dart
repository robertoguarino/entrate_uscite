import 'package:flutter/material.dart';
import '../models/movimento.dart';
import '../services/movimenti_service.dart';

class HomePage extends StatelessWidget {
  final MovimentiService service;

  const HomePage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giornale Contabile")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _nuovoMovimento(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Movimento>>(
        stream: service.streamMovimenti(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final movimenti = snapshot.data!;
          final saldo = movimenti.fold<double>(0, (p, m) => p + (m.entrata ? m.importo : -m.importo));

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Saldo: ${saldo.toStringAsFixed(2)} €",
                    style: TextStyle(
                      fontSize: 28,
                      color: saldo >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: movimenti.length,
                  itemBuilder: (_, i) {
                    final m = movimenti[i];
                    return ListTile(
                      title: Text(m.descrizione),
                      subtitle: Text(m.data.toString()),
                      trailing: Text(
                        (m.entrata ? "+" : "-") + m.importo.toStringAsFixed(2),
                        style: TextStyle(
                          color: m.entrata ? Colors.green : Colors.red,
                          fontSize: 18,
                        ),
                      ),
                      onLongPress: () => service.rimuovi(m.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _nuovoMovimento(BuildContext context) {
    final descrizioneController = TextEditingController();
    final importoController = TextEditingController();
    bool entrata = true;
    final categorie = ["Casa", "Auto", "Cibo", "Lavoro", "Svago", "Altro"];
    String? categoriaSelezionata;
    DateTime dataSelezionata = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text("Nuovo Movimento"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descrizioneController,
                      decoration: const InputDecoration(labelText: "Descrizione"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: importoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Importo"),
                    ),
                    const SizedBox(height: 10),

                    // Entrata / Uscita
                    Row(
                      children: [
                        const Text("Entrata"),
                        Switch(
                          value: entrata,
                          onChanged: (v) => setState(() {
                            entrata = v;
                          }),
                        ),
                        const Text("Uscita"),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Categoria
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Categoria"),
                      items: categorie.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          categoriaSelezionata = value;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    // Data
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Data: ${dataSelezionata.toLocal().toString().split(' ')[0]}",
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: dataSelezionata,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                dataSelezionata = picked;
                              });
                            }
                          },
                          child: const Text("Cambia"),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Annulla"),
                ),
                TextButton(
                  onPressed: () {
                    final descrizione = descrizioneController.text.trim();
                    final importo = double.tryParse(importoController.text) ?? 0;

                    if (descrizione.isEmpty || importo <= 0) return;

                    final nuovo = Movimento(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      descrizione: descrizione,
                      importo: importo,
                      data: dataSelezionata,
                      entrata: entrata,
                      categoria: categoriaSelezionata,
                    );

                    service.aggiungi(nuovo);
                    Navigator.pop(ctx);
                  },
                  child: const Text("Salva"),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
