import 'package:herafi/data/repositroies/userRepositoryImp.dart';
import 'package:herafi/domain/repositories/userRepository.dart';

class fetchUserDataUseCase{
  final userRepository userRepos;
  fetchUserDataUseCase({required this.userRepos});
  Future call({required String userId})async{
    return userRepos.fetchUserData(userId: userId);
  }
}