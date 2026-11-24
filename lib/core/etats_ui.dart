import 'package:campusflow_app/core/api_exception.dart';
import 'package:flutter/material.dart';

String messageDe(Object erreur) =>
    erreur is ApiException ? erreur.message : '$erreur';


class MessageErreur extends StatelessWidget {
  final String message;
  final VoidCallback onReessayer;

  const MessageErreur({
    super.key,
    required this.message,
    required this.onReessayer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, semanticLabel: 'Erreur réseau'),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onReessayer,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> executerAction(
    BuildContext context,
    Future<void> Function() action, {
      String? succes,
    }) async {
  final messager = ScaffoldMessenger.of(context);
  try {
    await action();
    if (succes != null) {
      messager.showSnackBar(SnackBar(content: Text(succes)));
    }
    return true;
  } catch (e) {
    messager.showSnackBar(SnackBar(content: Text('Échec : ${messageDe(e)}')));
    return false;
  }
}