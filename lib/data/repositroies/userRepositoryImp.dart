import 'package:dartz/dartz.dart';
import 'package:herafi/data/remotDataSource/userDataSource.dart';
import 'package:herafi/domain/repositories/userRepository.dart';

import '../../core/status/error/Failure.dart';
import '../../domain/entites/user.dart';
import '../models/craftsmanModel.dart';
import '../models/customerModel.dart';

class userRepositoryImp extends UserRepository{
  final userRemotDataSource dataSource=userRemotDataSource();


  Future<Either<Failure,UserEntity?>> fetchUserData({required String userId})async{
    try{

      final customerModel;
      final data=await dataSource.fetchUserData(userId: userId);
      print(data);
      if(data==null)return Right(null);
      if(data['user_type']=="craftsman"){
        customerModel = CraftsmanModel.fromJson(data);
      }
      else{
        customerModel = CustomerModel.fromJson(data);
      }

      return Right(customerModel);


    }
    catch(e){
      return Left(DatabaseFailure(e.toString()));
    }
  }
}