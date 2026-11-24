import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// /login
class EcranLogin extends StatefulWidget {
  const EcranLogin({super.key});

  @override
  State<EcranLogin> createState() => _EcranLoginState();
}

class _EcranLoginState extends State<EcranLogin> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  void _connecter() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    context.go('/taches');
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 72,
                          height: 72,
                          semanticLabel: 'Logo CampusFlow',
                          errorBuilder: (context, erreur, trace) => Icon(
                            Icons.event_available,
                            size: 56,
                            color: couleurs.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Connexion',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Retrouvez vos échéances.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Email requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _motDePasse,
                      obscureText: true,
                      decoration:
                      const InputDecoration(labelText: 'Mot de passe'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Mot de passe requis'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _connecter,
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}