class CertificateEntity {
  final int id;
  final DateTime createdAt;
  final String? image; // Nullable
  final String craftsmanId;

  CertificateEntity({
    required this.id,
    required this.createdAt,
    this.image, // Nullable
    required this.craftsmanId,
  });
}
