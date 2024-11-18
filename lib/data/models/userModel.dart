import '../../domain/entites/user.dart';

class UserModel  extends UserEntity{

  UserModel({
    required super.name,
    required super.id,
    required super.image,
    required super.createdAt,
    required super.phoneNumber,
    required super.userType,
    required super.location,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      id: json['id'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
      phoneNumber: json['phone_number'],
      userType: json['user_type'],
      location: json['location']
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'userType': userType,
      'location' : location,
    };
  }

  // Map from Entity to Model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      name: entity.name,
      id: entity.id,
      image: entity.image,
      createdAt: entity.createdAt,
      phoneNumber: entity.phoneNumber,
      userType: entity.userType,
      location: entity.location,
    );
  }

  // Map from Model to Entity
  UserEntity toEntity() {
    return UserEntity(
      name: name,
      id: id,
      image: image,
      createdAt: createdAt,
      phoneNumber: phoneNumber,
      userType: userType,
      location:location,
    );
  }
}
