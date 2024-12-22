class CraftsmanViewModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final String phoneNumber;
  final String? image;
  final double rating;
  final bool isAvailable;

  CraftsmanViewModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.phoneNumber,
    this.image,
    required this.rating,
    required this.isAvailable,
  });
}
