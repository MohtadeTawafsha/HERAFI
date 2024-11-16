import 'package:dartz/dartz.dart';
import 'package:herafi/core/status/error/Failure.dart';
import 'package:herafi/domain/entites/craftsman.dart';

abstract class CraftsmanRepository {
  Future<Either<Failure, void>> insertCraftsman(CraftsmanEntity craftsman);
}
