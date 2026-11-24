import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// /profil
class PageProfil extends StatelessWidget {
  const PageProfil({super.key});

  @override
  Widget build(BuildContext context) {
    const utilisateur = User(id: 1, nom: 'Festus', email: 'festus@exemple.com');
    final couleurs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: couleurs.primary,
              foregroundColor: couleurs.onPrimary,
              child: Text(
                utilisateur.nom.substring(0, 1),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Text(utilisateur.nom, style: Theme.of(context).textTheme.titleLarge),
            Text(utilisateur.email),
            const SizedBox(height: 24),
          ],
        ),
        FilledButton(
          onPressed: () => context.go('/login'),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}