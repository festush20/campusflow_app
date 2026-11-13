import 'package:flutter/material.dart';


class EcranTitre extends StatelessWidget {
  final VoidCallback onCommencer;

  const EcranTitre({super.key, required this.onCommencer});

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              couleurs.primary,
              Color.alphaBlend(Colors.black.withAlpha(110), couleurs.primary),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              // Apparition douce (animation finie, pas de boucle).
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                builder: (context, v, enfant) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - v)),
                    child: enfant,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(70),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        semanticLabel: 'Logo CampusFlow',
                        errorBuilder: (context, erreur, trace) => Icon(
                          Icons.event_available,
                          size: 64,
                          color: couleurs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'CampusFlow',
                      style: textes.displaySmall?.copyWith(
                        color: couleurs.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ne ratez plus un rendu.',
                      style: textes.titleMedium?.copyWith(
                        color: couleurs.onPrimary.withAlpha(220),
                      ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: couleurs.primary,
                        minimumSize: const Size(220, 52),
                      ),
                      onPressed: onCommencer,
                      child: const Text('Commencer'),
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