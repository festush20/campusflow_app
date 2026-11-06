import 'package:flutter/material.dart';

import 'donnees.dart';
import 'models.dart';

/// Formulaire de création d'une tâche. Renvoie la Task à l'écran précédent.
class FormulaireTache extends StatefulWidget {
  final int nouvelId;
  const FormulaireTache({super.key, required this.nouvelId});

  @override
  State<FormulaireTache> createState() => _FormulaireTacheState();
}

class _FormulaireTacheState extends State<FormulaireTache> {
  final _formKey = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _description = TextEditingController();
  int? _coursId;
  DateTime _date = DateTime.now().add(const Duration(days: 3));

  // Libérer les contrôleurs : erreur fréquente citée dans le cours.
  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final choix = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (choix == null || !mounted) return;
    setState(() => _date = DateTime(choix.year, choix.month, choix.day, 17));
  }

  void _enregistrer() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final description = _description.text.trim();
    Navigator.pop(
      context,
      Task(
        id: widget.nouvelId,
        titre: _titre.text.trim(),
        echeance: _date,
        description: description.isEmpty ? null : description,
        coursId: _coursId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titre,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButton<int?>(
                isExpanded: true,
                value: _coursId,
                hint: const Text('Cours'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Aucun cours'),
                  ),
                  ...coursDemo.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.nom),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _coursId = v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Échéance'),
                subtitle: Text(formatDate(_date)),
                trailing: const Icon(Icons.edit, semanticLabel: 'Changer la date'),
                onTap: _choisirDate,
              ),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (facultative)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _enregistrer,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
