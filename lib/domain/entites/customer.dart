class CustomerEntity {
  final String id;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final DateTime dateOfBirth;

  CustomerEntity({
    required this.id,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.dateOfBirth,
  });
}
 // @override
// bool operator ==(Object other) {
//   if (identical(this, other)) return true;
//
//   return other is CustomerEntity &&
//       other.id == id &&
//       other.createdAt == createdAt &&
//       other.firstName == firstName &&
//       other.lastName == lastName &&and
//       other.phoneNumber == phoneNumber &&
//       other.dateOfBirth == dateOfBirth;
// }

// @override
// int get hashCode {
//   return id.hashCode ^
//   createdAt.hashCode ^
//   firstName.hashCode ^
//   lastName.hashCode ^
//   phoneNumber.hashCode ^
//   dateOfBirth.hashCode;
// }