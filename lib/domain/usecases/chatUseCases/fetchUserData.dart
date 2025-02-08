import 'package:dartz/dartz.dart';
import 'package:herafi/domain/repositories/userRepository.dart';

import '../../../core/status/error/Failure.dart';
import '../../entites/user.dart';

class fetchUserDataUseCase{
  final UserRepository userRepos;
  fetchUserDataUseCase({required this.userRepos});
  Future<Either<Failure,UserEntity?>> call({required String userId})async{
    return userRepos.fetchUserData(userId: userId);
  }
}