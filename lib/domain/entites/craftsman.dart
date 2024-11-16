class CraftsmanEntity {
  final String id;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final int yearsOfExperience;
  final String category;

  CraftsmanEntity({
    required this.id,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.yearsOfExperience,
    required this.category,
  });
}
