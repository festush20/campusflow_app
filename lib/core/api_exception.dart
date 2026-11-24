class ApiException implements Exception {
  final String message;
  final int? statut;

  const ApiException(this.message, {this.statut});

  @override
  String toString() => message;
}