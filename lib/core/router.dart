import 'package:campusflow_app/core/coque_navigation.dart';
import 'package:campusflow_app/ecran_titre.dart';
import 'package:campusflow_app/features/auth/presentation/ecran_login.dart';
import 'package:campusflow_app/features/cours/presentation/page_cours.dart';
import 'package:campusflow_app/features/profil/presentation/page_profil.dart';
import 'package:campusflow_app/features/taches/presentation/pages_taches.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            EcranTitre(onCommencer: () => context.go('/login')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const EcranLogin(),
      ),
      // La barre de navigation est dans le ShellRoute.
      ShellRoute(
        builder: (context, state, child) =>
            CoqueNavigation(chemin: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/taches',
            builder: (context, state) => const PageEcheances(),
          ),
          GoRoute(
            path: '/calendrier',
            builder: (context, state) => const PageCalendrier(),
          ),
          GoRoute(
            path: '/cours',
            builder: (context, state) => const PageCours(),
          ),
          GoRoute(
            path: '/profil',
            builder: (context, state) => const PageProfil(),
          ),
        ],
      ),

      GoRoute(
        path: '/taches/nouvelle',
        builder: (context, state) => const PageFormulaire(),
      ),
      GoRoute(
        path: '/taches/:id',
        builder: (context, state) => PageDetail(
          id: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
    ],
  );
});