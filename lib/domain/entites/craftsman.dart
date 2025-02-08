import 'package:herafi/domain/entites/user.dart';

class CraftsmanEntity extends UserEntity {
  String category;
  int yearsOfExp;


  CraftsmanEntity({
    required this.category,
    required this.yearsOfExp,

    required super.name,
    required super.id,
    required super.image,
    required super.createdAt,
    required super.phoneNumber,
    required super.userType,
    required super.location,
    required super.dateOfBirth,
  });
}